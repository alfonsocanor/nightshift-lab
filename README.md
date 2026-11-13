# Nightshift Lab

A Salesforce DX project for testing Nightshift end to end: its set-up wizard, and the Lifecycle work. All metadata and data here are made up for testing.

## Develop in a scratch org

The Dev Hub is the org aliased `nightshift` (already set as this project's `target-dev-hub`).

```bash
# a new scratch org, as the default target
sf org create scratch --definition-file config/project-scratch-def.json --alias ns-dev --set-default --duration-days 30

# push the project, then open the org
sf project deploy start
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
- `scripts/`: anonymous Apex and SOQL to try things with.

See [CLAUDE.md](CLAUDE.md) for the rules an agent working here follows.
