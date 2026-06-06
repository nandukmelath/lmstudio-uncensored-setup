# Contributing to LM Studio Uncensored Setup

Thanks for wanting to contribute! This project benefits from community input — especially from people running different hardware.

## Ways to contribute

### 🐛 Bug reports
Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md). Include:
- Your Mac model and RAM
- macOS version
- LM Studio version
- Exact error output

### ✨ Feature requests
Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

### 🔧 Pull requests

High-value contributions:
- **Windows/Linux support** — setup scripts for other platforms
- **Ollama integration** — auto-configure Ollama instead of LM Studio
- **More models** — extend `patch_nothink.py` to support Llama 3, Mistral, etc.
- **Benchmark data** — real numbers from M1, M3, different RAM configs
- **CI improvements** — automated tests for the patcher

### Process
1. Fork the repo
2. Create a branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Push and open a PR using the PR template

## Code style
- Shell scripts: POSIX-compatible where possible, bash where needed
- Python: stdlib only (no heavy deps), Python 3.9+
- Keep it simple — this project targets non-technical users too

## License
By contributing, you agree your contributions are licensed under Apache 2.0.
