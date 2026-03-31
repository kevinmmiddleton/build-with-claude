#!/bin/bash
# ============================================================================
# Build With Claude — One-Command Setup
# ============================================================================
# This script sets up everything a non-technical person needs to start
# building apps from their phone using Claude Code + Telegram.
#
# What it does:
#   1. Installs Bun (JavaScript runtime)
#   2. Installs Claude Code
#   3. Adds Terminal to your Dock
#   4. Adds a friendly welcome message to your terminal
#   5. Adds an easy "update-claude" command
#   6. Creates an auto-start service so Claude Code + Telegram runs on login
#   7. Walks you through next steps
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kevinmmiddleton/build-with-claude/main/setup.sh | bash
#
# Or if you've cloned the repo:
#   bash setup.sh
# ============================================================================

set -e

# Colors for friendly output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║                                                  ║${NC}"
echo -e "${BLUE}${BOLD}║       🚀 Build With Claude — Setup               ║${NC}"
echo -e "${BLUE}${BOLD}║                                                  ║${NC}"
echo -e "${BLUE}${BOLD}║   You're about to set up everything you need     ║${NC}"
echo -e "${BLUE}${BOLD}║   to build apps from your phone.                 ║${NC}"
echo -e "${BLUE}${BOLD}║                                                  ║${NC}"
echo -e "${BLUE}${BOLD}║   Questions? Ask anytime. You've got this.       ║${NC}"
echo -e "${BLUE}${BOLD}║                                                  ║${NC}"
echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
step() {
  echo ""
  echo -e "${GREEN}${BOLD}✓ Step $1: $2${NC}"
  echo -e "  ${BLUE}$3${NC}"
  echo ""
}

info() {
  echo -e "  ${YELLOW}ℹ $1${NC}"
}

success() {
  echo -e "  ${GREEN}✓ $1${NC}"
}

