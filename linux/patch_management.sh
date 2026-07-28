#!/usr/bin/env bash
# linux/patch_management.sh
# Sample patch management automation for RHEL/CentOS fleets: checks for
# available updates, applies them in a maintenance window, and logs results.

set -euo pipefail

LOG_DIR="/var/log/patch-mgmt"
LOG_FILE="${LOG_DIR}/patch_$(date +%Y%m%d_%H%M%S).log"
DRY_RUN="${1:-false}"

mkdir -p "${LOG_DIR}"

echo "=== Patch Management Run: $(date) ===" | tee -a "${LOG_FILE}"

echo "Checking for available updates..." | tee -a "${LOG_FILE}"
AVAILABLE_UPDATES=$(yum check-update --quiet | wc -l || true)
echo "Available updates: ${AVAILABLE_UPDATES}" | tee -a "${LOG_FILE}"

if [ "${AVAILABLE_UPDATES}" -eq 0 ]; then
  echo "System is already up to date." | tee -a "${LOG_FILE}"
  exit 0
fi

if [ "${DRY_RUN}" == "true" ]; then
  echo "Dry run mode - listing updates without applying:" | tee -a "${LOG_FILE}"
  yum check-update | tee -a "${LOG_FILE}"
  exit 0
fi

echo "Applying security updates..." | tee -a "${LOG_FILE}"
yum update -y --security 2>&1 | tee -a "${LOG_FILE}"

if [ -f /var/run/reboot-required ]; then
  echo "Reboot required after patching." | tee -a "${LOG_FILE}"
fi

echo "Patch run complete. Log: ${LOG_FILE}"

