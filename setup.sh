#!/bin/bash
# ============================================================================
# Build With Claude — Interactive Setup
# ============================================================================
# A friendly, step-by-step guide that installs everything you need to build
# apps from your phone using Claude Code + Telegram.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kevinmmiddleton/build-with-claude/main/setup.sh | bash
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

TOTAL_STEPS=7
CURRENT_STEP=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
clear_screen() {
  clear
}

progress_bar() {
  local filled=$1
  local total=$2
  local bar=""
  for ((i=1; i<=total; i++)); do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}${GREEN}●${NC} "
    else
      bar="${bar}${DIM}○${NC} "
    fi
  done
  echo -e "  ${bar}  ${DIM}Step $filled of $total${NC}"
}

header() {
  echo ""
  echo -e "${BLUE}${BOLD}  ╭─────────────────────────────────────────╮${NC}"
  echo -e "${BLUE}${BOLD}  │  🚀 Build With Claude                   │${NC}"
  echo -e "${BLUE}${BOLD}  ╰─────────────────────────────────────────╯${NC}"
  echo ""
  progress_bar "$CURRENT_STEP" "$TOTAL_STEPS"
  echo ""
}

wait_for_user() {
  echo ""
  echo -e "  ${YELLOW}Ready to continue? Press Enter.${NC}"
  echo -e "  ${DIM}(or type 'q' to quit and come back later)${NC}"
  read -r response
  if [[ "$response" == "q" || "$response" == "Q" ]]; then
    echo ""
    echo -e "  ${BLUE}No problem! Run this script again anytime to pick up where you left off.${NC}"
    echo ""
    exit 0
  fi
}

explain() {
  echo -e "  ${DIM}$1${NC}"
}

success() {
  echo -e "  ${GREEN}✓ $1${NC}"
}

teaching_moment() {
  echo ""
  echo -e "  ${BLUE}${BOLD}💡 What just happened:${NC}"
  echo -e "  ${BLUE}$1${NC}"
}

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------
if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "  ${RED}This guide is designed for macOS. You appear to be on $(uname).${NC}"
  exit 1
fi

# ============================================================================
# WELCOME
# ============================================================================
clear_screen
echo ""
echo ""
echo -e "${BLUE}${BOLD}  ╭─────────────────────────────────────────╮${NC}"
echo -e "${BLUE}${BOLD}  │                                         │${NC}"
echo -e "${BLUE}${BOLD}  │  🚀 Build With Claude                   │${NC}"
echo -e "${BLUE}${BOLD}  │                                         │${NC}"
echo -e "${BLUE}${BOLD}  │  Build apps from your phone.            │${NC}"
echo -e "${BLUE}${BOLD}  │  No coding experience needed.           │${NC}"
echo -e "${BLUE}${BOLD}  │                                         │${NC}"
echo -e "${BLUE}${BOLD}  ╰─────────────────────────────────────────╯${NC}"
echo ""
echo ""
echo -e "  Welcome! 👋"
echo ""
echo -e "  Over the next few minutes, we're going to set up your Mac"
echo -e "  so you can build real apps by chatting with an AI from your phone."
echo ""
echo -e "  Here's how it works:"
echo ""
echo -e "  ${BOLD}You${NC} message on Telegram → ${BOLD}Claude${NC} writes code on your Mac → ${BOLD}Vercel${NC} puts it online"
echo ""
echo -e "  That's it. You describe what you want. Claude builds it."
echo ""
echo -e "  We'll go step by step. At each step, I'll explain:"
echo -e "  • What we're installing"
echo -e "  • Why you need it"
echo -e "  • What it does in plain English"
echo ""
echo -e "  ${YELLOW}You can ask questions at any point. There are no dumb questions.${NC}"
echo -e "  ${YELLOW}If something doesn't make sense, that's on the guide, not on you.${NC}"
echo ""
wait_for_user

# ============================================================================
# STEP 1: Xcode Command Line Tools
# ============================================================================
CURRENT_STEP=1
clear_screen
header

