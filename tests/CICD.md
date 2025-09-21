# 🚀 CI/CD GitOps Configuration

> Automated testing infrastructure with GitHub Actions and Oracle Cloud

## 🎯 Overview

This configuration enables **automated testing on every git push** using GitHub Actions and Oracle Cloud Free Tier. Tests run automatically in the cloud, providing immediate feedback on code changes.

## ⚡ Quick Setup

### 1. Configure GitHub Secrets

Go to your GitHub repository: **Settings → Secrets and variables → Actions**

Add these **Repository Secrets**:

#### Oracle Cloud Credentials
```bash
OCI_TENANCY_OCID      # Your tenancy OCID from OCI console
OCI_USER_OCID         # Your user OCID
OCI_FINGERPRINT       # Your API key fingerprint
OCI_PRIVATE_KEY       # Your OCI API private key (full PEM content)
OCI_REGION           # Your preferred region (e.g., us-ashburn-1)
OCI_COMPARTMENT_OCID  # Compartment OCID (usually same as tenancy)
```

#### SSH Keys for Server Access
```bash
SSH_PRIVATE_KEY       # SSH private key content
SSH_PUBLIC_KEY        # SSH public key content
```

### 2. Enable Workflow

The workflow is located at `.github/workflows/test-infrastructure.yml` and runs automatically on:

- ✅ **Push to main branch** (when code changes)
- ✅ **Pull requests to main** (for validation)
- ✅ **Manual trigger** (workflow_dispatch)
- ✅ **Label-triggered PRs** (add `test-cloud` label)

## 🔧 How to Get Oracle Cloud Credentials

### Step 1: Create Oracle Cloud Account
1. Go to https://www.oracle.com/cloud/free/
2. Sign up for Free Tier account
3. Complete verification process

### Step 2: Generate API Key
1. **Login to OCI Console**
2. **User Profile** (top right) → **User Settings**
3. **API Keys** → **Add API Key**
4. **Download Private Key** and **Copy Public Key**
5. **Save the fingerprint** displayed

### Step 3: Get OCIDs
```bash
# From OCI Console:
# Tenancy OCID: Administration → Tenancy Details
# User OCID: Identity → Users → Your User
# Compartment OCID: Identity → Compartments (usually same as Tenancy)
```

### Step 4: Format for GitHub Secrets

#### OCI_PRIVATE_KEY Format
```
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...
(rest of your private key content)
-----END PRIVATE KEY-----
```

#### SSH Key Generation
```bash
# Generate SSH key pair for server access
ssh-keygen -t ed25519 -f ~/.ssh/tmux_test_key -N ""

# Private key content (for SSH_PRIVATE_KEY secret)
cat ~/.ssh/tmux_test_key

# Public key content (for SSH_PUBLIC_KEY secret)
cat ~/.ssh/tmux_test_key.pub
```

## 🔄 CI/CD Workflow Details

### Workflow Triggers

| Trigger | When | Purpose |
|---------|------|---------|
| **Push to main** | Code changes merged | Full validation |
| **Pull Request** | PR opened/updated | Prevent broken code |
| **Manual Dispatch** | On-demand testing | Debug/validate |
| **Label: test-cloud** | PR labeled | Force cloud testing |

### Test Types

#### 1. 🚀 Quick Validation (Always Runs)
- ✅ Syntax validation of all scripts
- ✅ Tmux configuration testing
- ✅ Terraform configuration validation
- ⏱️ **Duration**: ~2 minutes
- 💰 **Cost**: Free (GitHub runners)

#### 2. ☁️ Cloud Infrastructure Testing (Conditional)
- ✅ Full Oracle Cloud deployment
- ✅ Real server testing with Ubuntu 24.04
- ✅ Complete tmux-persistent-console validation
- ✅ Session switching and persistence tests
- ⏱️ **Duration**: ~15-20 minutes
- 💰 **Cost**: Free (Oracle Free Tier)

#### 3. 🔒 Security Scanning (Always Runs)
- ✅ Terraform security scan (Checkov)
- ✅ Secret detection (TruffleHog)
- ✅ Infrastructure compliance check
- ⏱️ **Duration**: ~3 minutes
- 💰 **Cost**: Free

### Manual Test Options

You can manually trigger tests with options:

#### Test Types
- **`full`** (default): Complete test suite
- **`quick`**: Fast validation only
- **`stress`**: Multiple test cycles for stability

#### Infrastructure Management
- **Keep Infrastructure**: Check this to keep server running for debugging
- **Auto-cleanup** (default): Automatically destroy resources after tests

## 📊 Workflow Outputs

### GitHub Actions Summary
Each run provides detailed summary:

```
🧪 Test Infrastructure Report

- Instance: tmux-console-ci-42
- Public IP: 203.0.113.100
- Test Type: full
- Trigger: push

✅ Status: All Tests Passed
```

### Test Results
```bash
✅ Test 1: Tmux installation - PASSED
✅ Test 2: Console sessions created - PASSED
✅ Test 3: All 7 console sessions exist - PASSED
✅ Test 4: Connect script availability - PASSED
✅ Test 5: Setup script availability - PASSED
✅ Test 6: Tmux configuration (mouse support) - PASSED
✅ Test 7: Function key bindings (Ctrl+F1) - PASSED
✅ Test 8: Session switching functionality - PASSED
✅ Test 9: Session persistence - PASSED
✅ Test 10: Custom test script execution - PASSED

📊 Test Results Summary: 10/10 PASSED 🎉
```

