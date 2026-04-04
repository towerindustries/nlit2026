# Terraform 101 Workshop Template for GitHub Codespaces

This repository is a ready-to-commit starter for a workshop that runs in GitHub Codespaces.

## What this gives you

- Repeatable browser-based lab environment
- Preinstalled Terraform, AWS CLI, and GitHub CLI
- Preconfigured VS Code extensions
- Guided lab flow in the `labs/` directory
- Starter Terraform code in `starter-code/terraform/`
- Recommended Codespaces secrets for temporary AWS credentials

## Recommended workshop flow

1. Create a new GitHub repository from this folder.
2. Push the files.
3. Mark the repository as a **template repository** if you want each attendee to launch an isolated copy.
4. Configure **Codespaces prebuilds** for the default branch.
5. Provide attendees a single instruction: create a codespace and open `labs/00-welcome.md`.

## Attendee launch instructions

1. Open the repository on GitHub.
2. Click **Code**.
3. Choose **Codespaces**.
4. Create a new codespace on the main branch.
5. Wait for the workspace to finish setup.
6. Open `labs/00-welcome.md` and begin.

## Secrets to define for the repo or organization

Set these in GitHub Codespaces secrets if students need AWS access:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (optional)
- `AWS_DEFAULT_REGION`

Use temporary, tightly scoped credentials for workshops.

## Suggested GitHub settings

- Enable Codespaces for the repository or organization
- Enable prebuilds on `main`
- Restrict machine sizes to 2-core or 4-core unless the lab needs more
- Set a spending limit if the org is paying
- Set idle timeout policies to control costs

## Repository structure

```text
.devcontainer/
  devcontainer.json
  on-create.sh
  post-create.sh
  post-start.sh
labs/
  00-welcome.md
  01-first-apply.md
  02-variables-and-outputs.md
starter-code/
  terraform/
    main.tf
    variables.tf
    outputs.tf
    terraform.tfvars.example
scripts/
  reset-lab.sh
```

## Notes for instructors

- Put solution material in a private instructor repo or a protected branch.
- Freeze the repo a day before class so prebuilds stay warm.
- For 40 attendees, avoid heavyweight package installs during session time.
- Prefer one workshop repo per course run.
