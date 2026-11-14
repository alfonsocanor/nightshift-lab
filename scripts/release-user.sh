#!/usr/bin/env bash
# The lab release user of one org: the login a Lifecycle Center stage deploys with. GitHub names
# the stage's login as the author of every promotion merge, and this repository is public, so a
# stage logs in as this user, never as an admin.
#
#   bash scripts/release-user.sh <alias>
#
# Runs again safely: an org that already has an active release user is left as it is.
set -euo pipefail

fail() { echo "release-user: $*" >&2; exit 1; }

org_alias=${1:-}
[ -n "$org_alias" ] || { echo "usage: bash scripts/release-user.sh <alias>" >&2; exit 2; }

cd "$(dirname "$0")/.."

# sf writes its update notice to stderr; stdout stays pure JSON.
sf_json() { sf "$@" --json 2>/dev/null; }

dev_hub=$(sf_json config get target-dev-hub | jq -r '.result[0].value // empty')
[ -n "$dev_hub" ] || fail "no target-dev-hub set: sf config set target-dev-hub=nightshift"
hub=$(sf_json org display --target-org "$dev_hub") || fail "cannot reach Dev Hub '$dev_hub'"
org=$(sf_json org display --target-org "$org_alias") || fail "no org named '$org_alias'"

# Other aliases on this Mac are real orgs: only the Dev Hub and its own scratch orgs pass.
hub_id=$(jq -r '.result.id[0:15]' <<<"$hub")
hub_username=$(jq -r '.result.username' <<<"$hub")
org_id=$(jq -r '.result.id[0:15]' <<<"$org")
org_dev_hub=$(jq -r '.result.devHubId // empty' <<<"$org")
[ "$org_id" = "$hub_id" ] || [ "$org_dev_hub" = "$hub_username" ] ||
  fail "'$org_alias' is neither $dev_hub nor one of its scratch orgs: refusing"

deploy=$(sf_json project deploy start --metadata-dir lab/release-user --target-org "$org_alias" --wait 10) || true
[ "$(jq -r '.result.success' <<<"$deploy")" = true ] ||
  fail "permission set Lab_Release did not deploy: $(jq -r '[.result.files[]? | select(.state == "Failed") | .error][0] // .message' <<<"$deploy")"

existing=$(sf_json data query --target-org "$org_alias" \
  --query "SELECT Assignee.Username FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Lab_Release' AND Assignee.IsActive = true LIMIT 1" |
  jq -r '.result.records[0].Assignee.Username // empty')
if [ -n "$existing" ]; then
  echo "Release user of $org_alias: $existing (already there)"
  exit 0
fi

suffix=$(openssl rand -hex 3)
username="lab-release.${org_alias}.${suffix}@example.com"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
apex="$work/release-user.apex"
cat >"$apex" <<EOF
User admin = [SELECT Email, TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey, EmailEncodingKey FROM User WHERE Id = :UserInfo.getUserId()];
User release = new User(
    Username = '$username', FirstName = 'Lab', LastName = 'Release', Alias = 'labrel',
    CommunityNickname = 'lab-release-$suffix', Email = admin.Email,
    ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'].Id,
    TimeZoneSidKey = admin.TimeZoneSidKey, LocaleSidKey = admin.LocaleSidKey,
    LanguageLocaleKey = admin.LanguageLocaleKey, EmailEncodingKey = admin.EmailEncodingKey);
insert release;
insert new PermissionSetAssignment(
    AssigneeId = release.Id,
    PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Lab_Release'].Id);
System.resetPassword(release.Id, true);
EOF

run=$(sf_json apex run --target-org "$org_alias" --file "$apex") || true
[ "$(jq -r '.result.success' <<<"$run")" = true ] ||
  fail "creating the user failed: $(jq -r '.result.compileProblem // .result.exceptionMessage // .message' <<<"$run")"

email=$(sf_json data query --target-org "$org_alias" --query "SELECT Email FROM User WHERE Username = '$username'" |
  jq -r '.result.records[0].Email')
echo "Release user of $org_alias: $username"
echo "Salesforce sent the link to set its password to $email."
