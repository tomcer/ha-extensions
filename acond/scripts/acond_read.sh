#!/bin/bash
# =============================================================================
# Acond TČ - wrapper pro HTTP čtení dat z Tecomat Foxtrot
# Použití: acond_read.sh <page> <sed_pattern>
# Příklad: acond_read.sh PAGE49.XML 's/.*R6513_STRING\[80\]_s" VALUE="\([^"]*\)".*/\1/p'
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/acond_config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

source "$CONFIG_FILE"

PAGE="$1"
SED_PATTERN="$2"

if [ -z "$PAGE" ]; then
  echo "Usage: $0 <page> [sed_pattern]" >&2
  exit 1
fi

# Login
curl -s --max-time 5 -c /tmp/acond_cookies.txt \
  -d "USERNAME=${ACOND_USERNAME}&PASSWORD=${ACOND_PASSWORD}&SUBMIT=Login" \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

# Read with optional sed filter
if [ -n "$SED_PATTERN" ]; then
  curl -s --max-time 5 -b /tmp/acond_cookies.txt \
    -H "x-tecomat: data" \
    "http://${ACOND_HOST}/${PAGE}" | sed -n "$SED_PATTERN"
else
  curl -s --max-time 5 -b /tmp/acond_cookies.txt \
    -H "x-tecomat: data" \
    "http://${ACOND_HOST}/${PAGE}"
fi
