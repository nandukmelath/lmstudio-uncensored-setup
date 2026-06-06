# Changelog

All notable changes to this project will be documented here.

## [1.0.0] — 2026-06-06

### Added
- `setup.sh` — one-command full setup for Apple Silicon Macs
- `patch_nothink.py` — GGUF Jinja2 template patcher (disables thinking)
- `configure_hermes.py` — auto-configures Hermes Agent to use local LM Studio
- LaunchDaemon for permanent 14.5 GB Metal VRAM ceiling
- LaunchAgent for auto-start on login (server + model pre-loaded)
- HuggingFace model release: [Qwen3.5-9B-Uncensored-nothink-GGUF](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF)

### Technical details
- Raises iogpu.wired_limit_mb to 14500 (from default 8192)
- Patches `enable_thinking` Jinja2 block in GGUF to always emit empty think tag
- Loads model at 65,536 token context (Hermes Agent minimum)
- Sets Qwen3 official sampling: temp=0.6, top_p=0.95, top_k=20
