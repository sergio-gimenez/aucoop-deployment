#!/usr/bin/env python3

import json
import ast
import subprocess
import threading
import tempfile
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gtk


APP_DIR = Path(__file__).resolve().parent
MODULES_FILE = APP_DIR / "modules.json"
ESSENTIAL_SCRIPT = APP_DIR / "essential-setup.sh"
MODULE_INSTALLER = APP_DIR / "install-module.sh"
AI_INSTALLER = APP_DIR / "install-local-ai.sh"
PKEXEC_RUNNER = APP_DIR / "pkexec-runner.sh"
WORKBENCH_RUNNER = APP_DIR / "run-workbench-registration.sh"


def load_config():
    with MODULES_FILE.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def total_ram_gb():
    meminfo = Path("/proc/meminfo").read_text(encoding="utf-8")
    for line in meminfo.splitlines():
        if line.startswith("MemTotal:"):
            kb = int(line.split()[1])
            return kb / 1024 / 1024
    return 0


def ai_recommendation(ai_cfg, ram):
    if not ai_cfg.get("enabled", True):
        return "hidden"

    small_ram = ai_cfg.get("small_model_ram_gb", ai_cfg.get("minimum_ram_gb", 8))
    medium_ram = ai_cfg.get("medium_model_ram_gb", ai_cfg.get("recommended_ram_gb", 16))

    if ram < small_ram:
        return "not_recommended"
    if ram < medium_ram:
        return "basic"
    return "recommended"


def recommended_ai_model(ai_cfg, ram):
    models = sorted(ai_cfg.get("models", []), key=lambda m: m.get("min_ram_gb", 0))
    selected = None
    for model in models:
        if ram >= model.get("min_ram_gb", 0):
            selected = model
    return selected


def ai_model_label(model):
    size = model.get('size_gb')
    size_text = f", {size} GB download" if size else ""
    return f"{model['name']} ({model.get('min_ram_gb', '?')} GB+ recommended{size_text})"


def filtered_ai_models(ai_cfg, show_more):
    models = ai_cfg.get("models", [])
    if show_more:
        return models
    return [model for model in models if model.get("curated", True)]


class WelcomeWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="AUCOOP Mint Welcome")
        self.set_default_size(760, 520)
        self.set_border_width(16)

        self.config = load_config()
        self.process = None
        self.sudo_ready = False
        self.essential_complete = False
        self.current_ai_model_id = None

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.add(outer)

        title = Gtk.Label()
        title.set_markup("<span size='xx-large' weight='bold'>Welcome to AUCOOP Mint</span>")
        title.set_xalign(0)
        outer.pack_start(title, False, False, 0)

        subtitle = Gtk.Label(
            label="We are preparing AUCOOP Mint and installing the most important tools."
        )
        subtitle.set_xalign(0)
        subtitle.set_line_wrap(True)
        outer.pack_start(subtitle, False, False, 0)

        self.notebook = Gtk.Notebook()
        outer.pack_start(self.notebook, True, True, 0)

        self.build_essential_tab()
        self.build_optional_tab()
        self.build_registration_tab()
        self.build_advanced_tab()

    def build_essential_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        box.set_border_width(12)

        self.status_label = Gtk.Label(
            label="This may take a few minutes."
        )
        self.status_label.set_xalign(0)
        self.status_label.set_line_wrap(True)
        box.pack_start(self.status_label, False, False, 0)

        self.progress = Gtk.Spinner()
        box.pack_start(self.progress, False, False, 0)

        self.start_button = Gtk.Button(label="Start setup")
        self.start_button.connect("clicked", self.on_start_setup)
        box.pack_start(self.start_button, False, False, 0)

        self.notebook.append_page(box, Gtk.Label(label="Setup"))

    def build_optional_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        box.set_border_width(12)

        intro = Gtk.Label(
            label="Choose any extra tools you want on this computer."
        )
        intro.set_xalign(0)
        intro.set_line_wrap(True)
        box.pack_start(intro, False, False, 0)

        self.optional_status_label = Gtk.Label(label="")
        self.optional_status_label.set_xalign(0)
        self.optional_status_label.set_line_wrap(True)
        box.pack_start(self.optional_status_label, False, False, 0)

        self.optional_spinner = Gtk.Spinner()
        box.pack_start(self.optional_spinner, False, False, 0)

        self.module_checks = {}
        for module in self.config.get("optional_modules", []):
            frame = Gtk.Frame(label=module["name"])
            inner = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
            inner.set_border_width(8)

            description = Gtk.Label(label=module["description"])
            description.set_xalign(0)
            description.set_line_wrap(True)
            inner.pack_start(description, False, False, 0)

            check = Gtk.CheckButton(label=f"Install {module['name']}")
            check.set_active(module.get("default_selected", False))
            check.connect("toggled", self.on_optional_selection_changed)
            inner.pack_start(check, False, False, 0)
            self.module_checks[module["id"]] = check

            frame.add(inner)
            box.pack_start(frame, False, False, 0)

        ai_box = Gtk.Frame(label="Offline AI assistant")
        ai_inner = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        ai_inner.set_border_width(8)

        ram = total_ram_gb()
        ai_cfg = self.config.get("local_ai", {})
        ai_state = ai_recommendation(ai_cfg, ram)
        ai_model = recommended_ai_model(ai_cfg, ram)

        if ai_state == "recommended":
            ai_text = (
                f"This computer has about {ram:.1f} GB of RAM. "
                "An offline AI assistant is recommended here. "
                "Small local models should work reasonably well."
            )
        elif ai_state == "basic":
            ai_text = (
                f"This computer has about {ram:.1f} GB of RAM. "
                "A very small offline AI assistant may work here, but performance will be limited."
            )
        else:
            ai_text = (
                f"This computer has about {ram:.1f} GB of RAM. "
                "An offline AI assistant is not recommended on this machine."
            )

        ai_label = Gtk.Label(label=ai_text)
        ai_label.set_xalign(0)
        ai_label.set_line_wrap(True)
        ai_inner.pack_start(ai_label, False, False, 0)

        if ai_model:
            model_label = Gtk.Label(
                label=f"AUCOOP Mint recommends: {ai_model['name']}"
            )
            model_label.set_xalign(0)
            model_label.set_line_wrap(True)
            ai_inner.pack_start(model_label, False, False, 0)

            selector_title = Gtk.Label(label="Model")
            selector_title.set_xalign(0)
            ai_inner.pack_start(selector_title, False, False, 0)

            self.ai_models = ai_cfg.get("models", [])
            self.ai_model_combo = Gtk.ComboBoxText()
            self.current_ai_model_id = ai_model["id"]
            self.populate_ai_model_combo(show_more=False)
            ai_inner.pack_start(self.ai_model_combo, False, False, 0)

            self.show_more_models_check = Gtk.CheckButton(label="Show more models")
            self.show_more_models_check.connect("toggled", self.on_toggle_more_models)
            ai_inner.pack_start(self.show_more_models_check, False, False, 0)

            selector_hint = Gtk.Label(
                label="You can keep the recommended model, or choose another one after checking canirun.ai."
            )
            selector_hint.set_xalign(0)
            selector_hint.set_line_wrap(True)
            ai_inner.pack_start(selector_hint, False, False, 0)
        else:
            self.ai_model_combo = None
            self.show_more_models_check = None

        canirun_url = ai_cfg.get("canirun_url")
        if canirun_url:
            canirun_button = Gtk.Button(label="Check AI compatibility")
            canirun_button.connect("clicked", self.on_open_canirun, canirun_url)
            ai_inner.pack_start(canirun_button, False, False, 0)

        if ai_state in {"recommended", "basic"}:
            self.ai_check = Gtk.CheckButton(label="Install offline AI assistant")
            self.ai_check.connect("toggled", self.on_optional_selection_changed)
            ai_inner.pack_start(self.ai_check, False, False, 0)
        else:
            self.ai_check = None

        ai_box.add(ai_inner)
        box.pack_start(ai_box, False, False, 0)

        self.install_optional_button = Gtk.Button(label="Install selected tools")
        self.install_optional_button.set_sensitive(False)
        self.install_optional_button.connect("clicked", self.on_install_optional)
        box.pack_end(self.install_optional_button, False, False, 0)

        self.refresh_optional_button_state()

        self.notebook.append_page(box, Gtk.Label(label="Extra tools"))

    def build_advanced_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        box.set_border_width(12)

        self.log_buffer = Gtk.TextBuffer()
        self.log_buffer.set_text("Setup messages will appear here.\n")
        text = Gtk.TextView(buffer=self.log_buffer)
        text.set_editable(False)
        text.set_monospace(True)

        scroll = Gtk.ScrolledWindow()
        scroll.add(text)
        box.pack_start(scroll, True, True, 0)

        self.notebook.append_page(box, Gtk.Label(label="Advanced details"))

    def build_registration_tab(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        box.set_border_width(12)

        intro = Gtk.Label(
            label="Register this computer in Devicehub using Workbench."
        )
        intro.set_xalign(0)
        intro.set_line_wrap(True)
        box.pack_start(intro, False, False, 0)

        instance_label = Gtk.Label(label="Instance")
        instance_label.set_xalign(0)
        box.pack_start(instance_label, False, False, 0)

        self.instance_combo = Gtk.ComboBoxText()
        self.instance_combo.append_text("Demo (demo.ereuse.org)")
        self.instance_combo.append_text("Production (app.ereuse.org)")
        self.instance_combo.append_text("Custom")
        self.instance_combo.set_active(0)
        self.instance_combo.connect("changed", self.on_instance_changed)
        box.pack_start(self.instance_combo, False, False, 0)

        token_label = Gtk.Label(label="Devicehub token")
        token_label.set_xalign(0)
        box.pack_start(token_label, False, False, 0)

        self.token_entry = Gtk.Entry()
        self.token_entry.set_visibility(True)
        self.token_entry.connect("changed", self.on_registration_input_changed)
        box.pack_start(self.token_entry, False, False, 0)

        self.custom_url_label = Gtk.Label(label="Custom Devicehub URL")
        self.custom_url_label.set_xalign(0)
        self.custom_url_label.set_no_show_all(True)
        self.custom_url_label.hide()
        box.pack_start(self.custom_url_label, False, False, 0)

        self.custom_url_entry = Gtk.Entry()
        self.custom_url_entry.set_text("https://demo.ereuse.org/api/v1/snapshot/")
        self.custom_url_entry.set_no_show_all(True)
        self.custom_url_entry.hide()
        self.custom_url_entry.connect("changed", self.on_registration_input_changed)
        box.pack_start(self.custom_url_entry, False, False, 0)

        self.registration_status_label = Gtk.Label(label="")
        self.registration_status_label.set_xalign(0)
        self.registration_status_label.set_line_wrap(True)
        box.pack_start(self.registration_status_label, False, False, 0)

        self.registration_link = Gtk.LinkButton(uri="", label="")
        self.registration_link.set_no_show_all(True)
        self.registration_link.hide()
        self.registration_link.set_halign(Gtk.Align.START)
        box.pack_start(self.registration_link, False, False, 0)

        self.registration_qr_image = Gtk.Image()
        self.registration_qr_image.set_no_show_all(True)
        self.registration_qr_image.hide()
        box.pack_start(self.registration_qr_image, False, False, 0)

        self.registration_spinner = Gtk.Spinner()
        box.pack_start(self.registration_spinner, False, False, 0)

        self.registration_button = Gtk.Button(label="Run Workbench and register this computer")
        self.registration_button.set_sensitive(False)
        self.registration_button.connect("clicked", self.on_run_registration)
        box.pack_end(self.registration_button, False, False, 0)

        self.notebook.append_page(box, Gtk.Label(label="Registration"))

    def append_log(self, line):
        end = self.log_buffer.get_end_iter()
        self.log_buffer.insert(end, line)

    def start_essential_setup(self):
        def worker():
            self.process = subprocess.Popen(
                ["pkexec", str(PKEXEC_RUNNER), "essential-setup"],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )

            assert self.process.stdout is not None
            for line in self.process.stdout:
                GLib.idle_add(self.append_log, line)

            returncode = self.process.wait()
            GLib.idle_add(self.finish_essential_setup, returncode)

        threading.Thread(target=worker, daemon=True).start()

    def finish_essential_setup(self, returncode):
        self.progress.stop()
        if returncode == 0:
            self.essential_complete = True
            self.status_label.set_text("Setup complete\n\nPlease reboot now to finish AUCOOP Mint setup.")
            self.start_button.set_visible(False)
        else:
            self.status_label.set_text("Important setup failed. Check Advanced details.")
            self.start_button.set_sensitive(True)

        self.refresh_optional_button_state()
        return False

    def on_start_setup(self, _button):
        self.start_button.set_sensitive(False)
        self.status_label.set_text("Important setup is in progress.\n\nPlease wait while your computer finishes installing essential tools.")
        self.progress.start()
        self.append_log("Starting important setup...\n")
        self.start_essential_setup()

    def on_install_optional(self, _button):
        selected = [
            module_id
            for module_id, check in self.module_checks.items()
            if check.get_active()
        ]

        if not selected and not (self.ai_check and self.ai_check.get_active()):
            self.append_log("No extra tools selected.\n")
            return

        self.install_optional_button.set_sensitive(False)
        self.optional_status_label.set_text("Installing selected tools. Please wait.")
        self.optional_spinner.start()
        self.append_log("\nInstalling selected tools...\n")

        def worker():
            had_error = False
            ai_installed = False

            for module_id in selected:
                proc = subprocess.Popen(
                    ["pkexec", str(PKEXEC_RUNNER), "install-module", module_id],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    bufsize=1,
                )
                assert proc.stdout is not None
                for line in proc.stdout:
                    GLib.idle_add(self.append_log, line)
                if proc.wait() != 0:
                    had_error = True

            if self.ai_check and self.ai_check.get_active():
                selected_model_id = "auto"
                if self.ai_model_combo and self.ai_model_combo.get_active_id():
                    selected_model_id = self.ai_model_combo.get_active_id()
                proc = subprocess.Popen(
                    ["pkexec", "bash", str(AI_INSTALLER), selected_model_id],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    bufsize=1,
                )
                assert proc.stdout is not None
                for line in proc.stdout:
                    GLib.idle_add(self.append_log, line)
                if proc.wait() != 0:
                    had_error = True
                else:
                    ai_installed = True

            if had_error:
                GLib.idle_add(self.append_log, "\nSome extra tools failed to install.\n")
                GLib.idle_add(self.optional_status_label.set_text, "Some extra tools failed to install.")
            else:
                GLib.idle_add(self.append_log, "\nExtra tools installed.\n")
                GLib.idle_add(self.optional_status_label.set_text, "Extra tools installed.")

            if ai_installed:
                GLib.idle_add(self.pin_local_ai_launcher)

            GLib.idle_add(self.optional_spinner.stop)
            GLib.idle_add(self.refresh_optional_button_state)

        threading.Thread(target=worker, daemon=True).start()

    def on_open_canirun(self, _button, url):
        subprocess.Popen(["xdg-open", url])

    def on_instance_changed(self, combo):
        is_custom = combo.get_active_text() == "Custom"
        if is_custom:
            self.custom_url_label.show()
            self.custom_url_entry.show()
        else:
            self.custom_url_label.hide()
            self.custom_url_entry.hide()
        self.on_registration_input_changed(None)

    def on_registration_input_changed(self, _widget):
        token_ok = bool(self.token_entry.get_text().strip())
        url_ok = True
        if self.instance_combo.get_active_text() == "Custom":
            url_ok = bool(self.custom_url_entry.get_text().strip())
        self.registration_button.set_sensitive(token_ok and url_ok)

    def registration_url(self):
        instance = self.instance_combo.get_active_text()
        if instance and instance.startswith("Demo"):
            return "https://demo.ereuse.org/api/v1/snapshot/"
        if instance and instance.startswith("Production"):
            return "https://app.ereuse.org/api/v1/snapshot/"
        return self.custom_url_entry.get_text().strip()

    def on_run_registration(self, _button):
        token = self.token_entry.get_text().strip()
        url = self.registration_url()

        self.registration_button.set_sensitive(False)
        self.registration_status_label.set_text("Running Workbench and registering this computer. Please wait.")
        self.registration_link.hide()
        self.registration_qr_image.hide()
        self.registration_spinner.start()
        self.append_log("\nRunning Workbench registration...\n")

        def worker():
            proc = subprocess.Popen(
                ["pkexec", "bash", str(WORKBENCH_RUNNER), url, token],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )

            found_url = None
            found_dhid = None
            assert proc.stdout is not None
            for line in proc.stdout:
                if line.startswith("url: "):
                    found_url = line.split("url: ", 1)[1].strip()
                if line.startswith("dhid: "):
                    found_dhid = line.split("dhid: ", 1)[1].strip()
                GLib.idle_add(self.append_log, line)

            code = proc.wait()
            if code == 0:
                status = "Registration complete."
                if found_dhid:
                    status += f" Device ID: {found_dhid}."
                GLib.idle_add(self.registration_status_label.set_text, status)
                if found_url:
                    GLib.idle_add(self.show_registration_result, found_url)
            else:
                GLib.idle_add(self.registration_status_label.set_text, "Registration failed. Check Advanced details.")

            GLib.idle_add(self.registration_spinner.stop)
            GLib.idle_add(self.registration_button.set_sensitive, True)

        threading.Thread(target=worker, daemon=True).start()

    def show_registration_result(self, url):
        self.registration_link.set_uri(url)
        self.registration_link.set_label(url)
        self.registration_link.show()

        qr_path = Path(tempfile.gettempdir()) / "aucoop-devicehub-qr.png"
        subprocess.run(["qrencode", "-o", str(qr_path), url], check=False)
        if qr_path.exists():
            self.registration_qr_image.set_from_file(str(qr_path))
            self.registration_qr_image.show()

        return False

    def on_optional_selection_changed(self, _button):
        self.refresh_optional_button_state()

    def on_toggle_more_models(self, _button):
        show_more = bool(self.show_more_models_check and self.show_more_models_check.get_active())
        self.populate_ai_model_combo(show_more=show_more)

    def populate_ai_model_combo(self, show_more):
        if not self.ai_model_combo:
            return

        active_id = self.ai_model_combo.get_active_id() or self.current_ai_model_id
        self.ai_model_combo.remove_all()

        visible_models = filtered_ai_models(self.config.get("local_ai", {}), show_more)
        for model in visible_models:
            self.ai_model_combo.append(model["id"], ai_model_label(model))

        visible_ids = {model["id"] for model in visible_models}
        if active_id in visible_ids:
            self.ai_model_combo.set_active_id(active_id)
        elif self.current_ai_model_id in visible_ids:
            self.ai_model_combo.set_active_id(self.current_ai_model_id)
        elif visible_models:
            self.ai_model_combo.set_active_id(visible_models[0]["id"])

    def refresh_optional_button_state(self):
        has_selection = any(check.get_active() for check in self.module_checks.values())
        if self.ai_check and self.ai_check.get_active():
            has_selection = True
        self.install_optional_button.set_sensitive(has_selection)

    def pin_local_ai_launcher(self):
        launcher = "aucoop-local-ai.desktop"

        try:
            current = ast.literal_eval(subprocess.check_output(
                ["gsettings", "get", "org.cinnamon", "favorite-apps"],
                text=True,
            ).strip())
            if launcher not in current:
                current.append(launcher)
                subprocess.run(
                    ["gsettings", "set", "org.cinnamon", "favorite-apps", str(current)],
                    check=False,
                )
        except Exception:
            pass

        config_path = Path.home() / ".config/cinnamon/spices/grouped-window-list@cinnamon.org/2.json"
        if config_path.exists():
            try:
                data = json.loads(config_path.read_text(encoding="utf-8"))
                value = data.setdefault("pinned-apps", {}).setdefault("value", [])
                if launcher not in value:
                    value.append(launcher)
                    config_path.write_text(json.dumps(data, indent=4) + "\n", encoding="utf-8")
            except Exception:
                pass


def main():
    win = WelcomeWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
