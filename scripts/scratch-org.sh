#!/usr/bin/env bash
# A new scratch org from config/project-scratch-def.json, made the default target, with force-app deployed.
#
#   bash scripts/scratch-org.sh <alias> [days]     days: 1 to 30, default 30
#
# The Dev Hub is this project's target-dev-hub (the nightshift org).
set -euo pipefail

usage() { echo "usage: bash scripts/scratch-org.sh <alias> [days 1-30]" >&2; exit 2; }
fail() { echo "scratch-org: $*" >&2; exit 1; }

org_alias=${1:-}
days=${2:-30}
[ -n "$org_alias" ] || usage
[[ "$days" =~ ^[0-9]+$ ]] && [ "$days" -ge 1 ] && [ "$days" -le 30 ] || usage

cd "$(dirname "$0")/.."

# sf writes its update notice to stderr; stdout stays pure JSON.
sf_json() { sf "$@" --json 2>/dev/null; }

dev_hub=$(sf_json config get target-dev-hub | jq -r '.result[0].value // empty')
[ -n "$dev_hub" ] || fail "no target-dev-hub set: sf config set target-dev-hub=nightshift"

# Reusing an alias would orphan the org it pointed to, still holding an active slot.
if sf_json org display --target-org "$org_alias" >/dev/null; then
  fail "'$org_alias' already names an org; pick another alias or delete it: sf org delete scratch --target-org $org_alias"
fi

limits=$(sf_json limits api display --target-org "$dev_hub") || fail "cannot read the limits of Dev Hub '$dev_hub'"
daily_left=$(jq -r '.result[] | select(.name == "DailyScratchOrgs") | .remaining' <<<"$limits")
active_left=$(jq -r '.result[] | select(.name == "ActiveScratchOrgs") | .remaining' <<<"$limits")
echo "Dev Hub $dev_hub: $active_left active and $daily_left new scratch orgs left today"
[ "$daily_left" -gt 0 ] || fail "no new scratch orgs left today; the count resets after 24 hours"
[ "$active_left" -gt 0 ] || fail "no active slot left; delete one first (sf org list --all)"

sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias "$org_alias" \
  --set-default \
  --duration-days "$days" \
  --target-dev-hub "$dev_hub" \
  --wait 15

if [ -n "$(find force-app -type f -print -quit)" ]; then
  sf project deploy start --target-org "$org_alias"
else
  echo "force-app is empty: nothing to deploy"
fi

sf_json org display --target-org "$org_alias" |
  jq -r '.result | "\nReady: \(.alias), default target org, expires \(.expirationDate)\nOpen it: sf org open"'
