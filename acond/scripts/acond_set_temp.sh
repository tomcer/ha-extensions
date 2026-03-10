#!/bin/bash
# =============================================================================
# Acond TČ - Nastavení teploty přes HTTP POST
# Použití: acond_set_temp.sh room <teplota>
#          acond_set_temp.sh dhw <teplota>
# Volá se z HA shell_command s pevným argumentem typu,
# teplota se čte z HA REST API (localhost).
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/acond_config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  exit 1
fi

source "$CONFIG_FILE"

TYPE="$1"

# Přečti aktuální hodnotu z HA (běží na localhostu)
HA_TOKEN_FILE="/config/.storage/acond_ha_token"
if [ -f "$HA_TOKEN_FILE" ]; then
  HA_TOKEN=$(cat "$HA_TOKEN_FILE")
fi

case "$TYPE" in
  room)
    PAGE="PAGE49.XML"
    REG="__R190_REAL_.1f"
    ENTITY="input_number.acond_room_temp_target"
    ;;
  dhw)
    PAGE="PAGE49.XML"
    REG="__R815_REAL_.1f"
    ENTITY="input_number.acond_dhw_temp_target"
    ;;
  *)
    exit 1
    ;;
esac

# Přečti aktuální teplotu z HA (homeassistant = docker hostname v HA OS)
TEMP=$(curl -s --max-time 3 \
  -H "Authorization: Bearer ${HA_TOKEN}" \
  "http://homeassistant:8123/api/states/${ENTITY}" | \
  sed -n 's/.*"state":"\([^"]*\)".*/\1/p')

if [ -z "$TEMP" ] || [ "$TEMP" = "unknown" ] || [ "$TEMP" = "unavailable" ]; then
  exit 1
fi

# Login k TČ
rm -f /tmp/acond_settemp_cookies.txt
curl -s --max-time 5 -L -c /tmp/acond_settemp_cookies.txt \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

curl -s --max-time 5 -b /tmp/acond_settemp_cookies.txt -c /tmp/acond_settemp_cookies.txt \
  -d "USER=${ACOND_USERNAME}&PASS=${ACOND_PASSWORD}" \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

# POST teplotu
curl -s --max-time 5 -b /tmp/acond_settemp_cookies.txt \
  -d "${REG}=${TEMP}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  "http://${ACOND_HOST}/${PAGE}" > /dev/null

rm -f /tmp/acond_settemp_cookies.txt
