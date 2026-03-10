#!/bin/bash
# =============================================================================
# Acond TČ - Deploy to Home Assistant via SSH
# Usage: ./deploy.sh [ha_host]
# Default host: homeassistant.local
# =============================================================================

set -e

HA_HOST="${1:-homeassistant.local}"
HA_CONFIG="/config"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Deploying Acond TČ to ${HA_HOST} ==="

# Check SSH connectivity
if ! ssh -o ConnectTimeout=3 root@${HA_HOST} "echo ok" > /dev/null 2>&1; then
  echo "ERROR: Cannot connect to root@${HA_HOST}" >&2
  exit 1
fi

# Deploy YAML configs
echo "Copying YAML configs..."
scp -q \
  "${SCRIPT_DIR}/modbus_acond.yaml" \
  "${SCRIPT_DIR}/template_sensors_acond.yaml" \
  "${SCRIPT_DIR}/shell_command_acond.yaml" \
  "${SCRIPT_DIR}/command_line_acond.yaml" \
  "${SCRIPT_DIR}/automation_acond.yaml" \
  "${SCRIPT_DIR}/input_number_acond.yaml" \
  "${SCRIPT_DIR}/input_boolean_acond.yaml" \
  "${SCRIPT_DIR}/input_button_acond.yaml" \
  root@${HA_HOST}:${HA_CONFIG}/

# Deploy scripts
echo "Copying scripts..."
ssh root@${HA_HOST} "mkdir -p ${HA_CONFIG}/scripts"
scp -q \
  "${SCRIPT_DIR}/scripts/acond_write.sh" \
  "${SCRIPT_DIR}/scripts/acond_read.sh" \
  "${SCRIPT_DIR}/scripts/acond_web_poller.sh" \
  root@${HA_HOST}:${HA_CONFIG}/scripts/
ssh root@${HA_HOST} "chmod +x ${HA_CONFIG}/scripts/acond_write.sh ${HA_CONFIG}/scripts/acond_read.sh ${HA_CONFIG}/scripts/acond_web_poller.sh"

# Check if config file exists on HA, warn if not
if ! ssh root@${HA_HOST} "test -f ${HA_CONFIG}/scripts/acond_config.sh"; then
  echo ""
  echo "WARNING: ${HA_CONFIG}/scripts/acond_config.sh not found on HA!"
  echo "Create it from the example:"
  echo "  ssh root@${HA_HOST} 'cat > ${HA_CONFIG}/scripts/acond_config.sh << EOF"
  echo "ACOND_HOST=\"192.168.5.30\""
  echo "ACOND_USERNAME=\"acond\""
  echo "ACOND_PASSWORD=\"acond\""
  echo "EOF'"
fi

# Check if secrets contain acond_host
if ! ssh root@${HA_HOST} "grep -q acond_host ${HA_CONFIG}/secrets.yaml 2>/dev/null"; then
  echo ""
  echo "WARNING: acond_host not found in secrets.yaml!"
  echo "Add it: ssh root@${HA_HOST} 'echo \"acond_host: \\\"192.168.5.30\\\"\" >> ${HA_CONFIG}/secrets.yaml'"
fi

# Validate configuration
echo "Validating HA configuration..."
if ssh root@${HA_HOST} "ha core check" 2>&1 | grep -q "completed successfully"; then
  echo "Configuration valid!"
  echo ""
  read -p "Restart Home Assistant? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    ssh root@${HA_HOST} "ha core restart"
    echo "Home Assistant is restarting..."
  fi
else
  echo "WARNING: Configuration check had issues. Check logs on HA."
  ssh root@${HA_HOST} "ha core check" 2>&1
fi

echo ""
echo "=== Deploy complete ==="
