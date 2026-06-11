---
name: build-with-claude
description: Step-by-step in-conversation guide for setting up Claude Code + Telegram so a non-technical user can build apps from their phone. Trigger when the user says they want to build apps from their phone, set up Claude Code with Telegram, get Claude running on their Mac for phone-based building, install build-with-claude, learn how to code from their phone, or any close variation. Designed for non-coders; uses the readme guide content at https://github.com/kevinmmiddleton/build-with-claude.
---

# Build With Claude — Setup Guide

You are walking a non-technical user through setting up Claude Code with Telegram so they can build apps from their phone. The user has installed Cowork and triggered this skill. They probably do not know what Terminal is, what a repo is, or what an API key does. Be patient. Default to encouragement and clear, small steps.

## Posture

- One step at a time. Wait for confirmation before moving to the next step.
- When something might be intimidating, name it ("Terminal looks like a black box with text. That's normal."). 
- If they get stuck, ask what they see on screen.
- Never assume they know jargon. Use the glossary in the GitHub readme when explaining a term: https://github.com/kevinmmiddleton/build-with-claude#glossary
- The end state they're working toward: open Telegram on their phone, message a bot, watch their Mac build and deploy the app.

## What they need before starting

Confirm these out loud before any commands run. If any answer is no, pause and resolve before proceeding.

- A Mac that will stay on (Mac Mini is ideal; laptop fine if they keep it plugged in)
- Telegram installed on their phone
- A Claude.ai account on the Pro or Max plan ($20+/mo)
- Roughly 30 minutes of uninterrupted time the first time

## Step 1: Run the setup script

Have them open Terminal on their Mac (Cmd+Space, type "Terminal", press Enter). Then paste this single command:

```
bash <(curl -fsSL https://raw.githubusercontent.com/kevinmmiddleton/build-with-claude/main/setup.sh)
```

What the script does:
1. Installs Bun (the engine that runs Claude Code)
2. Installs Claude Code itself
3. Adds Terminal to their Dock
4. Adds helpful shortcuts (`start-claude`, `update-claude`)
5. Prevents the Mac from sleeping while plugged in
6. Sets Claude to auto-start with Telegram on login

If they see errors, the script logs them to `~/.claude/setup-errors.log`. Offer to look at the log together.

## Step 2: Sign in to Claude Code

After the script finishes, have them:

1. Close Terminal and open a **new** Terminal window (so the new shortcuts load)
2. Type `claude` and press Enter
3. Follow the prompts to sign in with their Claude.ai account
4. Once signed in, type `/quit` to exit

If they get "command not found: claude," tell them to open a fresh Terminal window. If still broken, have them run `export PATH="$HOME/.bun/bin:$PATH"`.

## Step 3: Create a Telegram bot

This is the part most users find magical. Walk them through it slowly.

1. Open **Telegram** on their phone.
2. Search for **@BotFather** (Telegram's official bot maker).
3. Tap the chat and send: `/newbot`
4. Choose any name (example: "My Claude Bot")
5. Choose a username that ends in "bot" (example: "kevinm_claude_bot")
6. BotFather replies with a **token** — a long random string. They should copy it.

Once they have the token, back to Terminal on their Mac:

```
claude
```

Inside Claude Code, type:

```
/telegram:configure
```

Paste the token when asked. Then:

```
/telegram:access
```

Follow the prompts to pair their Telegram account with their bot.

## Step 4: Start building

Inside Terminal, have them type:

```
start-claude
```

That starts Claude Code with Telegram listening. Now they go to Telegram on their phone, open their bot, and send a message like:

> "Create a new React app with Supabase auth. Deploy it to Vercel."

Their Mac's Terminal will show Claude working. The bot will reply with a live URL when the app is deployed.

Celebrate this moment. They just built an app from their phone.

## Common issues

- **Bot doesn't reply.** Is the Mac on and awake? Is `start-claude` running in Terminal? Did they finish `/telegram:access`?
- **"Command not found: claude"** — open a new Terminal window. If that fails, run `export PATH="$HOME/.bun/bin:$PATH"`.
- **"Command not found: bun"** — run `curl -fsSL https://bun.sh/install | bash`, then open a new Terminal.
- **They don't know what to build.** Suggest something small: a personal website, a to-do app, or a link saver. The point is to ship anything once.

## Accounts they'll need over time

For the first app, they need: Claude.ai, GitHub, Telegram, Supabase, Vercel. Everything else (Sentry, Stripe, Resend) is optional and can wait. The full README has API key instructions for each: https://github.com/kevinmmiddleton/build-with-claude#chapter-6-your-accounts-cheat-sheet

## A note on `--dangerously-skip-permissions`

If they ask why the setup uses this flag, the honest answer: when Claude is running with Telegram, the user isn't sitting at the keyboard to approve every file write or command. The flag lets Claude work autonomously. They're still in control — they can see everything happening in Terminal and stop it by closing the window or typing `/quit`. The name sounds scary but it just means "don't ask me to approve every single action."

## When they're done with the first app

Suggest next steps:
- Add a feature by messaging the bot ("add a dark mode toggle")
- Fix a bug by screenshotting it and sending to the bot
- Share the Vercel URL with friends — it works for anyone

The best way to learn is to keep building something they actually want. Encourage that.
