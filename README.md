<div align="center">

# 🔓 LM Studio Uncensored Setup

### Zero-guardrail local AI on Apple Silicon — instant responses, no cloud, no limits.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Model](https://img.shields.io/badge/🤗%20Model-Qwen3.5--9B--nothink-orange)](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF)
[![Platform](https://img.shields.io/badge/Platform-Apple%20Silicon%20M1%2FM2%2FM3-black)](https://github.com/nandukmelath/lmstudio-uncensored-setup)
[![Stars](https://img.shields.io/github/stars/nandukmelath/lmstudio-uncensored-setup?style=social)](https://github.com/nandukmelath/lmstudio-uncensored-setup/stargazers)

**Everything you need to run a fully uncensored, zero-latency local LLM — automated in one script.**

[🚀 Quick Install](#quick-install) · [🧠 The Model](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF) · [🤖 Hermes Integration](#hermes-agent) · [⚡ Benchmarks](#benchmarks)

</div>

---

## What is this?

Most local LLM setups are slow, over-filtered, and annoying to configure. This isn't.

This repo gives you a **one-command** setup that:

- 🔓 **Zero refusals** — Qwen3.5-9B fully uncensored (HauhauCS fine-tune)
- ⚡ **Instant responses** — thinking mode disabled at GGUF template level (no 20s wait)
- 🧠 **Full intelligence** — model reasoning is in the weights, not the thinking block
- 🔒 **100% local** — nothing leaves your Mac, ever
- 🤖 **Hermes Agent ready** — wire it as your agentic AI backend in one config change
- 🔁 **Auto-start on login** — model pre-loaded and ready before you open a terminal

**Hardware tested:** MacBook Pro M2 Pro, 16 GB — runs at **22–25 tok/s**

---

## Quick Install

```bash
git clone https://github.com/nandukmelath/lmstudio-uncensored-setup
cd lmstudio-uncensored-setup
chmod +x scripts/setup.sh && ./scripts/setup.sh
```

> Requires [LM Studio](https://lmstudio.ai) installed. That's it.

---

## What the script does

| Step | Action | Why |
|------|--------|-----|
| 1 | Raises Metal GPU ceiling to **14.5 GB** | Fits 65K context KV cache on 16 GB |
| 2 | Installs LaunchDaemon (survives reboots) | VRAM boost permanent |
| 3 | Downloads model if not present | Qwen3.5-9B Q4_K_M |
| 4 | **Patches GGUF template** (no-think mode) | Instant responses |
| 5 | Loads model at **65,536 context** | Hermes Agent compatible |
| 6 | Installs LaunchAgent | Auto-starts on every login |
| 7 | Configures Hermes Agent | Local model as agentic backend |

---

## The no-think patch

Qwen3.5 is a **thinking model** — by default it spends 15–30 seconds generating a reasoning chain before answering. Smart, but slow.

This setup patches the GGUF's embedded Jinja2 template to output an empty `<think></think>` block instead:

```
Before: <think> ... 400 tokens of reasoning ... </think> → answer  (25 seconds)
After:  <think></think> → answer                                   (1 second)
```

The model's intelligence is in its **weights**, not the thinking trace. You get the same quality, 25x faster first-token.

> Want deep reasoning on a specific question? Add `/think` to your message — it re-enables thinking for that turn only.

---

## Sampling parameters (Qwen3.5 official)

| Param | Value | Source |
|-------|-------|--------|
| Temperature | `0.6` | [Qwen3 official docs](https://qwenlm.github.io/blog/qwen3/) |
| Top-P | `0.95` | Qwen3 official |
| Top-K | `20` | Qwen3 official |
| Repeat penalty | `1.0` | Disabled — thinking models don't need it |
| Max tokens | `4096` | Full responses |

---

## Hermes Agent

[Hermes Agent](https://github.com/NousResearch/hermes-agent) is a powerful local AI agent. With this setup, it runs entirely on your local model:

```yaml
# ~/.hermes/config.yaml  (auto-configured by setup.sh)
model:
  provider: lmstudio
  default: qwen3.5-9b-uncensored-hauhaucs-aggressive
  base_url: http://127.0.0.1:1234/v1
  context_length: 65536
```

---

## Benchmarks

Tested on MacBook Pro M2 Pro (16 GB):

| Metric | Value |
|--------|-------|
| Generation speed | ~22–25 tok/s |
| Time to first token | <1 second |
| Context window | 65,536 tokens |
| VRAM usage | ~8.5 GB (model + KV cache) |
| Refusal rate | 0% |

---

## Model

The patched model is on HuggingFace: **[nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF)**

Built on:
- [Qwen/Qwen3.5-9B](https://huggingface.co/Qwen/Qwen3.5) (Apache 2.0)
- [HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive](https://huggingface.co/HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive) (Apache 2.0)

---

## License

Apache 2.0 — same as the base models. See [LICENSE](LICENSE).

---

<div align="center">

**If this saved you hours of config hell, drop a ⭐**

Made by [@nandukmelath](https://github.com/nandukmelath) · Model on [🤗 HuggingFace](https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF)

</div>
