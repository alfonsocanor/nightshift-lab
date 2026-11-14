# Nightshift Lab

A Salesforce DX project for testing Nightshift end to end: its set-up wizard, and the Lifecycle work. All metadata and data here are made up for testing.

## Develop in a scratch org

The Dev Hub is the org aliased `nightshift` (already set as this project's `target-dev-hub`).

```bash
# a new scratch org: checks the Dev Hub's limits, creates it for 30 days
# (or the days given), makes it the default target, deploys force-app and
# creates its lab release user (scripts/release-user.sh)
bash scripts/scratch-org.sh ns-dev [days]

sf org open

# see what is live and how many are left today
sf org list --all
sf limits api display -o nightshift | grep -i scratch

# delete one when done
sf org delete scratch --target-org ns-dev
```

A Developer Edition Dev Hub allows 3 active scratch orgs and 6 new ones a day.

## Layout

- `force-app/main/default/`: the metadata.
- `config/project-scratch-def.json`: the scratch org's shape.
- `lab/release-user/`: the `Lab_Release` permission set of the user a Lifecycle Center stage logs in as. Outside `force-app`, so the pipeline never promotes it.
- `scripts/`: anonymous Apex and SOQL to try things with.

See [CLAUDE.md](CLAUDE.md) for the rules an agent working here follows.
