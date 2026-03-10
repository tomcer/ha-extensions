#!/bin/bash
# =============================================================================
# Acond TČ - Web Poller (jedno TCP spojení pro všechny web hodnoty)
#
# Přihlásí se jednou k Tecomat Foxtrot, přečte všechny potřebné stránky,
# uloží výsledek do JSON souboru. HA senzory čtou z tohoto souboru.
#
# Použití: acond_web_poller.sh
# Výstup:  /tmp/acond_web_state.json
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/acond_config.sh"
OUTPUT_FILE="/tmp/acond_web_state.json"
COOKIE_FILE="/tmp/acond_poller_cookies.txt"

if [ ! -f "$CONFIG_FILE" ]; then
  echo '{"error":"config_missing"}' > "$OUTPUT_FILE"
  exit 1
fi

source "$CONFIG_FILE"

# Cleanup
rm -f "$COOKIE_FILE"

# --- 1. Login (jedno spojení) ---
curl -s --max-time 5 -L -c "$COOKIE_FILE" \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

curl -s --max-time 5 -b "$COOKIE_FILE" -c "$COOKIE_FILE" \
  -d "USER=${ACOND_USERNAME}&PASS=${ACOND_PASSWORD}" \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

# --- 2. Čtení PAGE49 (hlavní stav - HDO, topení, TUV plány) ---
PAGE49=$(curl -s --max-time 5 -b "$COOKIE_FILE" \
  -H "x-tecomat: data" \
  "http://${ACOND_HOST}/PAGE49.XML")

# --- 3. Čtení PAGE51 (TUV časové plány) ---
PAGE51=$(curl -s --max-time 5 -b "$COOKIE_FILE" \
  -H "x-tecomat: data" \
  "http://${ACOND_HOST}/PAGE51.XML")

# Cleanup session
rm -f "$COOKIE_FILE"

# --- 4. Parsování hodnot ---
extract_val() {
  echo "$1" | sed -n "s/.*${2}\" VALUE=\"\([^\"]*\)\".*/\1/p" | head -1
}

# HDO blokace - X160.1 (nový FW, dříve X12.1)
HDO_RAW=$(extract_val "$PAGE49" "__X160.1_BOOL_i")

# TUV plán - R805.4
TUV_PLAN_RAW=$(extract_val "$PAGE49" "__R805.4_BOOL_i")

# TUV ohřev zapnut - R805.3
TUV_HEAT_RAW=$(extract_val "$PAGE49" "__R805.3_BOOL_i")

# Topení plán - R805.2
HEAT_PLAN_RAW=$(extract_val "$PAGE49" "__R805.2_BOOL_i")

# Noční útlum - R805.1
NIGHT_SETBACK_RAW=$(extract_val "$PAGE49" "__R805.1_BOOL_i")

# Teplota výstupní (R1808) - pro kontrolu
TEMP_OUTPUT=$(extract_val "$PAGE49" "__R1808_REAL_.1f")

# Noční útlum časy
NIGHT_FROM=$(extract_val "$PAGE49" "__R862_TIME_Thh:mm")
NIGHT_TO=$(extract_val "$PAGE49" "__R866_TIME_Thh:mm")

# Timestamp
TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

# --- 5. Zápis JSON ---
cat > "$OUTPUT_FILE" << ENDJSON
{
  "timestamp": "${TIMESTAMP}",
  "hdo_block": ${HDO_RAW:-null},
  "tuv_schedule": ${TUV_PLAN_RAW:-null},
  "tuv_heating_enabled": ${TUV_HEAT_RAW:-null},
  "heating_schedule": ${HEAT_PLAN_RAW:-null},
  "night_setback": ${NIGHT_SETBACK_RAW:-null},
  "temp_output": ${TEMP_OUTPUT:-null},
  "night_from": "${NIGHT_FROM:-}",
  "night_to": "${NIGHT_TO:-}"
}
ENDJSON
