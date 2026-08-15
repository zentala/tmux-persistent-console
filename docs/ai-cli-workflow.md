**Purpose:** Worked examples of using pTTY with AI coding CLIs over a single SSH connection.

# AI CLI Workflow Examples

## Claude Code Remote Development

You SSH in **once** — `ssh tmux.example.com` — and then use `Ctrl+F1`-`Ctrl+F10` to flip between consoles inside that single tmux session. No second SSH, no second terminal window required.

```text
ssh tmux.example.com         # one connection — lands you in console-1

# Inside tmux, set each console up once:
#   Ctrl+F1 → console-1 → run: claude-code
#   Ctrl+F2 → console-2 → run: tail -f logs/app.log
#   Ctrl+F3 → console-3 → run: git status

# Then just press Ctrl+F1 / F2 / F3 to switch between them instantly.
# WiFi dies? Run `ssh tmux.example.com` again — everything is still there.
```

## GitHub Copilot CLI Workflow

Same pattern — one SSH connection, multiple consoles via F-keys:

```text
ssh tmux.example.com

# Ctrl+F1 → Copilot chat:  gh copilot explain "complex function"
# Ctrl+F2 → Testing:       npm test --watch
# Ctrl+F3 → Git/deploy:    git status && git push

# All three consoles stay alive on the server. Disconnect any time;
# reconnect with `ssh tmux.example.com` and pick up exactly where you left off.
```

> 💡 **Why one SSH, not three?** tmux multiplexes inside the single SSH connection — one TCP socket carries all 10 consoles. Opening three SSH sessions just to switch between three consoles wastes connections and forces you to track three separate terminal windows. The whole point of pTTY is: *one connection, many consoles, F-keys to flip between them*.
