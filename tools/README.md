# Developer Tools

Narzędzia do monitorowania CI/CD i zarządzania projektem.

---

## 🔍 CI/CD Monitoring Tools

### `check-ci.sh` - Sprawdź status buildów

Sprawdza ostatnie buildy na GitHub Actions.

**Użycie:**
```bash
./tools/check-ci.sh              # Check main branch
./tools/check-ci.sh develop      # Check develop branch
```

**Output:**
```
🔍 GitHub Actions CI/CD Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: zentala/tmux-persistent-console
Branch: main

📊 Latest Workflow Runs:

✅ 🧪 Test Infrastructure
   Status: completed | Conclusion: success
   Date: 2025-10-07
   URL: https://github.com/zentala/tmux-persistent-console/actions/runs/...

🔄 🔒 Security Scan
   Status: in_progress | Conclusion: running
   Date: 2025-10-07
   URL: https://github.com/zentala/tmux-persistent-console/actions/runs/...

📝 Latest Commit Status:

Commit: 902d4f6
Message: feat(v3.0): Eliminate status bar flickering with static tmux formats

✅ All checks passed

🔗 Quick Links:
  • Actions: https://github.com/zentala/tmux-persistent-console/actions
  • Latest: https://github.com/zentala/tmux-persistent-console/actions/runs
  • Commit: https://github.com/zentala/tmux-persistent-console/commit/...
```

**Wymaga:**
- GitHub CLI: `sudo apt install gh` (Debian/Ubuntu) lub `brew install gh` (macOS)
- Autentykacja: `gh auth login`

---

### `watch-ci.sh` - Obserwuj buildy w czasie rzeczywistym

Automatycznie odświeża status co N sekund.

**Użycie:**
```bash
./tools/watch-ci.sh           # Refresh every 10 seconds
./tools/watch-ci.sh 5         # Refresh every 5 seconds
./tools/watch-ci.sh 30        # Refresh every 30 seconds
```

**Użyteczne gdy:**
- Czekasz na zakończenie builda
- Debugujesz problemy CI/CD
- Monitorujesz długie testy

**Wyjście:** Ctrl+C

---

### `push-and-watch.sh` - Push i automatyczne monitorowanie

Pushuje kod na GitHub i automatycznie monitoruje status builda.

**Użycie:**
```bash
./tools/push-and-watch.sh              # Push to main and watch
./tools/push-and-watch.sh develop      # Push to develop and watch
```

**Co robi:**
1. Sprawdza czy jesteś na właściwym branchu
2. Sprawdza uncommitted changes
3. Opcjonalnie commituje zmiany (jeśli zapytasz)
4. Pushuje na GitHub
5. Monitoruje CI/CD przez 2 minuty (12 × 10s)
6. Pokazuje link do kontynuacji

**Przykład:**
```bash
$ ./tools/push-and-watch.sh main

🚀 Push & Watch CI/CD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📤 Pushing to origin/main...
✅ Pushed successfully

🔄 Watching CI/CD status...

[Shows status every 10 seconds for 2 minutes]

✅ Monitoring complete

Continue watching with:
  ./tools/watch-ci.sh
```

---

## 📋 Workflow Descriptions

Twoje GitHub Actions workflows:

### 🧪 Test Infrastructure (`test-infrastructure.yml`)

**Trigger:**
- Push to `main` or `develop`
- Pull Request to `main`
- Manual dispatch (workflow_dispatch)

**Jobs:**

1. **Quick Validation** (zawsze)
   - Sprawdza składnię bash scripts
   - Waliduje tmux.conf
   - Sprawdza Terraform config

2. **Cloud Testing** (tylko main/PR/manual)
   - Deploy na Oracle Cloud Free Tier
   - Instaluje tmux-persistent-console
   - Uruchamia testy automatyczne
   - Cleanup (usuwa infrastrukturę)

3. **Security Scan**
   - Checkov (Terraform security)
   - TruffleHog (secret detection)

**Test types** (manual dispatch):
- `full` - Pełny test suite (default)
- `quick` - Tylko szybkie testy
- `stress` - 3 cykle testów

**Czas:** ~15-30 minut (z Oracle Cloud)

---

### 📦 Release (`release.yml`)

Automatyczne tworzenie release'ów przy tagowaniu.

**Trigger:**
- Push tagu: `v*` (np. `v3.0`, `v3.1-beta`)

