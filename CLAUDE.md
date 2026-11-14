# Nightshift Lab

A Salesforce project that exists to test Nightshift, not to ship anything. Owner, 2026-11-13: "The idea of this org is to be able to test the set up of nightshift, the wizard. This also will allow us to improve Nightshift to implement Lifecycle"; "so we can implement made up things for fully testing purposes".

## Rules

- **Everything here is made up.** Objects, fields, Apex, flows and data are invented to give Nightshift realistic work. Nothing comes from a real customer or a real production org.
- **The repository is public.** Never commit a username, an org id, an auth URL, a consumer key, a private key or an access token. Refer to orgs by alias only. `.sf/` and `.sfdx/` stay ignored.
- **Stages log in as the lab release user, never as an admin.** Lifecycle Center names a stage's login as the author of every promotion merge it writes to GitHub. The release user (`lab-release.<alias>.<random>@example.com`, profile Minimum Access - Salesforce, permission set `Lab_Release` from `lab/release-user/`) is made by `bash scripts/release-user.sh <alias>`, and by `scripts/scratch-org.sh` for every new scratch org; Salesforce emails the link to set its password to the org admin's address. The script refuses any org but `nightshift` and its own scratch orgs. Merges before 2026-11-14 evening name the `nightshift` admin and the first `lab-uat` admin; they stay, because rewriting `main` would break Lifecycle Center's record of them.
- **Develop in scratch orgs** (`bash scripts/scratch-org.sh <alias> [days]`), never in the Dev Hub. Deploy to `nightshift` only on purpose, when a test of Nightshift's production-side set-up needs it.

## Orgs

| Alias | What it is | Role for Nightshift |
| --- | --- | --- |
| `nightshift` | Developer Edition, Dev Hub (`target-dev-hub` of this project) | Production. Its My Domain ends in `.develop.my.salesforce.com`, which Nightshift's guards read as a production host: it can be the production org of a test install, never a task org. |
| `ns-dev` | Scratch org from `config/project-scratch-def.json`, 30 days | A development org. |
| `lab-uat` | Scratch org, 30 days, expires 2026-12-14 | Lifecycle Center's UAT stage, registered as a Sandbox. |

Other aliases on this Mac point at real orgs (`ns-uat` is a real company UAT sandbox). Use only the aliases in this table.

The Dev Hub is a Developer Edition: at most 3 active scratch orgs and 6 new ones a day (`sf limits api display -o nightshift`).

## What Nightshift accepts today (read 2026-11-13, revision 155)

- A scratch org's host (`.scratch.my.salesforce.com`) passes `assertNonProduction` in `packages/core/src/ports/salesforce-orgs.ts`, so it can be a task org.
- The Station's **Settings → Add a sandbox** checks `assertTaskSandbox` in `packages/core/src/app/sandbox-desk.ts`, which accepts only a `.sandbox.my.salesforce.com` host whose org says it is a sandbox. A scratch org is refused there today; testing the wizard with scratch orgs needs Nightshift to change, or a sandbox.

## Lifecycle Center

Lifecycle Center is Salesforce's next-generation DevOps Center (renamed in fall 2026). It runs in `nightshift`, and the owner wants Nightshift to gain an adapter for it ("implement Lifecycle"). Set up on 2026-11-14:

- **Project and pipeline**, both "Nightshift Lab", on this repository: **UAT** (`lab-uat`, branch `uat`) promotes to **Production** (`nightshift`, branch `main`). Active. `sf devops pipeline list -o nightshift` shows the ids.
- The `nightshift` admin holds Lifecycle Center User, Admin and Deployment Manager.
- **Scripted** with `sf devops`: permission sets, project, pipeline, stages, branches (`stage branch add --create-vcs-branch` only registers the branch; activating the pipeline creates it on GitHub), activation.
- **The owner's by hand**: accepting the terms and connecting GitHub in the app, once; each stage's login, as that org's release user (`sf devops stage environment add ... --force` opens a page that always asks for a username and password; the password is the one set from Salesforce's email). A development scratch org is connected from the pipeline screen or by its first commit from DX Inspector; no CLI command does it.
- **When `lab-uat` expires**, create another scratch org with `scripts/scratch-org.sh` (it makes the release user), set its password from the email, and re-run `sf devops stage environment add ... --org-type Sandbox --force` for the UAT stage, logging in as that release user.
- `main` is the Production branch now. A change merged into `main` outside the pipeline (docs, scripts) leaves `uat` behind it.
