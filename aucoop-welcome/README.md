# AUCOOP Welcome

Small GTK welcome app for AUCOOP Mint.

Goals:

- show that important setup is happening
- expose a live log view for advanced users
- offer optional software modules after essential setup finishes
- stay easy to extend through config files
- keep local-AI prompts conditional so weak machines are not cluttered

Responsibilities:

- run on first login after `install.sh` has finished the base AUCOOP provisioning
- complete slow or hardware-specific setup such as updates, codecs, and driver installation
- offer optional extras like offline knowledge and local AI
- launch device registration once the machine is already usable

The app is intentionally simple and native to Linux Mint.
