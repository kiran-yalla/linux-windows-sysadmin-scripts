# linux-windows-sysadmin-scripts

Cross-platform Bash and PowerShell automation scripts for system administration: patching, log rotation, and user/security administration.

## What this demonstrates

- 🩹 **Patch management** — `linux/patch_management.sh` checks for and applies security updates on RHEL/CentOS systems, with a dry-run mode and logging.
- 🗂️ **Log rotation** — `linux/log_rotation.py` compresses aging log files and prunes old archives past a retention period, for apps that don't rely on `logrotate` directly.
- 🔐 **Windows security audit** — `windows/user_security_audit.ps1` audits local and domain accounts for stale logins, non-expiring passwords, and privileged group membership.

## Structure

```
.
├── linux/
│   ├── patch_management.sh   # Security patch check + apply automation
│   └── log_rotation.py        # Log compression and retention cleanup
└── windows/
    └── user_security_audit.ps1  # Local/domain account security hygiene audit
```

## Usage

```bash
# Linux
./linux/patch_management.sh true          # dry run
./linux/patch_management.sh false         # apply updates
python linux/log_rotation.py /var/log/myapp --compress-days 1 --delete-days 30
```

```powershell
# Windows
.\windows\user_security_audit.ps1 -InactiveDays 90
```

> This is a portfolio/demonstration repository illustrating common cross-platform sysadmin automation patterns. Review and adapt paths, package managers, and thresholds to your actual environment before real-world use.

## Author

Kiran Yalla — Senior Platform Engineer supporting 700+ servers across Linux and Windows, with hands-on experience in security engineering, patch management, and system hardening.
