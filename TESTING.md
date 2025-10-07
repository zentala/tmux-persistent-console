# Testing Checklist - Persistent Console

## 🧪 Manual Testing Protocol

### Status Bar Tests

- [ ] **Single status bar** - tylko jedna linia na dole (nie podwójna)
- [ ] **All 7 consoles visible** - widać wszystkie konsole 1-7
- [ ] **Active session highlighted** - obecna sesja podświetlona (cyan + cień)
- [ ] **Icons correct**:
  - [ ]  dla aktywnej sesji (ma procesy)
  - [ ]  dla pustej sesji
  - [ ]  dla ikony terminala przy F1-F7
  - [ ] 󰒓 dla F11 Manager
  - [ ]  dla F12 Help
- [ ] **Header shows** - `🖥️ CONSOLE@hostname` (lub tylko 🖥️ na wąskim)
- [ ] **Responsive** - na wąskim ekranie (<120): tylko numery bez nazw

### Keyboard Shortcuts Tests

#### Direct Jump (F1-F7)
- [ ] F1 → switch to console-1
- [ ] F2 → switch to console-2
- [ ] F3 → switch to console-3
- [ ] F4 → switch to console-4
- [ ] F5 → switch to console-5
- [ ] F6 → switch to console-6
- [ ] F7 → switch to console-7

#### Navigation
- [ ] Ctrl+← → previous console
- [ ] Ctrl+→ → next console
- [ ] Ctrl+1-7 → jump to console (alternative)

#### Actions
- [ ] **Ctrl+H** → shortcuts popup appears
  - [ ] Popup shows correct shortcuts
  - [ ] Any key closes popup
  - [ ] Doesn't change session

- [ ] **Ctrl+R** → restart confirmation appears
  - [ ] Popup shows warning
  - [ ] "Yes, restart now" → restarts session
  - [ ] "No, cancel" → stays in session
  - [ ] Cannot restart "help" or "manager" sessions

- [ ] **Ctrl+F8** → detach safely
- [ ] **Ctrl+D** → disconnect (bash default)

#### Manager & Help
- [ ] **F11** → opens Manager window
  - [ ] Creates "manager" session if doesn't exist
  - [ ] Reuses existing "manager" session
  - [ ] Tab highlighted in status bar

- [ ] **F12** → opens Help window
  - [ ] Creates "help" session if doesn't exist
  - [ ] Reuses existing "help" session
  - [ ] Shows static help text (no prompt)
  - [ ] Tab highlighted in status bar

### Session Management Tests

- [ ] **New session created** on first access
- [ ] **Session persists** after detach
- [ ] **Session survives** SSH disconnect
- [ ] **Restart works** - kills old, creates new
- [ ] **No conflicts** between sessions
- [ ] **Lock files cleaned up** after restart

### Visual Tests

- [ ] **No double status bar**
- [ ] **Shadows visible** on active tab
- [ ] **Colors correct**:
  - Cyan (colour39) for active
  - Gray (colour244) for inactive
  - Dark gray (colour240) for empty
- [ ] **Icons render** (requires Nerd Fonts)
- [ ] **Text truncates** properly on narrow screen

### Edge Cases

- [ ] Restart from non-console session → shows error
- [ ] Restart already restarting session → waits
- [ ] Multiple rapid restarts → handled gracefully
- [ ] Very narrow terminal (<80 cols) → still readable
- [ ] Very wide terminal (>200 cols) → no overflow

---

## 🐳 Docker Test Environment

### Build Test Container

```bash
cd ~/.vps/sessions
docker build -t tmux-console-test -f Dockerfile.test .
```

### Run Tests

```bash
docker run -it --rm tmux-console-test
```

### Test Dockerfile

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    tmux \
    git \
    curl \
    wget \
    zsh \
    bash \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# Install gum
RUN wget -q https://github.com/charmbracelet/gum/releases/download/v0.14.5/gum_0.14.5_Linux_x86_64.tar.gz -O /tmp/gum.tar.gz \
    && tar -xzf /tmp/gum.tar.gz -C /tmp \
    && mv /tmp/gum_0.14.5_Linux_x86_64/gum /usr/local/bin/ \
    && rm -rf /tmp/gum*

# Copy console files
COPY . /root/.vps/sessions/

# Install
WORKDIR /root/.vps/sessions
RUN bash install.sh

# Set entrypoint
ENTRYPOINT ["tmux", "attach", "-t", "console-1"]
```

---

## 🔬 Automated Tests (Future)

### Using BATS (Bash Automated Testing System)

```bash
# Install bats
npm install -g bats

# Run tests
bats tests/
```

### Example Test: `tests/status-bar.bats`

```bats
#!/usr/bin/env bats

@test "status bar script exists" {
  [ -x ~/.vps/sessions/src/status-bar.sh ]
}

@test "status bar shows all 7 consoles" {
  result=$(bash ~/.vps/sessions/src/status-bar.sh "console-1" "150")
  [[ "$result" == *"F1"* ]]
  [[ "$result" == *"F7"* ]]
}

@test "status bar highlights current session" {
  result=$(bash ~/.vps/sessions/src/status-bar.sh "console-3" "150")
  [[ "$result" == *"colour39"* ]] # Cyan color for active
}

@test "status bar responsive on narrow screen" {
  result=$(bash ~/.vps/sessions/src/status-bar.sh "console-1" "80")
  [[ "$result" != *":main"* ]] # No names on narrow
}
```

### Example Test: `tests/restart.bats`

```bats
@test "restart script exists" {
  [ -x ~/.vps/sessions/src/restart-session.sh ]
}

@test "restart creates lock file" {
  bash ~/.vps/sessions/src/restart-session.sh "console-1" &
  sleep 0.2
  [ -f ~/.cache/tmux-console/restart-console-1.lock ]
}

@test "restart recreates session" {
  tmux new-session -d -s test-restart
  bash ~/.vps/sessions/src/restart-session.sh "test-restart"
  sleep 1
  tmux has-session -t test-restart
}
```

---

## ✅ Definition of Done

Feature is **DONE** when:

1. ✅ **Manual tests pass** - all items checked
2. ✅ **Docker test works** - runs in clean container
3. ✅ **No visual bugs** - single status bar, correct icons
4. ✅ **No errors** - tmux loads without errors
5. ✅ **Documented** - README updated
6. ✅ **Committed** - git history clean

---

## 📝 Test Log Template

```markdown
## Test Run: YYYY-MM-DD

**Tester:** [name]
**Environment:** [local/docker/vps]
**Tmux version:** [version]

### Results

- Status Bar: ✅ / ❌
- Keyboard Shortcuts: ✅ / ❌
- Session Management: ✅ / ❌
- Visual: ✅ / ❌
- Edge Cases: ✅ / ❌

### Issues Found

1. [Issue description]
2. [Issue description]

### Notes

[Any observations]
```

---

**Last Updated:** 2025-10-06
**Status:** Draft - needs implementation