echo -e "  ${BOLD}Step 1: Developer Tools${NC}"
echo ""
echo -e "  Before we install anything, your Mac needs some basic"
echo -e "  building blocks that Apple provides for free."
echo ""
echo -e "  Think of this like laying the foundation before building a house."
echo -e "  You'll never interact with these tools directly, but everything"
echo -e "  else we install needs them to work."
echo ""
echo -e "  ${DIM}This includes Git, which tracks changes to your code — like"
echo -e "  a detailed 'undo history' for everything you build.${NC}"
echo ""

if xcode-select -p &>/dev/null; then
  success "Already installed! Your Mac has the developer tools."
  teaching_moment "These were already on your machine — maybe from a previous setup.\n  Either way, you're good to go."
else
  echo -e "  ${YELLOW}Installing now...${NC}"
  echo -e "  ${YELLOW}A popup may appear on your screen. Click 'Install' and wait.${NC}"
  echo -e "  ${YELLOW}This can take a few minutes.${NC}"
  echo ""
  xcode-select --install 2>/dev/null || true
  echo ""
  echo -e "  ${YELLOW}⏳ When the installation finishes, press Enter here.${NC}"
  read -r
  teaching_moment "You just installed Git and other developer basics.\n  Git is like Google Docs version history, but for code.\n  Every change gets saved, and you can always go back."
fi

wait_for_user

# ============================================================================
# STEP 2: Install Bun
# ============================================================================
CURRENT_STEP=2
clear_screen
header

echo -e "  ${BOLD}Step 2: Install Bun${NC}"
echo ""
echo -e "  Bun is a program that runs JavaScript — the language most"
echo -e "  web apps are built with."
echo ""
echo -e "  You won't write JavaScript yourself. Claude does that."
echo -e "  But Claude Code is built with JavaScript, so it needs"
echo -e "  something to run it. That's Bun."
echo ""
echo -e "  ${DIM}Analogy: Bun is like the engine in a car. You don't"
echo -e "  think about the engine when you drive, but nothing"
echo -e "  works without it.${NC}"
echo ""

if command -v bun &>/dev/null; then
  success "Bun is already installed! (version $(bun --version))"
  teaching_moment "Bun was already on your machine. Nothing to do here."
else
  echo -e "  ${YELLOW}Installing Bun now...${NC}"
  echo ""
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  echo ""
  success "Bun installed! (version $(bun --version))"
  teaching_moment "Bun is now installed on your Mac. It lives in a hidden\n  folder called .bun in your home directory. You'll never\n  need to open that folder — just know it's there."
fi

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

wait_for_user

# ============================================================================
# STEP 3: Install Claude Code
# ============================================================================
CURRENT_STEP=3
clear_screen
header

echo -e "  ${BOLD}Step 3: Install Claude Code${NC}"
echo ""
echo -e "  This is the star of the show. 🌟"
echo ""
echo -e "  Claude Code is an AI that lives in your terminal."
echo -e "  It can:"
echo -e "    • Write code in any programming language"
echo -e "    • Create entire apps from a description"
echo -e "    • Fix bugs when something breaks"
echo -e "    • Push your code to GitHub"
echo -e "    • Deploy your app to the internet"
echo ""
echo -e "  And when we connect it to Telegram, you can do all"
echo -e "  of this from your phone."
echo ""

if command -v claude &>/dev/null; then
  success "Claude Code is already installed!"
  echo ""
  echo -e "  ${YELLOW}Updating to the latest version...${NC}"
  bun update -g @anthropic-ai/claude-code 2>/dev/null || true
  success "Updated!"
  teaching_moment "Claude Code was already installed. We updated it to\n  make sure you have the latest features and fixes."
else
  echo -e "  ${YELLOW}Installing Claude Code now...${NC}"
  echo ""
  bun install -g @anthropic-ai/claude-code
  echo ""
  success "Claude Code installed!"
  teaching_moment "Claude Code is now a command on your Mac. When you\n  type 'claude' in Terminal, it starts up. We'll do\n  that in a moment, but first let's finish setting up."
fi

wait_for_user

# ============================================================================
# STEP 4: Terminal Shortcuts
# ============================================================================
CURRENT_STEP=4
clear_screen
header

