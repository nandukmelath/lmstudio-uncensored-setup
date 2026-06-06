# Manual Setup Guide

Step-by-step instructions for each component — useful if the automated script fails or you want to understand what it's doing.

## Step 1 — Raise Metal VRAM ceiling

```bash
# One-time (resets on reboot)
sudo sysctl iogpu.wired_limit_mb=14500

# Verify
sysctl iogpu.wired_limit_mb
# → iogpu.wired_limit_mb: 14500
```

### Make it permanent (LaunchDaemon)

```bash
sudo tee /Library/LaunchDaemons/com.local.vram-limit.plist > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>com.local.vram-limit</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/sbin/sysctl</string>
        <string>iogpu.wired_limit_mb=14500</string>
    </array>
    <key>RunAtLoad</key><true/>
</dict>
</plist>
EOF
sudo launchctl load /Library/LaunchDaemons/com.local.vram-limit.plist
```

## Step 2 — Download the model

Option A — Download pre-patched model from HuggingFace:
```
https://huggingface.co/nandukmelath/Qwen3.5-9B-Uncensored-nothink-GGUF
```
Download `Qwen3.5-9B-Uncensored-nothink-Q4_K_M.gguf` and place in your LM Studio models folder.

Option B — Download original and patch yourself:
```bash
# In LM Studio: search HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive, download Q4_K_M
# Then run:
python3 scripts/patch_nothink.py ~/.lmstudio/models/HauhauCS/.../model.gguf
```

## Step 3 — Load model

```bash
~/.lmstudio/bin/lms server start
~/.lmstudio/bin/lms load qwen3.5-9b-uncensored-hauhaucs-aggressive \
  --context-length 65536 \
  --gpu max
```

## Step 4 — Auto-start on login (LaunchAgent)

```bash
mkdir -p ~/.lmstudio/server-logs

cat > ~/Library/LaunchAgents/com.lmstudio.server.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>com.lmstudio.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string><string>-c</string>
        <string>$HOME/.lmstudio/bin/lms server start && sleep 5 && $HOME/.lmstudio/bin/lms load qwen3.5-9b-uncensored-hauhaucs-aggressive --context-length 65536 --gpu max</string>
    </array>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><false/>
    <key>StandardOutPath</key><string>/Users/YOUR_USERNAME/.lmstudio/server-logs/autostart.log</string>
    <key>StandardErrorPath</key><string>/Users/YOUR_USERNAME/.lmstudio/server-logs/autostart-error.log</string>
</dict>
</plist>
EOF

launchctl load ~/Library/LaunchAgents/com.lmstudio.server.plist
```

## Step 5 — Configure Hermes Agent

```bash
python3 scripts/configure_hermes.py
```

Or manually edit `~/.hermes/config.yaml`:
```yaml
model:
  provider: lmstudio
  default: qwen3.5-9b-uncensored-hauhaucs-aggressive
  base_url: http://127.0.0.1:1234/v1
  context_length: 65536
```

## Verify everything works

```bash
curl -s http://localhost:1234/v1/models | python3 -m json.tool
# Should show your model

curl -s http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3.5-9b-uncensored-hauhaucs-aggressive","messages":[{"role":"user","content":"say hi"}],"max_tokens":20}' \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['choices'][0]['message']['content'])"
```
