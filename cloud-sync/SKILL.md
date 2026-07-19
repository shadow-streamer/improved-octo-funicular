---
name: cloud-sync
description: Set up or check cloud sync for your project. Use when the user says "set up cloud sync", "sync my data", "cloud backup", "sync status", or wants their data backed up or synced to a cloud service.
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# Cloud Sync

Generic cloud sync setup and management. This skill provides a framework for implementing cloud synchronization for any project.

## When to Use

- Setting up cloud backup for project data
- Checking sync status
- Configuring cloud storage providers
- Managing sync credentials

## 1. Check Status

Check if cloud sync is configured:

```bash
# Check for common sync configuration files
ls -la ~/.config/*sync* 2>/dev/null || echo "No sync config found"
ls -la .env* 2>/dev/null || echo "No .env files found"

# Check for running sync processes
ps aux | grep -i sync | grep -v grep || echo "No sync processes running"
```

## 2. Configuration

### Option A: Environment Variables

Create a `.env` file with your cloud credentials:

```bash
# Example for various providers
CLOUD_PROVIDER="aws|gcp|azure|dropbox|google_drive"
CLOUD_ACCESS_KEY="your_access_key"
CLOUD_SECRET_KEY="your_secret_key"
CLOUD_BUCKET="your_bucket_name"
CLOUD_REGION="us-east-1"
```

### Option B: Config File

Create a `~/.config/project-sync/config.json`:

```json
{
  "provider": "aws",
  "credentials": {
    "access_key": "your_access_key",
    "secret_key": "your_secret_key"
  },
  "bucket": "your_bucket_name",
  "region": "us-east-1"
}
```

## 3. Security Best Practices

**NEVER commit credentials to git.** Use one of these methods:

1. **Environment variables** - Store in `.env` (add to `.gitignore`)
2. **Config files** - Store in `~/.config/` (outside project directory)
3. **Secret managers** - Use AWS Secrets Manager, HashiCorp Vault, etc.
4. **SSH keys** - For Git-based sync, use SSH keys instead of passwords

## 4. Implementation Patterns

### Git-based Sync

```bash
# Initialize git if not already done
git init
git remote add origin git@github.com:user/repo.git

# Simple sync workflow
git add .
git commit -m "Sync: $(date +%Y-%m-%d_%H-%M-%S)"
git push origin main
```

### Rclone (Multi-cloud)

```bash
# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Configure remote
rclone config

# Sync files
rclone sync ./data remote:bucket/data
```

### AWS S3

```bash
# Configure AWS CLI
aws configure

# Sync files
aws s3 sync ./data s3://your-bucket/data
```

## 5. Automation

### Cron Job (Linux/Mac)

```bash
# Edit crontab
crontab -e

# Add sync every hour
0 * * * * /path/to/sync-script.sh
```

### Systemd Timer (Linux)

```ini
# /etc/systemd/system/project-sync.timer
[Unit]
Description=Project Sync Timer

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
```

## 6. Monitoring

```bash
# Check sync status
ls -la /path/to/synced/data

# Check logs
tail -f /var/log/sync.log

# Check disk usage
df -h
```

## 7. Troubleshooting

### Common Issues

1. **Permission denied** - Check file permissions and credentials
2. **Connection timeout** - Check network connectivity
3. **Disk space** - Ensure sufficient local storage
4. **Conflict resolution** - Implement merge strategy for concurrent edits

### Debug Mode

```bash
# Enable verbose logging
export SYNC_DEBUG=true

# Run sync with verbose output
./sync-script.sh --verbose
```

## See Also

- `learn-codebase` - Understand project structure before syncing
- `make-plan` - Plan sync implementation
