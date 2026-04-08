#!/bin/bash
# ============================================================================
# Build With Claude — Interactive Setup
# ============================================================================
# A friendly, step-by-step guide that installs everything you need to build
# apps from your phone using Claude Code + Telegram.
#
# Usage (recommended — downloads and runs):
#   bash <(curl -fsSL https://raw.githubusercontent.com/kevinmmiddleton/build-with-claude/main/setup.sh)
#
# Or if you've cloned the repo:
#   bash setup.sh
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

TOTAL_STEPS=9
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

# Read from the real keyboard, not from a pipe
# This is critical when running via: bash <(curl ...)
wait_for_user() {
  echo ""
  echo -e "  ${YELLOW}Ready to continue? Press Enter.${NC}"
  echo -e "  ${DIM}(or type 'q' to quit and come back later)${NC}"
  read -r response </dev/tty
  if [[ "$response" == "q" || "$response" == "Q" ]]; then
    echo ""
    echo -e "  ${BLUE}No problem! Run this script again anytime to pick up where you left off.${NC}"
    echo ""
    exit 0
  fi
}

ask_user() {
  read -r response </dev/tty
  echo "$response"
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
# Error logging — captures failures to help debug later
# ---------------------------------------------------------------------------
ERROR_LOG="$HOME/.claude/setup-errors.log"

log_error() {
  local step="$1"
  local error_msg="$2"
  mkdir -p "$HOME/.claude"
  echo "---" >> "$ERROR_LOG"
  echo "timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$ERROR_LOG"
  echo "step: $step" >> "$ERROR_LOG"
  echo "macOS: $(sw_vers -productVersion 2>/dev/null || echo 'unknown')" >> "$ERROR_LOG"
  echo "error: $error_msg" >> "$ERROR_LOG"
  echo "" >> "$ERROR_LOG"
}

handle_error() {
  local step="$1"
  local error_msg="$2"
  log_error "$step" "$error_msg"
  echo ""
  echo -e "  ${RED}Something went wrong at: $step${NC}"
  echo -e "  ${RED}$error_msg${NC}"
  echo ""
  echo -e "  ${YELLOW}This has been logged to: ~/.claude/setup-errors.log${NC}"
  echo ""
  echo -e "  ${DIM}Don't worry — once Telegram is set up, you can paste${NC}"
  echo -e "  ${DIM}the error log to Claude and it can help troubleshoot.${NC}"
}

# ---------------------------------------------------------------------------
# Setup journal — writes a CLAUDE.md that tracks setup progress
# ---------------------------------------------------------------------------
SETUP_FILE="$HOME/.claude/CLAUDE.md"

write_setup_file() {
  mkdir -p "$HOME/.claude"
  cat > "$SETUP_FILE" << SETUPEOF
# My Setup — Build With Claude

> This file tracks your setup progress. Claude Code reads it automatically
> so it knows what's configured and can help you if you get stuck.
>
> Last updated: $(date '+%Y-%m-%d %H:%M')

## Setup Status

| Step | Status |
|------|--------|
| Developer Tools (Xcode CLI) | ${SETUP_XCODE:-⏳ Pending} |
| Bun (JavaScript runtime) | ${SETUP_BUN:-⏳ Pending} |
| Claude Code | ${SETUP_CLAUDE:-⏳ Pending} |
| GitHub CLI | ${SETUP_GITHUB:-⏳ Pending} |
| Terminal shortcuts | ${SETUP_SHORTCUTS:-⏳ Pending} |
| Mac energy settings | ${SETUP_ENERGY:-⏳ Pending} |
| Auto-start on login | ${SETUP_AUTOSTART:-⏳ Pending} |
| Claude Code sign-in | ${SETUP_SIGNIN:-⏳ Pending} |
| Telegram bot created | ${SETUP_BOT:-⏳ Pending} |
| Telegram connected | ${SETUP_TELEGRAM:-⏳ Pending} |
| First message sent | ${SETUP_FIRST_MSG:-⏳ Pending} |

## Accounts

| Service | Status | What It's For |
|---------|--------|---------------|
| Claude.ai | ${ACCT_CLAUDE:-❓ Unknown} | AI builder (required) |
| GitHub | ${ACCT_GITHUB:-❓ Not set up} | Code storage |
| Supabase | ${ACCT_SUPABASE:-❓ Not set up} | Database + auth |
| Vercel | ${ACCT_VERCEL:-❓ Not set up} | Deployment |
| Sentry | ${ACCT_SENTRY:-❓ Not set up} | Error tracking |
| Stripe | ${ACCT_STRIPE:-❓ Not set up} | Payments |
| Resend | ${ACCT_RESEND:-❓ Not set up} | Email |

## Quick Reference

- Start Claude + Telegram: \`start-claude\`
- Update Claude Code: \`update-claude\`
- Guide: https://github.com/kevinmmiddleton/build-with-claude

## Notes

If you're reading this and something isn't set up yet, tell Claude:
"Help me finish my setup — check my CLAUDE.md for what's pending."
SETUPEOF
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
echo -e "  ${BOLD}Before we start, let's make sure you have:${NC}"
echo ""
echo -e "  ${BOLD}[ ]${NC} A Claude.ai account with a ${BOLD}Pro${NC} (\$20/mo) or ${BOLD}Max${NC} (\$100/mo) plan"
echo -e "      ${DIM}Sign up at claude.ai if you don't have one${NC}"
echo -e "  ${BOLD}[ ]${NC} Telegram installed on your phone"
echo -e "      ${DIM}Free from the App Store${NC}"
echo -e "  ${BOLD}[ ]${NC} Your Mac plugged in to power"
echo -e "      ${DIM}Some installs take a few minutes${NC}"
echo ""
echo -e "  ${YELLOW}Got all three? Press Enter to begin.${NC}"
echo -e "  ${DIM}(If you need to set up Claude.ai or Telegram first, type 'q')${NC}"

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
  SETUP_XCODE="✅ Installed"
  teaching_moment "These were already on your machine — maybe from a previous setup.\n  Either way, you're good to go."
else
  echo -e "  ${YELLOW}Installing now...${NC}"
  echo -e "  ${YELLOW}A popup will appear on your screen. Click 'Install' and wait.${NC}"
  echo -e "  ${YELLOW}This can take 5-10 minutes — that's normal.${NC}"
  echo ""
  xcode-select --install 2>/dev/null || true
  echo ""
  echo -e "  ${YELLOW}⏳ Waiting for the installation to finish...${NC}"
  echo -e "  ${YELLOW}   When the popup says 'The software was installed', press Enter here.${NC}"
  echo ""
  read -r </dev/tty
  # Verify it actually installed
  if xcode-select -p &>/dev/null; then
    SETUP_XCODE="✅ Installed"
    success "Developer tools installed!"
  else
    echo -e "  ${RED}Hmm, it doesn't look like the installation finished.${NC}"
    echo -e "  ${RED}Try running this script again after the install completes.${NC}"
    exit 1
  fi
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
  SETUP_BUN="✅ Installed ($(bun --version))"
  success "Bun is already installed! (version $(bun --version))"
  teaching_moment "Bun was already on your machine. Nothing to do here."
else
  echo -e "  ${YELLOW}Installing Bun now...${NC}"
  echo ""
  if curl -fsSL https://bun.sh/install | bash; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    echo ""
    SETUP_BUN="✅ Installed ($(bun --version))"
    success "Bun installed! (version $(bun --version))"
  else
    handle_error "Install Bun" "curl install script failed"
  fi
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
  SETUP_CLAUDE="✅ Installed"
  success "Updated!"
  teaching_moment "Claude Code was already installed. We updated it to\n  make sure you have the latest features and fixes."
else
  echo -e "  ${YELLOW}Installing Claude Code now...${NC}"
  echo ""
  if bun install -g @anthropic-ai/claude-code; then
    echo ""
    SETUP_CLAUDE="✅ Installed"
    success "Claude Code installed!"
  else
    handle_error "Install Claude Code" "bun install failed"
  fi
  teaching_moment "Claude Code is now a command on your Mac. When you\n  type 'claude' in Terminal, it starts up. We'll do\n  that in a moment, but first let's finish setting up."
fi

wait_for_user

# ============================================================================
# STEP 4: Set Up GitHub
# ============================================================================
CURRENT_STEP=4
clear_screen
header

echo -e "  ${BOLD}Step 4: Set Up GitHub${NC}"
echo ""
echo -e "  GitHub is where your code lives online. Think of it as"
echo -e "  Google Drive for code — it stores everything safely and"
echo -e "  lets you access it from anywhere."
echo ""
echo -e "  When Claude builds your app, it pushes the code to GitHub."
echo -e "  Then Vercel reads from GitHub and puts your app online."
echo ""
echo -e "  ${BOLD}You → Claude → GitHub → Vercel → Live app${NC}"
echo ""

if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
  SETUP_GITHUB="✅ Connected"
  ACCT_GITHUB="✅ Connected"
  success "GitHub CLI is installed and you're logged in!"
  teaching_moment "You're already set up with GitHub. Claude can push\n  code on your behalf."
else
  echo -e "  We need to install the GitHub CLI (a tool that lets Claude"
  echo -e "  push code to GitHub without you having to do it manually)."
  echo ""

  if ! command -v gh &>/dev/null; then
    echo -e "  ${YELLOW}Installing GitHub CLI...${NC}"
    echo ""
    # Try Homebrew first, fall back to direct download
    if command -v brew &>/dev/null; then
      brew install gh 2>/dev/null || true
    else
      # Install via the official script
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null || {
        echo -e "  ${YELLOW}Let's install Homebrew first (a package manager for Mac)...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
        brew install gh
      }
    fi
    success "GitHub CLI installed!"
  fi

  echo ""
  echo -e "  ${BOLD}Now let's log in to GitHub.${NC}"
  echo ""
  echo -e "  If you don't have a GitHub account yet, go to ${BOLD}github.com${NC}"
  echo -e "  and create one first. It's free."
  echo ""
  echo -e "  ${YELLOW}When you're ready, press Enter and follow the login prompts.${NC}"
  read -r </dev/tty

  gh auth login </dev/tty || {
    echo ""
    echo -e "  ${YELLOW}No worries if that didn't work. You can always log in later by typing:${NC}"
    echo -e "  ${GREEN}gh auth login${NC}"
  }

  if gh auth status &>/dev/null 2>&1; then
    SETUP_GITHUB="✅ Connected"
    ACCT_GITHUB="✅ Connected"
    success "Logged in to GitHub!"
    teaching_moment "Claude can now push code to GitHub on your behalf.\n  Every app you build will have its own 'repository' (folder)\n  on GitHub. You can see all your projects at github.com."
  else
    echo ""
    teaching_moment "GitHub login didn't complete, but that's okay.\n  You can do it later by typing: gh auth login\n  Claude will remind you if it needs GitHub access."
  fi
fi

wait_for_user

# ============================================================================
# STEP 5: Terminal Shortcuts
# ============================================================================
CURRENT_STEP=5
clear_screen
header

echo -e "  ${BOLD}Step 5: Making Your Life Easier${NC}"
echo ""
echo -e "  We're going to do three small things:"
echo ""
echo -e "  ${BOLD}a)${NC} Add Terminal to your Dock"
echo -e "     ${DIM}So you can find it without searching${NC}"
echo ""
echo -e "  ${BOLD}b)${NC} Create shortcuts"
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

# Add Homebrew to PATH if installed
if [ -d "/opt/homebrew/bin" ] && ! grep -q '/opt/homebrew/bin/brew' "$ZSHRC" 2>/dev/null; then
  echo '' >> "$ZSHRC"
  echo '# Homebrew' >> "$ZSHRC"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$ZSHRC"
fi

if ! grep -q 'update-claude' "$ZSHRC" 2>/dev/null; then
  echo '' >> "$ZSHRC"
  echo '# Claude Code shortcuts' >> "$ZSHRC"
  echo 'alias update-claude="bun update -g @anthropic-ai/claude-code && echo \"✓ Claude Code updated!\""' >> "$ZSHRC"
  echo 'alias start-claude="claude --channels plugin:telegram:telegram --dangerously-skip-permissions"' >> "$ZSHRC"
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

SETUP_SHORTCUTS="✅ Done"
success "Shortcuts created"
success "Welcome message added"

teaching_moment "We edited a file called .zshrc — that's a settings file\n  for your Terminal. Every time you open a new Terminal window,\n  it reads this file. Your shortcuts and welcome message will\n  be there every time.\n\n  Think of .zshrc as 'Terminal preferences' — like how your\n  phone remembers your wallpaper and ringtone."

wait_for_user

# ============================================================================
# STEP 6: Keep Your Mac Awake
# ============================================================================
CURRENT_STEP=6
clear_screen
header

echo -e "  ${BOLD}Step 6: Keep Your Mac Awake${NC}"
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
echo -e "  ${DIM}Type it when prompted — the cursor won't move, that's normal.${NC}"
echo ""

sudo -v </dev/tty 2>/dev/null && sudo pmset -c sleep 0 displaysleep 30 2>/dev/null && \
  SETUP_ENERGY="✅ Configured" && success "Mac will stay awake when plugged in" || {
  SETUP_ENERGY="⚠️ Manual setup needed"
  echo ""
  echo -e "  ${YELLOW}Couldn't set this automatically. No worries!${NC}"
  echo -e "  ${YELLOW}You can do it manually:${NC}"
  echo -e "  ${DIM}  System Settings > Energy Saver (or Battery > Options)${NC}"
  echo -e "  ${DIM}  Turn on: 'Prevent automatic sleeping when the display is off'${NC}"
}

teaching_moment "Your Mac now knows to stay awake when it's plugged in.\n  This means Claude is always ready to receive your messages,\n  even at 3am. The display still sleeps to save your screen,\n  but the brain stays on.\n\n  ${DIM}Tip: if you typed your password and nothing seemed to happen,\n  that's normal — macOS hides password input for security.${NC}"

wait_for_user

# ============================================================================
# STEP 7: Auto-Start Claude on Login
# ============================================================================
CURRENT_STEP=7
clear_screen
header

echo -e "  ${BOLD}Step 7: Auto-Start${NC}"
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
echo -e "  ${DIM}Note: auto-start only works after you've signed in to"
echo -e "  Claude Code and set up Telegram (the next step).${NC}"
echo ""

LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
PLIST="$LAUNCH_AGENTS/com.claude.telegram.plist"
mkdir -p "$LAUNCH_AGENTS"

# Use full expanded path (not $HOME) in the plist so launchd resolves it
USER_HOME="$HOME"

cat > "$PLIST" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.telegram</string>
    <key>ProgramArguments</key>
    <array>
        <string>${USER_HOME}/.bun/bin/claude</string>
        <string>--channels</string>
        <string>plugin:telegram:telegram</string>
        <string>--dangerously-skip-permissions</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${USER_HOME}/.claude/telegram-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>${USER_HOME}/.claude/telegram-stderr.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${USER_HOME}/.bun/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>${USER_HOME}</string>
    </dict>
    <key>WorkingDirectory</key>
    <string>${USER_HOME}</string>
</dict>
</plist>
PLISTEOF

# Make sure the .claude directory exists for logs
mkdir -p "$HOME/.claude"

SETUP_AUTOSTART="✅ Configured"
success "Auto-start rule created"

# Write progress so far
write_setup_file

teaching_moment "We created a small file that macOS reads on login.\n  It says: 'Start Claude Code with Telegram.'\n\n  If Claude ever crashes, macOS will restart it automatically\n  (that's what 'KeepAlive' means). You don't have to babysit it.\n\n  ${DIM}The auto-start kicks in after you complete the Telegram\n  setup in the next step and restart your Mac (or log out/in).${NC}"

wait_for_user

# ============================================================================
# STEP 8: Set Up Your Pipeline (Vercel + Supabase)
# ============================================================================
CURRENT_STEP=8
clear_screen
header

echo -e "  ${BOLD}Step 8: Your App Pipeline${NC}"
echo ""
echo -e "  Right now Claude can write code and push it to GitHub."
echo -e "  But to make a real app that people can visit, we need"
echo -e "  two more pieces:"
echo ""
echo -e "  ${BOLD}Vercel${NC} — takes your code from GitHub and puts it on the internet."
echo -e "  ${DIM}Every time Claude pushes code, Vercel automatically updates"
echo -e "  your live app. No manual steps.${NC}"
echo ""
echo -e "  ${BOLD}Supabase${NC} — gives your app a database, user accounts, and storage."
echo -e "  ${DIM}If your app needs users to sign up, save data, or upload files,"
echo -e "  Supabase handles all of that.${NC}"
echo ""
echo -e "  ${BOLD}The pipeline:${NC}"
echo -e "  You message Telegram → Claude writes code → pushes to GitHub → Vercel deploys → Live app"
echo ""
echo -e "  ${DIM}Both are free to start. You won't need a credit card.${NC}"

wait_for_user

# --- 8a: Vercel ---
clear_screen
header

echo -e "  ${BOLD}Step 9a: Set Up Vercel${NC}"
echo ""
echo -e "  Vercel is what puts your app on the internet."
echo -e "  It watches your GitHub repo and every time new code"
echo -e "  is pushed, it automatically rebuilds and deploys."
echo ""
echo -e "  ${BOLD}Here's what to do:${NC}"
echo ""
echo -e "  1. Open your browser and go to ${BOLD}vercel.com${NC}"
echo ""
echo -e "  2. Click ${BOLD}\"Sign Up\"${NC}"
echo ""
echo -e "  3. Choose ${BOLD}\"Continue with GitHub\"${NC}"
echo -e "     ${DIM}This connects Vercel to your GitHub account so it"
echo -e "     can read your code and deploy it.${NC}"
echo ""
echo -e "  4. Authorize Vercel when GitHub asks"
echo ""
echo -e "  5. That's it for now! You don't need to import a project yet."
echo -e "     ${DIM}When Claude creates your first app, it will push to GitHub."
echo -e "     Then you'll come back to Vercel and click 'Import Project'.${NC}"
echo ""
echo -e "  ${YELLOW}Press Enter when you've signed up for Vercel.${NC}"
read -r </dev/tty

ACCT_VERCEL="✅ Account created"
write_setup_file
success "Vercel account ready!"

teaching_moment "Vercel is now connected to your GitHub. When Claude\n  pushes code to a repo, you'll import it in Vercel and\n  every future push deploys automatically. Zero effort.\n\n  ${DIM}Your apps will get a free URL like: your-app.vercel.app${NC}"

wait_for_user

# --- 8b: Supabase ---
clear_screen
header

echo -e "  ${BOLD}Step 9b: Set Up Supabase${NC}"
echo ""
echo -e "  Supabase is the backend for your app — it handles"
echo -e "  the stuff you can't see: user accounts, saved data,"
echo -e "  file uploads, and more."
echo ""
echo -e "  ${DIM}Think of it as a filing cabinet for your app. Users sign in,"
echo -e "  their data gets stored, and it's all organized and secure.${NC}"
echo ""
echo -e "  ${BOLD}Here's what to do:${NC}"
echo ""
echo -e "  1. Open your browser and go to ${BOLD}supabase.com${NC}"
echo ""
echo -e "  2. Click ${BOLD}\"Start your project\"${NC}"
echo ""
echo -e "  3. Sign up with ${BOLD}GitHub${NC} (same account you just used)"
echo ""
echo -e "  4. Create a new project:"
echo -e "     • Pick a name (anything — e.g., 'my-first-app')"
echo -e "     • Set a database password (save this somewhere safe!)"
echo -e "     • Choose a region close to you"
echo -e "     • Click 'Create new project'"
echo ""
echo -e "  5. Wait for it to finish setting up (~30 seconds)"
echo ""
echo -e "  6. Go to ${BOLD}Settings > API${NC} in the left sidebar"
echo -e "     You'll see:"
echo -e "     • ${BOLD}Project URL${NC} — starts with https://"
echo -e "     • ${BOLD}anon public key${NC} — a long string"
echo -e "     ${DIM}You don't need to copy these now. When Claude builds"
echo -e "     your app, it'll ask you for them.${NC}"
echo ""
echo -e "  ${YELLOW}Press Enter when you've created your Supabase project.${NC}"
read -r </dev/tty

ACCT_SUPABASE="✅ Project created"
write_setup_file
success "Supabase project ready!"

teaching_moment "Your app now has a database. When Claude builds\n  features like user accounts or saving data, it'll\n  connect to this Supabase project. You'll just need\n  to paste the URL and key when Claude asks for them."

wait_for_user

# ============================================================================
# STEP 9: Guided Manual Steps
# ============================================================================
CURRENT_STEP=9
clear_screen
header

echo -e "  ${BOLD}Step 9: The Finish Line${NC}"
echo ""
echo -e "  Everything is set up! Here's what we did:"
echo ""
echo -e "  ${GREEN}✓${NC} Developer tools (the foundation)"
echo -e "  ${GREEN}✓${NC} Bun (the engine)"
echo -e "  ${GREEN}✓${NC} Claude Code (the AI builder)"
echo -e "  ${GREEN}✓${NC} GitHub (where your code lives)"
echo -e "  ${GREEN}✓${NC} Terminal in your Dock + shortcuts"
echo -e "  ${GREEN}✓${NC} Mac stays awake when plugged in"
echo -e "  ${GREEN}✓${NC} Auto-start on login"
echo -e "  ${GREEN}✓${NC} Vercel (automatic deployment)"
echo -e "  ${GREEN}✓${NC} Supabase (database + auth)"
echo ""
echo -e "  Now we need to do a few things together that I can't"
echo -e "  automate — signing in and connecting Telegram."
echo ""
echo -e "  ${YELLOW}I'll walk you through each one. Ready?${NC}"

wait_for_user

# --- 8a: Sign in to Claude ---
clear_screen
header

echo -e "  ${BOLD}Step 9a: Sign in to Claude Code${NC}"
echo ""
echo -e "  We need to open a ${BOLD}new${NC} Terminal window for this."
echo ""
echo -e "  Here's how:"
echo -e "  1. Look at your Dock (bottom of the screen)"
echo -e "  2. Click the Terminal icon (it looks like a black screen)"
echo -e "  3. A new window opens"
echo -e "  4. Type: ${GREEN}claude${NC}"
echo -e "  5. Press Enter"
echo ""
echo -e "  Claude will open a browser window asking you to sign in"
echo -e "  with your Claude.ai account. Sign in, then come back here."
echo ""
echo -e "  ${DIM}If you don't have a Claude.ai account yet, go to${NC}"
echo -e "  ${DIM}claude.ai and sign up. You'll need a Pro ($20/mo) or${NC}"
echo -e "  ${DIM}Max ($100/mo) plan.${NC}"
echo ""
echo -e "  ${YELLOW}After you've signed in to Claude Code, type /quit in"
echo -e "  that Terminal window to close it, then come back here.${NC}"
echo ""
echo -e "  ${YELLOW}Press Enter when you've completed this step.${NC}"
read -r </dev/tty

SETUP_SIGNIN="✅ Signed in"
ACCT_CLAUDE="✅ Pro/Max plan"
write_setup_file
success "Claude Code sign-in complete!"

teaching_moment "You just linked your Claude.ai account to Claude Code\n  on this Mac. You only need to do this once — it remembers\n  you across Terminal sessions and restarts."

wait_for_user

# --- 8b: Create Telegram bot ---
clear_screen
header

echo -e "  ${BOLD}Step 9b: Create Your Telegram Bot${NC}"
echo ""
echo -e "  Now let's create your personal AI bot on Telegram."
echo -e "  Grab your phone — this part happens there."
echo ""
echo -e "  ${BOLD}On your phone:${NC}"
echo ""
echo -e "  1. Open ${BOLD}Telegram${NC}"
echo -e "     ${DIM}(download it from the App Store if you don't have it)${NC}"
echo ""
echo -e "  2. Search for ${BOLD}@BotFather${NC}"
echo -e "     ${DIM}Look for the one with a blue checkmark — that's the real one${NC}"
echo ""
echo -e "  3. Send this message: ${GREEN}/newbot${NC}"
echo ""
echo -e "  4. BotFather asks for a ${BOLD}name${NC} — type anything friendly"
echo -e "     ${DIM}Example: My Claude Bot${NC}"
echo ""
echo -e "  5. BotFather asks for a ${BOLD}username${NC} — must end in 'bot'"
echo -e "     ${DIM}Example: yourname_claude_bot${NC}"
echo ""
echo -e "  6. BotFather replies with a ${BOLD}token${NC} — a long string like:"
echo -e "     ${DIM}7123456789:AAHx1234567890abcdefghijklmnop${NC}"
echo ""
echo -e "  ${YELLOW}${BOLD}Copy that token.${NC} ${YELLOW}You'll need it in the next step.${NC}"
echo ""
echo -e "  ${YELLOW}Press Enter when you've got the token copied.${NC}"
read -r </dev/tty

SETUP_BOT="✅ Created"
write_setup_file
success "Bot created!"

teaching_moment "You just created a Telegram bot. Right now it's empty —\n  it doesn't do anything yet. In the next step, we'll\n  connect it to Claude Code so it becomes your AI builder."

wait_for_user

# --- 8c: Connect Telegram to Claude ---
clear_screen
header

echo -e "  ${BOLD}Step 9c: Connect Telegram to Claude Code${NC}"
echo ""
echo -e "  Almost there! Now we connect your bot to Claude Code."
echo ""
echo -e "  ${BOLD}Open a new Terminal window${NC} and do these steps:"
echo ""
echo -e "  1. Type: ${GREEN}claude${NC}"
echo -e "     ${DIM}(Claude Code starts up)${NC}"
echo ""
echo -e "  2. Type: ${GREEN}/telegram:configure${NC}"
echo -e "     ${DIM}(This tells Claude about your bot)${NC}"
echo ""
echo -e "  3. It will ask for your bot token"
echo -e "     ${BOLD}Paste the token${NC} you copied from BotFather"
echo -e "     ${DIM}(Cmd+V to paste)${NC}"
echo ""
echo -e "  4. Type: ${GREEN}/telegram:access${NC}"
echo -e "     ${DIM}(This pairs your Telegram account)${NC}"
echo ""
echo -e "  5. Follow the prompts — it will ask you to message"
echo -e "     your bot on Telegram to verify it's you"
echo ""
echo -e "  6. When it confirms pairing, type: ${GREEN}/quit${NC}"
echo ""
echo -e "  ${YELLOW}Press Enter when you've completed all of these steps.${NC}"
read -r </dev/tty

SETUP_TELEGRAM="✅ Connected"
write_setup_file
success "Telegram connected!"

teaching_moment "Your Telegram bot is now connected to Claude Code.\n  When you message the bot, it goes to your Mac, Claude\n  processes it, and replies back on Telegram."

wait_for_user

# --- 8d: First launch ---
clear_screen
header

echo -e "  ${BOLD}Step 9d: Launch! 🚀${NC}"
echo ""
echo -e "  This is it. The moment of truth."
echo ""
echo -e "  ${BOLD}Open a new Terminal window${NC} and type:"
echo ""
echo -e "     ${GREEN}${BOLD}start-claude${NC}"
echo ""
echo -e "  You should see Claude Code start up with Telegram"
echo -e "  connected. Leave this Terminal window open — it's now"
echo -e "  your always-on AI builder."
echo ""
echo -e "  ${BOLD}Now open Telegram on your phone${NC} and message your bot."
echo ""
echo -e "  Try something simple:"
echo -e "  ${BOLD}\"Hi! Tell me what you can do.\"${NC}"
echo ""
echo -e "  ${YELLOW}Press Enter when Claude has replied on Telegram.${NC}"
read -r </dev/tty

SETUP_FIRST_MSG="✅ Sent!"
write_setup_file

clear_screen
echo ""
echo ""
echo -e "${GREEN}${BOLD}  ╭─────────────────────────────────────────╮${NC}"
echo -e "${GREEN}${BOLD}  │                                         │${NC}"
echo -e "${GREEN}${BOLD}  │  🎉 You did it!                         │${NC}"
echo -e "${GREEN}${BOLD}  │                                         │${NC}"
echo -e "${GREEN}${BOLD}  │  You can now build apps from your phone. │${NC}"
echo -e "${GREEN}${BOLD}  │                                         │${NC}"
echo -e "${GREEN}${BOLD}  ╰─────────────────────────────────────────╯${NC}"
echo ""
echo ""
echo -e "  ${BOLD}What to try next:${NC}"
echo ""
echo -e "  Message your bot on Telegram with something like:"
echo ""
echo -e "  • ${BOLD}\"Create a personal website with my name and bio\"${NC}"
echo -e "  • ${BOLD}\"Build a to-do app where I can add and check off tasks\"${NC}"
echo -e "  • ${BOLD}\"Make a link saver where I can paste URLs and tag them\"${NC}"
echo ""
echo -e "  Start small. Add features as you go."
echo -e "  The best way to learn is to build something you actually want."
echo ""
echo -e "  ${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Your shortcuts:${NC}"
echo -e "  ${GREEN}start-claude${NC}   Start Claude + Telegram"
echo -e "  ${GREEN}update-claude${NC}  Update Claude Code"
echo ""
echo -e "  ${BOLD}Stuck?${NC}"
echo -e "  • Ask Claude in Telegram — it can troubleshoot itself"
echo -e "  • Guide: ${BLUE}github.com/kevinmmiddleton/build-with-claude${NC}"
echo ""
echo -e "  ${YELLOW}You've got this. Happy building! 🛠️${NC}"
echo ""