echo -e "  ${BOLD}Step 4: Making Your Life Easier${NC}"
echo ""
echo -e "  We're going to do three small things:"
echo ""
echo -e "  ${BOLD}a)${NC} Add Terminal to your Dock"
echo -e "     ${DIM}So you can find it without searching${NC}"
echo ""
echo -e "  ${BOLD}b)${NC} Create keyboard shortcuts"
echo -e "     ${DIM}Instead of typing long commands, you'll have:${NC}"
echo -e "     ${GREEN}start-claude${NC}  → starts Claude with Telegram"
echo -e "     ${GREEN}update-claude${NC} → updates Claude Code"
echo ""
echo -e "  ${BOLD}c)${NC} Add a welcome message to Terminal"
echo -e "     ${DIM}So when you open Terminal, you see your shortcuts${NC}"
echo ""
echo -e "  ${YELLOW}Setting this up now...${NC}"
echo ""

# Add Terminal to Dock
if ! defaults read com.apple.dock persistent-apps 2>/dev/null | grep -q "Terminal.app"; then
  defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Utilities/Terminal.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  killall Dock 2>/dev/null || true
  success "Terminal added to your Dock (look at the bottom of your screen!)"
else
  success "Terminal is already in your Dock"
fi

# Set up .zshrc
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

if ! grep -q 'BUN_INSTALL' "$ZSHRC" 2>/dev/null; then
  echo '' >> "$ZSHRC"
  echo '# Bun (JavaScript runtime for Claude Code)' >> "$ZSHRC"
  echo 'export BUN_INSTALL="$HOME/.bun"' >> "$ZSHRC"
  echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$ZSHRC"
fi

if ! grep -q 'update-claude' "$ZSHRC" 2>/dev/null; then
  echo '' >> "$ZSHRC"
  echo '# Claude Code shortcuts' >> "$ZSHRC"
  echo 'alias update-claude="bun update -g @anthropic-ai/claude-code && echo \"✓ Claude Code updated!\""' >> "$ZSHRC"
  echo 'alias start-claude="claude --channels plugin:telegram:telegram"' >> "$ZSHRC"
fi

if ! grep -q 'Build With Claude' "$ZSHRC" 2>/dev/null; then
  cat >> "$ZSHRC" << 'WELCOME'

# Welcome message
if [[ $- == *i* ]]; then
  echo ""
  echo "  🚀 Build With Claude"
  echo "  ─────────────────────────────"
  echo "  start-claude    Start Claude + Telegram"
  echo "  update-claude   Update Claude Code"
  echo "  ─────────────────────────────"
  echo ""
fi
WELCOME
fi

success "Shortcuts created"
success "Welcome message added"

teaching_moment "We edited a file called .zshrc — that's a settings file\n  for your Terminal. Every time you open a new Terminal window,\n  it reads this file. Your shortcuts and welcome message will\n  be there every time.\n\n  Think of .zshrc as 'Terminal preferences' — like how your\n  phone remembers your wallpaper and ringtone."

wait_for_user

# ============================================================================
# STEP 5: Keep Your Mac Awake
# ============================================================================
CURRENT_STEP=5
clear_screen
header

echo -e "  ${BOLD}Step 5: Keep Your Mac Awake${NC}"
echo ""
echo -e "  Remember: Claude Code runs on your Mac. If your Mac"
echo -e "  falls asleep, Claude can't receive your Telegram messages."
echo ""
echo -e "  We're going to tell your Mac: when you're plugged in,"
echo -e "  don't go to sleep. Your display will still turn off"
echo -e "  after 30 minutes to save energy, but the computer"
echo -e "  itself will stay awake and ready."
echo ""
echo -e "  ${DIM}If you're on a laptop and unplug it, normal sleep"
echo -e "  behavior resumes. This only applies when charging.${NC}"
echo ""
echo -e "  ${YELLOW}This requires your Mac password (the one you use to log in).${NC}"
echo ""

sudo pmset -c sleep 0 displaysleep 30 2>/dev/null && \
  success "Mac will stay awake when plugged in" || \
  echo -e "  ${YELLOW}Couldn't set this automatically. No worries — you can do it\n  in System Settings > Energy Saver. Set 'Prevent automatic\n  sleeping when the display is off' to On.${NC}"

teaching_moment "Your Mac now knows to stay awake when it's plugged in.\n  This means Claude is always ready to receive your messages,\n  even at 3am. The display still sleeps to save your screen,\n  but the brain stays on."