## 🔧 Advanced Configuration

### Customize Test Triggers

Edit `.github/workflows/test-infrastructure.yml`:

```yaml
# Run tests only on specific paths
on:
  push:
    paths:
      - 'src/**'           # Source code changes
      - 'install.sh'       # Installer changes
      - 'tests/**'         # Test changes
      - '.github/**'       # Workflow changes
```

### Add Custom Test Scenarios

```yaml
# Add custom test job
custom-testing:
  name: 🎯 Custom Tests
  runs-on: ubuntu-latest
  needs: cloud-testing
  steps:
    - name: 🧪 Run custom scenarios
      run: |
        # Your custom test commands
        ssh ubuntu@${{ needs.cloud-testing.outputs.public_ip }} "
          # Custom test scenario
          ./my-custom-test.sh
        "
```

### Environment-Specific Testing

```yaml
strategy:
  matrix:
    region:
      - us-ashburn-1
      - eu-frankfurt-1
      - ap-tokyo-1
    test_scenario:
      - basic
      - stress
      - performance
```

## 🚨 Troubleshooting CI/CD

### Common Issues

#### 1. "Authentication failed" Error
**Cause**: Incorrect OCI credentials
**Solution**:
```bash
# Verify your OCI credentials locally first
oci iam user get --user-id $OCI_USER_OCID

# Check fingerprint matches
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c
```

#### 2. "No capacity" Error
**Cause**: Oracle Cloud region has no available ARM instances
**Solution**: Add fallback regions in workflow:
```yaml
strategy:
  matrix:
    region:
      - us-ashburn-1    # Primary
      - us-phoenix-1    # Fallback
      - eu-frankfurt-1  # Fallback
```

#### 3. "SSH connection failed"
**Cause**: Incorrect SSH keys or network issues
**Solution**:
```bash
# Test SSH key locally
ssh-keygen -y -f private_key_file

# Verify public key format
cat public_key_file
# Should start with: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...
```

#### 4. Tests timeout
**Cause**: Cloud-init taking too long
**Solution**: Increase timeout in workflow:
```yaml
- name: ⏳ Wait for server initialization
  timeout-minutes: 15  # Increase from default
```

### Debugging Failed Runs

#### 1. Keep Infrastructure for Investigation
- ✅ Check "Keep infrastructure" when manually triggering
- 🔍 SSH to server: `ssh ubuntu@IP_FROM_LOGS`
- 🕵️ Check cloud-init: `sudo cloud-init status --long`

#### 2. Enable Debug Logging
Add to workflow:
```yaml
env:
  TF_LOG: DEBUG
  ACTIONS_STEP_DEBUG: true
```

#### 3. Manual Cleanup
If workflow fails to cleanup:
```bash
# Login to OCI console
# Compute → Instances → Terminate instance
# Or use OCI CLI:
oci compute instance terminate --instance-id <INSTANCE_OCID>
```

## 🔐 Security Best Practices

### Secret Management
- ✅ **Never commit credentials** to repository
- ✅ **Use GitHub Secrets** for all sensitive data
- ✅ **Rotate keys regularly** (every 90 days)
- ✅ **Limit secret access** to necessary repositories

### Infrastructure Security
- ✅ **Automatic cleanup** prevents resource sprawl
- ✅ **Security scanning** catches misconfigurations
- ✅ **Time-limited access** with automatic destruction
- ✅ **Audit logs** track all deployments

### Network Security
```yaml
# Restrict SSH access to GitHub Actions IP ranges
resource "oci_core_network_security_group_security_rule" "ssh_github" {
  source = "192.30.252.0/22"  # GitHub Actions IP range
  # Add other GitHub IP ranges as needed
}
```

## 📈 Monitoring and Metrics

### GitHub Actions Metrics
- ✅ **Success rate** tracking
- ✅ **Duration trends** monitoring
- ✅ **Cost tracking** (Oracle Free Tier usage)
- ✅ **Failure notifications**

### Custom Monitoring
Add monitoring to workflow:
```yaml
- name: 📊 Send metrics
  if: always()
  run: |
    # Send metrics to your monitoring system
    curl -X POST "$METRICS_ENDPOINT" \
      -H "Content-Type: application/json" \
      -d '{
        "test_result": "${{ job.status }}",
        "duration": "${{ job.duration }}",
        "instance_type": "ARM",
        "region": "${{ secrets.OCI_REGION }}"
      }'
```

## 🎯 Best Practices

### Development Workflow
1. **Feature branches**: Work on feature branches
2. **Draft PRs**: Use draft PRs to avoid triggering expensive tests
3. **Label control**: Use `test-cloud` label for PR cloud testing
4. **Local testing**: Test locally before pushing

### Resource Management
1. **Auto-cleanup**: Always enable automatic cleanup
2. **Timeout limits**: Set reasonable timeouts (30 min max)
3. **Parallel limits**: Limit concurrent workflows
4. **Region rotation**: Use multiple regions for reliability

### Cost Optimization
1. **Free Tier monitoring**: Track Oracle Free Tier usage
2. **Selective triggers**: Only run cloud tests when needed
3. **Quick validation**: Fast local tests catch basic issues
4. **Cleanup verification**: Ensure resources are destroyed

---

**🎉 Your tmux-persistent-console now has professional CI/CD with automated testing on every commit!**