fail() {
  echo -e "  ${RED}✗ $1${NC}"
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
if [[ "$(uname)" != "Darwin" ]]; then
  fail "This script is designed for macOS. You appear to be on $(uname)."
  exit 1
fi

echo -e "${YELLOW}Before we start, let's make sure your Mac is ready...${NC}"
echo ""

# Check for Xcode Command Line Tools (needed for git)
if ! xcode-select -p &>/dev/null; then
  step "0" "Installing Xcode Command Line Tools" "This gives you Git and other developer basics."
  info "A popup may appear asking you to install. Click 'Install' and wait."
  xcode-select --install 2>/dev/null || true
  echo ""
  echo -e "${YELLOW}⏳ Waiting for Xcode Command Line Tools to install...${NC}"
  echo -e "${YELLOW}   If a popup appeared, click Install and wait for it to finish.${NC}"
  echo -e "${YELLOW}   Then press Enter here to continue.${NC}"
  read -r
fi
success "Xcode Command Line Tools: installed"

# ---------------------------------------------------------------------------
# Step 1: Install Bun
# ---------------------------------------------------------------------------
if command -v bun &>/dev/null; then
  success "Bun is already installed ($(bun --version))"
else
  step "1" "Installing Bun" "Bun is the engine that runs Claude Code."
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  success "Bun installed ($(bun --version))"
fi

# Make sure bun is on PATH for this script
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ---------------------------------------------------------------------------
# Step 2: Install Claude Code
# ---------------------------------------------------------------------------
if command -v claude &>/dev/null; then
  success "Claude Code is already installed"
  info "Updating to latest version..."
  bun update -g @anthropic-ai/claude-code 2>/dev/null || true
else
  step "2" "Installing Claude Code" "This is the AI that builds your apps."
  bun install -g @anthropic-ai/claude-code
  success "Claude Code installed"
fi

# ---------------------------------------------------------------------------
# Step 3: Add Terminal to Dock
# ---------------------------------------------------------------------------
step "3" "Adding Terminal to your Dock" "So you can find it easily."

# Check if Terminal is already in the Dock
if ! defaults read com.apple.dock persistent-apps 2>/dev/null | grep -q "Terminal.app"; then
  defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Utilities/Terminal.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  killall Dock 2>/dev/null || true
  success "Terminal added to your Dock"
else
  success "Terminal is already in your Dock"
fi

# ---------------------------------------------------------------------------
# Step 4: Add friendly terminal welcome + aliases
# ---------------------------------------------------------------------------
step "4" "Setting up your terminal environment" "Adding helpful shortcuts and a welcome message."

ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

# Add Bun to PATH if not already there
if ! grep -q 'BUN_INSTALL' "$ZSHRC" 2>/dev/null; then
  echo '' >> "$ZSHRC"
  echo '# Bun' >> "$ZSHRC"
  echo 'export BUN_INSTALL="$HOME/.bun"' >> "$ZSHRC"
  echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$ZSHRC"
fi

# Add update-claude alias
if ! grep -q 'update-claude' "$ZSHRC" 2>/dev/null; then
  echo '' >> "$ZSHRC"
  echo '# Claude Code shortcuts' >> "$ZSHRC"
  echo 'alias update-claude="bun update -g @anthropic-ai/claude-code && echo \"✓ Claude Code updated!\""' >> "$ZSHRC"
  echo 'alias start-claude="claude --channels plugin:telegram:telegram"' >> "$ZSHRC"
  success "Added shortcuts: 'update-claude' and 'start-claude'"
fi

# Add welcome message
if ! grep -q 'Build With Claude' "$ZSHRC" 2>/dev/null; then
  cat >> "$ZSHRC" << 'WELCOME'

# Welcome message
if [[ $- == *i* ]]; then
  echo ""
  echo "  🚀 Build With Claude"
  echo "  ─────────────────────────────────────"
  echo "  start-claude    Start Claude + Telegram"
  echo "  update-claude   Update Claude Code"
  echo "  ─────────────────────────────────────"
  echo ""
fi
WELCOME
  success "Added welcome message to your terminal"
fi

# ---------------------------------------------------------------------------
# Step 5: Prevent Mac from sleeping
# ---------------------------------------------------------------------------
step "5" "Configuring energy settings" "Keeping your Mac awake so Claude stays available."

# Prevent sleep when on power adapter (doesn't affect battery behavior)
sudo pmset -c sleep 0 displaysleep 30 2>/dev/null && \
  success "Mac will stay awake when plugged in (display sleeps after 30 min)" || \
  info "Couldn't set energy settings automatically. You can do this in System Settings > Energy."

# ---------------------------------------------------------------------------
# Step 6: Create auto-start Launch Agent
# ---------------------------------------------------------------------------
step "6" "Setting up auto-start" "Claude Code + Telegram will start automatically when you log in."

LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
PLIST="$LAUNCH_AGENTS/com.claude.telegram.plist"
mkdir -p "$LAUNCH_AGENTS"

cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.telegram</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/.bun/bin/claude</string>
        <string>--channels</string>
        <string>plugin:telegram:telegram</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/.claude/telegram-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/.claude/telegram-stderr.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$HOME/.bun/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>
    <key>WorkingDirectory</key>
    <string>$HOME</string>
</dict>
</plist>
EOF

success "Auto-start configured at: $PLIST"
info "Claude + Telegram will start on your next login."
info "To start it right now: launchctl load $PLIST"

# ---------------------------------------------------------------------------
# Done!
# ---------------------------------------------------------------------------
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║                                                  ║${NC}"
echo -e "${GREEN}${BOLD}║       ✅ Setup Complete!                          ║${NC}"
echo -e "${GREEN}${BOLD}║                                                  ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}What's installed:${NC}"
echo -e "  ✓ Bun (JavaScript runtime)"
echo -e "  ✓ Claude Code (AI builder)"
echo -e "  ✓ Terminal in your Dock"
echo -e "  ✓ Shortcuts: ${YELLOW}start-claude${NC}, ${YELLOW}update-claude${NC}"
echo -e "  ✓ Auto-start on login"
echo -e "  ✓ Mac sleep prevention (when plugged in)"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo -e "  ${BLUE}1.${NC} Open a new Terminal window (so the shortcuts load)"
echo ""
echo -e "  ${BLUE}2.${NC} Sign in to Claude Code:"
echo -e "     ${YELLOW}claude${NC}"
echo -e "     (Follow the prompts to log in with your Claude.ai account)"
echo ""
echo -e "  ${BLUE}3.${NC} Set up your Telegram bot:"
echo -e "     Open Telegram, search for ${BOLD}@BotFather${NC}"
echo -e "     Send: /newbot"
echo -e "     Choose a name and username for your bot"
echo -e "     Copy the token BotFather gives you"
echo ""
echo -e "  ${BLUE}4.${NC} Connect Telegram to Claude Code:"
echo -e "     In Claude Code, type: ${YELLOW}/telegram:configure${NC}"
echo -e "     Paste your bot token when asked"
echo ""
echo -e "  ${BLUE}5.${NC} Start Claude with Telegram:"
echo -e "     ${YELLOW}start-claude${NC}"
echo ""
echo -e "  ${BLUE}6.${NC} Open Telegram on your phone and message your bot."
echo -e "     Try: ${BOLD}\"Create a new React app called my-first-app\"${NC}"
echo ""
echo -e "  ${BLUE}7.${NC} Watch the magic happen. 🎉"
echo ""
echo -e "${YELLOW}Questions? Stuck? That's normal. Ask Claude in Telegram for help.${NC}"
echo ""
