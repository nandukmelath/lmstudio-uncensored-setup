#!/bin/bash
# LM Studio Uncensored Setup — M2 Mac
# Requires: LM Studio installed at /Applications/LM Studio.app
# Run with: chmod +x setup.sh && ./setup.sh

set -e

LMSTUDIO_BIN="$HOME/.lmstudio/bin/lms"
HERMES_CONFIG="$HOME/.hermes/config.yaml"

echo "========================================="
echo " LM Studio Uncensored Setup"
echo "========================================="
echo ""

# 1. Check LM Studio is installed
if [ ! -f "$LMSTUDIO_BIN" ]; then
    echo "❌ LM Studio CLI not found. Please install LM Studio first:"
    echo "   https://lmstudio.ai"
    exit 1
fi
echo "✅ LM Studio CLI found"

# 2. Raise VRAM ceiling to 14.5 GB (requires sudo)
echo ""
echo "Setting GPU memory ceiling to 14.5 GB (requires password)..."
osascript -e 'do shell script "sysctl iogpu.wired_limit_mb=14500" with administrator privileges'
echo "✅ VRAM ceiling: 14.5 GB"

# 3. Install permanent VRAM LaunchDaemon
echo "Installing permanent VRAM LaunchDaemon..."
osascript -e 'do shell script "cat > /Library/LaunchDaemons/com.local.vram-limit.plist << '\''PLIST'\''
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>com.local.vram-limit</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/sbin/sysctl</string>
        <string>iogpu.wired_limit_mb=14500</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLIST
launchctl load /Library/LaunchDaemons/com.local.vram-limit.plist" with administrator privileges'
echo "✅ VRAM LaunchDaemon installed (survives reboots)"

# 4. Start LM Studio server
echo ""
echo "Starting LM Studio server..."
$LMSTUDIO_BIN server start 2>/dev/null || true
sleep 3
echo "✅ LM Studio server running on port 1234"

# 5. Download the model if not present
MODEL_PATH="$HOME/.lmstudio/models/HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive"
MODEL_FILE="Qwen3.5-9B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf"

if [ ! -f "$MODEL_PATH/$MODEL_FILE" ]; then
    echo ""
    echo "Downloading model (5.2 GB, this may take a while)..."
    $LMSTUDIO_BIN get "HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive" --quant Q4_K_M
    echo "✅ Model downloaded"
fi

# 6. Apply no-think patch to GGUF template
echo ""
echo "Patching model template (disabling thinking for instant responses)..."
python3 "$(dirname "$0")/patch_nothink.py" "$MODEL_PATH/$MODEL_FILE"

# 7. Load model with optimal settings
echo ""
echo "Loading model at 65536 context..."
$LMSTUDIO_BIN load qwen3.5-9b-uncensored-hauhaucs-aggressive --context-length 65536 --gpu max
echo "✅ Model loaded"

# 8. Install auto-start LaunchAgent
echo ""
echo "Installing auto-start LaunchAgent..."
mkdir -p "$HOME/.lmstudio/server-logs"
cat > "$HOME/Library/LaunchAgents/com.lmstudio.server.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.lmstudio.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>$HOME/.lmstudio/bin/lms server start &amp;&amp; sleep 5 &amp;&amp; $HOME/.lmstudio/bin/lms load qwen3.5-9b-uncensored-hauhaucs-aggressive --context-length 65536 --gpu max</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>$HOME/.lmstudio/server-logs/autostart.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/.lmstudio/server-logs/autostart-error.log</string>
</dict>
</plist>
PLIST
launchctl load "$HOME/Library/LaunchAgents/com.lmstudio.server.plist" 2>/dev/null || true
echo "✅ LaunchAgent installed (starts on login)"

# 9. Configure Hermes Agent (if installed)
if [ -f "$HERMES_CONFIG" ]; then
    echo ""
    echo "Configuring Hermes Agent..."
    python3 "$(dirname "$0")/configure_hermes.py"
    echo "✅ Hermes Agent → local LM Studio model"
fi

echo ""
echo "========================================="
echo " Setup complete!"
echo "========================================="
echo ""
echo "  Model:    Qwen3.5-9B-Uncensored (no-think)"
echo "  API:      http://localhost:1234/v1"
echo "  Context:  65,536 tokens"
echo "  VRAM:     14.5 GB ceiling"
echo ""
echo "  LM Studio chat: open LM Studio app"
echo "  Hermes Agent:   run 'hermes' in terminal"
echo ""
