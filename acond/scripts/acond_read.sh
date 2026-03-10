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

# Login (get fresh cookie, then POST credentials with new FW field names)
rm -f /tmp/acond_read_cookies.txt
curl -s --max-time 5 -L -c /tmp/acond_read_cookies.txt \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

curl -s --max-time 5 -b /tmp/acond_read_cookies.txt -c /tmp/acond_read_cookies.txt \
  -d "USER=${ACOND_USERNAME}&PASS=${ACOND_PASSWORD}" \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

# Read with optional sed filter
if [ -n "$SED_PATTERN" ]; then
  curl -s --max-time 5 -b /tmp/acond_read_cookies.txt \
    -H "x-tecomat: data" \
    "http://${ACOND_HOST}/${PAGE}" | sed -n "$SED_PATTERN"
else
  curl -s --max-time 5 -b /tmp/acond_read_cookies.txt \
    -H "x-tecomat: data" \
    "http://${ACOND_HOST}/${PAGE}"
fi

rm -f /tmp/acond_read_cookies.txt
