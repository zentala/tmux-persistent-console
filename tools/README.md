# Developer Tools

CI/CD monitoring and project management tools.

---

## 🔍 CI/CD Monitoring Tools

### `check-ci.sh` - Check build status

Checks recent builds on GitHub Actions.

**Usage:**
```bash
./tools/check-ci.sh              # Check main branch
./tools/check-ci.sh develop      # Check develop branch
```

**Output:**
```
🔍 GitHub Actions CI/CD Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: zentala/pTTY
Branch: main

📊 Latest Workflow Runs:

✅ 🧪 Test Infrastructure
   Status: completed | Conclusion: success
   Date: 2025-10-07
   URL: https://github.com/zentala/pTTY/actions/runs/...

🔄 🔒 Security Scan
   Status: in_progress | Conclusion: running
   Date: 2025-10-07
   URL: https://github.com/zentala/pTTY/actions/runs/...

📝 Latest Commit Status:

Commit: 902d4f6
Message: feat(v3.0): Eliminate status bar flickering with static tmux formats

✅ All checks passed

🔗 Quick Links:
  • Actions: https://github.com/zentala/pTTY/actions
  • Latest: https://github.com/zentala/pTTY/actions/runs
  • Commit: https://github.com/zentala/pTTY/commit/...
```

**Requires:**
- GitHub CLI: `sudo apt install gh` (Debian/Ubuntu) or `brew install gh` (macOS)
- Authentication: `gh auth login`

---

### `watch-ci.sh` - Watch builds in real time

Refreshes status automatically every N seconds.

**Usage:**
```bash
./tools/watch-ci.sh           # Refresh every 10 seconds
./tools/watch-ci.sh 5         # Refresh every 5 seconds
./tools/watch-ci.sh 30        # Refresh every 30 seconds
```

**Useful when:**
- Waiting for a build to finish
- Debugging CI/CD issues
- Watching long-running tests

**Exit:** Ctrl+C

---

### `push-and-watch.sh` - Push and auto-monitor

Pushes to GitHub and automatically watches the build status.

**Usage:**
```bash
./tools/push-and-watch.sh              # Push to main and watch
./tools/push-and-watch.sh develop      # Push to develop and watch
```

**What it does:**
1. Checks you're on the right branch
2. Checks for uncommitted changes
3. Optionally commits changes (asks first)
4. Pushes to GitHub
5. Watches CI/CD for 2 minutes (12 × 10s)
6. Prints a link to keep watching

**Example:**
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

The repo's GitHub Actions workflows:

### 🧪 Test Infrastructure (`test-infrastructure.yml`)

**Trigger:**
- Push to `main` or `develop`
- Pull Request to `main`
- Manual dispatch (workflow_dispatch)

**Jobs:**

1. **Quick Validation** (always)
   - Checks bash script syntax
   - Validates tmux.conf
   - Checks Terraform config

2. **Cloud Testing** (main/PR/manual only)
   - Deploys to Oracle Cloud Free Tier
   - Installs pTTY
   - Runs the automated test suite
   - Cleanup (tears down the infrastructure)

3. **Security Scan**
   - Checkov (Terraform security)
   - TruffleHog (secret detection)

**Test types** (manual dispatch):
- `full` - Full test suite (default)
- `quick` - Fast tests only
- `stress` - 3 test cycles

**Duration:** ~15-30 minutes (with Oracle Cloud)

---

### 📦 Release (`release.yml`)

Creates a release automatically when a tag is pushed.

**Trigger:**
- Tag push: `v*` (e.g. `v3.0`, `v3.1-beta`)

**What it does:**
- Creates a GitHub Release
- Generates a changelog
- Attaches install files

---

### 🔍 PR Validation (`pr-validation.yml`)

Validates pull requests.

**Trigger:**
- PR opened
- PR updated

**What it checks:**
- Code syntax
- Unit tests
- Conflicts with main

---

### 🐳 Docker Test (`docker-test.yml`)

Tests in a clean Docker environment.

**Trigger:**
- Push to `src/`, `tests/`, `Dockerfile`
- Pull Request

**What it tests:**
- Docker image build
- Install inside the container
- Basic tmux functionality

---

## 🛠️ Installation & Setup

### 1. Install GitHub CLI

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install gh
```

**macOS:**
```bash
brew install gh
```

**Other:** https://cli.github.com/

### 2. Authenticate

```bash
gh auth login
```

Choose:
- GitHub.com
- HTTPS or SSH
- Login through web browser

### 3. Verify the install

```bash
gh auth status
```

Should show:
```
✓ Logged in to github.com as zentala (...)
✓ Git operations for github.com configured to use ssh protocol.
✓ Token: *******************
```

### 4. Test it

```bash
cd ~/.vps/sessions
./tools/check-ci.sh
```

---

## 💡 Tips & Tricks

### Quick check of the last build

```bash
./tools/check-ci.sh | head -20
```

### Monitoring in a separate terminal

```bash
# Terminal 1: Work normally
vim src/tmux.conf

# Terminal 2: Watch CI
./tools/watch-ci.sh
```

### Push and walk away

```bash
./tools/push-and-watch.sh main

# Monitoring stops after 2 minutes
# but the build keeps running
# check back later:
./tools/check-ci.sh
```

### Check a specific commit

```bash
git log --oneline -5
# Copy commit hash

gh run list --commit <hash>
```

### Re-run a failed build

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

**Problem:** GitHub CLI is not installed.

**Solution:**
```bash
# Check if gh is installed
which gh

# If not, install:
sudo apt install gh     # Debian/Ubuntu
brew install gh         # macOS
```

### "gh auth status: authentication required"

**Problem:** Not logged in.

**Solution:**
```bash
gh auth login
# Follow prompts
```

### "API rate limit exceeded"

**Problem:** Too many requests to the GitHub API.

**Solution:**
```bash
# Check rate limit
gh api rate_limit

# Wait or authenticate (increases limit)
gh auth login
```

### Build doesn't start

**Problem:** The workflow may not trigger on your branch.

**Solution:**
```bash
# Check workflow triggers
cat .github/workflows/test-infrastructure.yml | grep -A 5 "on:"

# Manual trigger if allowed
gh workflow run test-infrastructure.yml --ref your-branch
```

### No builds show up for your commit

**Problem:** The commit may not match the trigger paths (e.g. docs-only change).

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

- **GitHub Actions**: https://github.com/zentala/pTTY/actions
- **GitHub CLI Docs**: https://cli.github.com/manual/
- **Workflow Syntax**: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions

---

**Created:** 2025-10-07
**For:** Developer convenience and CI/CD monitoring