**Co robi:**
- Tworzy GitHub Release
- Generuje changelog
- Dołącza pliki instalacyjne

---

### 🔍 PR Validation (`pr-validation.yml`)

Walidacja Pull Requestów.

**Trigger:**
- Otwarcie PR
- Update PR

**Co sprawdza:**
- Składnia kodu
- Testy jednostkowe
- Konflikt z main

---

### 🐳 Docker Test (`docker-test.yml`)

Testy w czystym środowisku Docker.

**Trigger:**
- Push do `src/`, `tests/`, `Dockerfile`
- Pull Request

**Co testuje:**
- Build obrazu Docker
- Instalacja w kontenerze
- Podstawowe funkcje tmux

---

## 🛠️ Installation & Setup

### 1. Zainstaluj GitHub CLI

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install gh
```

**macOS:**
```bash
brew install gh
```

**Inne:** https://cli.github.com/

### 2. Autentykacja

```bash
gh auth login
```

Wybierz:
- GitHub.com
- HTTPS lub SSH
- Login through web browser

### 3. Sprawdź instalację

```bash
gh auth status
```

Powinno pokazać:
```
✓ Logged in to github.com as zentala (...)
✓ Git operations for github.com configured to use ssh protocol.
✓ Token: *******************
```

### 4. Test

```bash
cd ~/.vps/sessions
./tools/check-ci.sh
```

---

## 💡 Tips & Tricks

### Szybkie sprawdzenie ostatniego builda

```bash
./tools/check-ci.sh | head -20
```

### Monitoring w osobnym terminalu

```bash
# Terminal 1: Work normally
vim src/tmux.conf

# Terminal 2: Watch CI
./tools/watch-ci.sh
```

### Push i idź spać 😴

```bash
./tools/push-and-watch.sh main

# Po 2 minutach monitoring się kończy
# Ale build dalej działa
# Rano sprawdź:
./tools/check-ci.sh
```

### Sprawdź konkretny commit

```bash
git log --oneline -5
# Copy commit hash

gh run list --commit <hash>
```

### Re-run failed build

```bash
# Get run ID from check-ci.sh output
gh run rerun <run-id>

# Watch it
./tools/watch-ci.sh
```

### Manual workflow trigger

```bash
# Trigger test-infrastructure with specific test type
gh workflow run test-infrastructure.yml \
  --ref main \
  -f test_type=stress \
  -f keep_infrastructure=false

# Watch it
./tools/watch-ci.sh
```

---

## 🐛 Troubleshooting

### "gh: command not found"

**Problem:** GitHub CLI nie jest zainstalowany.

**Solution:**
```bash
# Check if gh is installed
which gh

# If not, install:
sudo apt install gh     # Debian/Ubuntu
brew install gh         # macOS
```

### "gh auth status: authentication required"

**Problem:** Nie jesteś zalogowany.

**Solution:**
```bash
gh auth login
# Follow prompts
```

### "API rate limit exceeded"

**Problem:** Za dużo requestów do GitHub API.

**Solution:**
```bash
# Check rate limit
gh api rate_limit

# Wait or authenticate (increases limit)
gh auth login
```

### Build się nie uruchamia

**Problem:** Workflow może nie triggerować na twoim branchu.

**Solution:**
```bash
# Check workflow triggers
cat .github/workflows/test-infrastructure.yml | grep -A 5 "on:"

# Manual trigger if allowed
gh workflow run test-infrastructure.yml --ref your-branch
```

### Nie widzę buildów dla swojego commita

**Problem:** Commit może nie spełniać triggers (np. zmiana tylko w docs).

**Solution:**
```bash
# Check what paths trigger workflow
cat .github/workflows/test-infrastructure.yml | grep -A 10 "paths:"

# If you want to force run:
gh workflow run test-infrastructure.yml
```

---

## 📚 Related Documentation

- **GitHub Actions**: `.github/workflows/`
- **CI/CD Tests**: `tests/README.md`
- **Oracle Cloud Setup**: `tests/terraform/README.md`

---

## 🔗 Quick Links

- **GitHub Actions**: https://github.com/zentala/tmux-persistent-console/actions
- **GitHub CLI Docs**: https://cli.github.com/manual/
- **Workflow Syntax**: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions

---

**Created:** 2025-10-07
**For:** Developer convenience and CI/CD monitoring
