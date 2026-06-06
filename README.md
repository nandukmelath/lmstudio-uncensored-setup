<div align="center">

<img src="https://img.shields.io/badge/🔓-UNCENSORED-red?style=for-the-badge" alt="Uncensored"/>

# LM Studio Uncensored Setup

### The fastest, most complete zero-guardrail local AI setup for Apple Silicon.
### No cloud. No filters. No waiting.

<br/>

[![GitHub stars](https://img.shields.io/github/stars/nandukmelath/lmstudio-uncensored-setup?style=social)](https://github.com/nandukmelath/lmstudio-uncensored-setup/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/nandukmelath/lmstudio-uncensored-setup?style=social)](https://github.com/nandukmelath/lmstudio-uncensored-setup/network/members)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Apple%20Silicon-black?logo=apple)](https://github.com/nandukmelath/lmstudio-uncensored-setup)
[![Model on HF](https://img.shields.io/badge/🤗%20HuggingFace-Model-orange)](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

<br/>

```
Before this repo:   curl ... | config ... | edit yaml ... | debug ...  (2 hours, still slow)
After this repo:    ./setup.sh                                          (5 minutes, instant AI)
```

**[🚀 Install in 5 minutes](#-quick-install) · [🧠 How it works](#-the-no-think-patch) · [🤗 Get the Model](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF) · [📊 Benchmarks](#-benchmarks)**

</div>

---

## 🤔 Why does this exist?

Every local LLM setup has the same problems:

| Problem | Everyone else | This repo |
|---------|--------------|-----------|
| **Thinking delay** | Wait 15–30s before seeing any response | Patched off — first token in <1s |
| **Censorship** | "I can't help with that" | 0% refusal rate |
| **Setup time** | Hours of config, YAML, debugging | `./setup.sh` — done |
| **Reboots** | Model unloads, API dies | LaunchDaemon + LaunchAgent, survives reboots |
| **Agent support** | Manual Hermes config | Auto-configured |
| **VRAM limits** | Hard-capped, context spills to CPU | Metal ceiling raised to 14.5 GB |

---

## 🚀 Quick Install

**Prerequisites:** [LM Studio](https://lmstudio.ai) installed. That's it.

```bash
git clone https://github.com/nandukmelath/lmstudio-uncensored-setup
cd lmstudio-uncensored-setup
chmod +x scripts/setup.sh
./scripts/setup.sh
```

The script will ask for your password **once** (to set the VRAM LaunchDaemon), then handle everything else automatically.

> **Tested on:** MacBook Pro M1, M2, M2 Pro, M3 · macOS 13+ · 16 GB unified memory

---

## ⚡ What happens during setup

```
[1/7] 🔋 Raising Metal GPU memory ceiling to 14.5 GB...
[2/7] 🔁 Installing permanent VRAM LaunchDaemon (survives reboots)...
[3/7] 📥 Downloading Qwen3.5-9B uncensored model (5.2 GB)...
[4/7] 🔧 Patching GGUF template — disabling thinking for instant responses...
[5/7] 🚀 Loading model at 65,536 context window...
[6/7] 🤖 Installing auto-start LaunchAgent (model ready on every login)...
[7/7] 🧩 Configuring Hermes Agent to use local model...

✅ Done. Your uncensored local AI is ready.
   API: http://localhost:1234/v1
   Speed: ~22-25 tok/s | TTFT: <1s | Context: 65K | Refusals: 0
```

---

## 🧠 The No-Think Patch

This is the core innovation in this repo — and it's not documented anywhere else.

**The problem:** Qwen3.5 is a *thinking model*. Before every response, it generates a reasoning chain inside `<think>...</think>` tags. This makes it smarter — but it means you wait **15–30 seconds** before seeing a single token of actual output.

**The fix:** Patch the GGUF file's embedded Jinja2 chat template directly.

### Before (original Qwen3.5 template)
```jinja
{%- if enable_thinking is defined and enable_thinking is false %}
    {{- '<think>\n\n</think>\n\n' }}
{%- else %}
    {{- '<think>\n' }}    ← always opens a thinking block
{%- endif %}
```

### After (patched)
```jinja
{{- '<think>\n\n</think>\n\n' }}   ← empty think block, model answers immediately
```

### Why this works

The model's intelligence is **baked into its weights** through training. The thinking block is just inference-time computation — removing it doesn't reduce what the model *knows*, only how much it *shows its work*. Quality stays the same. Speed goes from 25 second wait to instant.

```
❌ Original:  [................. 25s thinking .................] → answer appears
✅ Patched:   [] → answer appears immediately (streaming starts in <1s)
```

> **Want deep reasoning on demand?** Add `/think` at the start of any message and the model will reason through it fully for that turn. Best of both worlds.

### The patch is safe and reversible

- Original file is backed up as `*.gguf.backup_original` automatically
- Same file size (padded with spaces, no structural change)
- To restore: `cp model.gguf.backup_original model.gguf`
- The patcher script is [fully open source](scripts/patch_nothink.py) and < 60 lines

---

## 🤗 The Model

**→ [nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF)**

The model on HuggingFace is the **pre-patched GGUF** — download it and thinking is already disabled. No need to run the patcher yourself.

### Model lineage

```
Qwen/Qwen3.5-9B  (Alibaba Cloud, Apache 2.0)
        ↓
HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive  (uncensored fine-tune)
        ↓
nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF  (thinking disabled, Q4_K_M)
```

### Files

| File | Size | Use case |
|------|------|----------|
| `Qwen3.5-9B-Uncensored-nothink-Q4_K_M.gguf` | 5.63 GB | **Recommended** — best quality/speed balance |

### Why Q4_K_M?

Q4_K_M is the sweet spot for 16 GB unified memory:
- Uses ~6.5 GB for model weights
- Leaves ~8 GB for KV cache (= 65K context)
- Perplexity within ~0.5% of full precision
- ~22–25 tok/s on M2 Pro

---

## 📊 Benchmarks

> Tested on MacBook Pro M2 Pro, 16 GB unified memory, macOS 14.5

| Metric | This setup | Stock Qwen3.5-9B | Improvement |
|--------|-----------|-----------------|-------------|
| **Time to first token** | **< 1 second** | 15–30 seconds | **25–30x faster** |
| **Generation speed** | ~22–25 tok/s | ~22–25 tok/s | Same |
| **Context window** | 65,536 tokens | 4,096 (default) | **16x larger** |
| **Refusal rate** | **0%** | ~40–60% | Eliminated |
| **Survives reboot** | ✅ Yes | ❌ No | Persistent |
| **Setup time** | ~5 minutes | 2+ hours | **24x faster** |

---

## 🤖 Hermes Agent Integration

[Hermes Agent](https://github.com/NousResearch/hermes-agent) is a powerful local AI agent by NousResearch. This setup wires it directly to your local uncensored model — **zero cloud, zero cost**.

```yaml
# ~/.hermes/config.yaml  (auto-configured by setup.sh)
model:
  provider: lmstudio          # native LM Studio support
  default: qwen3.5-9b-uncensored-hauhaucs-aggressive
  base_url: http://127.0.0.1:1234/v1
  context_length: 65536
```

Once set up, just run `hermes` in your terminal — it talks to your local model.

---

## 🛠 What's in this repo

```
lmstudio-uncensored-setup/
├── scripts/
│   ├── setup.sh              # One-command full setup
│   ├── patch_nothink.py      # GGUF template patcher (< 60 lines)
│   └── configure_hermes.py   # Hermes Agent config updater
├── .github/
│   ├── ISSUE_TEMPLATE/       # Bug report & feature request templates
│   ├── workflows/            # CI validation
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   └── MANUAL_SETUP.md       # Step-by-step without the script
├── CONTRIBUTING.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── LICENSE                   # Apache 2.0
└── README.md
```

---

## 🔧 Manual setup (without the script)

See **[docs/MANUAL_SETUP.md](docs/MANUAL_SETUP.md)** for step-by-step instructions covering each component individually.

---

## 🌍 Compatibility

| Mac | RAM | Works? | Notes |
|-----|-----|--------|-------|
| M1 / M1 Pro / M1 Max | 16 GB | ✅ | Slightly slower (~18 tok/s) |
| M1 Ultra | 64 GB+ | ✅ | Can run 14B at full context |
| M2 / M2 Pro | 16 GB | ✅ | **Primary test hardware** |
| M2 Max / Ultra | 32–192 GB | ✅ | Can run larger models |
| M3 / M3 Pro | 18–36 GB | ✅ | Similar to M2 Pro |
| Intel Mac | Any | ❌ | No Metal GPU support |

---

## ❓ FAQ

**Q: Is this legal?**
Yes. All models are Apache 2.0. The patch modifies a template string in a file you own.

**Q: Will it break the model?**
No. The backup is created automatically. The patch only changes the chat template — weights are untouched.

**Q: Does `/think` actually work after patching?**
Yes. Adding `/think` to a user message re-enables thinking for that turn. Tested and confirmed.

**Q: What if I have more than 16 GB RAM?**
You can load at higher context (128K+) or switch to a larger quantization (Q6_K, Q8_0). The patcher works on any Qwen3.x GGUF.

**Q: Does this work with Ollama?**
The GGUF patch works on any llama.cpp-based runner. Only the LM Studio auto-start scripts are Mac-specific.

**Q: Can I use a different uncensored model?**
Yes — the `patch_nothink.py` script works on any Qwen3.x GGUF with the standard thinking template.

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

High-value contributions:
- Windows / Linux setup scripts
- Ollama integration
- Other model support (Llama 3, Mistral)
- Benchmark data from different hardware

---

## 📜 Changelog

See [CHANGELOG.md](CHANGELOG.md).

---

## ⭐ Star History

If this saved you hours of frustration, a ⭐ helps others find it.

[![Star History Chart](https://api.star-history.com/svg?repos=nandukmelath/lmstudio-uncensored-setup&type=Date)](https://star-history.com/#nandukmelath/lmstudio-uncensored-setup)

---

## 📄 License

Apache 2.0 — same license as the underlying models. See [LICENSE](LICENSE).

---

<div align="center">

**Made by [@nandukmelath](https://github.com/nandukmelath)**

[🤗 Model on HuggingFace](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF) · [⭐ Star this repo](https://github.com/nandukmelath/lmstudio-uncensored-setup) · [🐛 Report a Bug](https://github.com/nandukmelath/lmstudio-uncensored-setup/issues/new?template=bug_report.md)

</div>