wait_for_user

# ============================================================================
# STEP 6: Auto-Start Claude on Login
# ============================================================================
CURRENT_STEP=6
clear_screen
header

echo -e "  ${BOLD}Step 6: Auto-Start${NC}"
echo ""
echo -e "  What if your Mac restarts (after an update, a power"
echo -e "  outage, etc.)? You'd have to open Terminal and type"
echo -e "  'start-claude' every time. That's annoying."
echo ""
echo -e "  Instead, we'll create an 'auto-start rule' that tells"
echo -e "  your Mac: every time you log in, start Claude Code"
echo -e "  with Telegram automatically. Set it and forget it."
echo ""
echo -e "  ${DIM}macOS calls these 'Launch Agents.' They're like alarm"
echo -e "  clocks for programs — they go off at a specific time"
echo -e "  (in this case, when you log in).${NC}"
echo ""

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

success "Auto-start rule created"

teaching_moment "We created a small file that macOS reads on login.\n  It says: 'Start Claude Code with Telegram.'\n\n  If Claude ever crashes, macOS will restart it automatically\n  (that's what 'KeepAlive' means). You don't have to babysit it."

wait_for_user

# ============================================================================
# STEP 7: Next Steps
# ============================================================================
CURRENT_STEP=7
clear_screen
header

echo -e "  ${BOLD}Step 7: You're All Set! 🎉${NC}"
echo ""
echo -e "  Everything is installed. Here's what we did:"
echo ""
echo -e "  ${GREEN}✓${NC} Developer tools (the foundation)"
echo -e "  ${GREEN}✓${NC} Bun (the engine)"
echo -e "  ${GREEN}✓${NC} Claude Code (the AI builder)"
echo -e "  ${GREEN}✓${NC} Terminal in your Dock + shortcuts"
echo -e "  ${GREEN}✓${NC} Mac stays awake when plugged in"
echo -e "  ${GREEN}✓${NC} Auto-start on login"
echo ""
echo -e "  ${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Now, the fun part. Three things left to do by hand:${NC}"
echo ""
echo -e "  ${BLUE}${BOLD}1. Sign in to Claude Code${NC}"
echo -e "     Open a ${BOLD}new${NC} Terminal window and type:"
echo -e "     ${GREEN}claude${NC}"
echo -e "     Follow the prompts to log in with your Claude.ai account."
echo -e "     Then type ${GREEN}/quit${NC} to exit."
echo ""
echo -e "  ${BLUE}${BOLD}2. Create your Telegram bot${NC}"
echo -e "     Open Telegram on your phone."
echo -e "     Search for ${BOLD}@BotFather${NC}"
echo -e "     Send: ${GREEN}/newbot${NC}"
echo -e "     Pick a name and username."
echo -e "     Copy the token it gives you."
echo ""
echo -e "  ${BLUE}${BOLD}3. Connect Telegram to Claude${NC}"
echo -e "     In Terminal, type: ${GREEN}claude${NC}"
echo -e "     Then type: ${GREEN}/telegram:configure${NC}"
echo -e "     Paste your bot token."
echo -e "     Then: ${GREEN}/telegram:access${NC} to pair your account."
echo ""
echo -e "  ${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Once that's done, open a new Terminal and type:"
echo -e "  ${GREEN}${BOLD}start-claude${NC}"
echo ""
echo -e "  Then message your bot on Telegram:"
echo -e "  ${BOLD}\"Create a React app called hello-world and deploy it to Vercel\"${NC}"
echo ""
echo -e "  And watch it happen. From your phone. 📱✨"
echo ""
echo -e "  ${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${DIM}Stuck? That's normal. Here are your options:${NC}"
echo -e "  ${DIM}• Ask Claude in Telegram — it can troubleshoot itself${NC}"
echo -e "  ${DIM}• Check the guide: github.com/kevinmmiddleton/build-with-claude${NC}"
echo -e "  ${DIM}• Open an issue on the GitHub repo${NC}"
echo ""
echo -e "  ${YELLOW}The best way to learn is to build something you actually want.${NC}"
echo -e "  ${YELLOW}Start small. Add features as you go. You've got this.${NC}"
echo ""
