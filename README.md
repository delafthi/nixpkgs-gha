# nixpkgs-update-gha

> [!WARNING]
> **This project is currently in testing phase.**
>
> Features may not work as expected and breaking changes may occur without notice. Use at your own risk.

Automatically update and maintain your nixpkgs packages using GitHub Actions and [nix-update](https://github.com/Mic92/nix-update).

## Features

- Scheduled package updates (configurable cron)
- Parallel updates for multiple packages
- Automatic PR creation to nixpkgs
- Duplicate PR detection
- Powered by [nix-update](https://github.com/Mic92/nix-update) for reliable version updates
- Optional nixpkgs-review integration
- Manual on-demand updates
- Auto-discovery of latest versions from GitHub, GitLab, PyPI, crates.io, and more

## Setup

### 1. Fork nixpkgs

You need a fork of nixpkgs to push your update branches to:

1. Go to <https://github.com/NixOS/nixpkgs> and click "Fork"
2. Note your fork's repository name (e.g., `yourname/nixpkgs`)

### 2. Fork this repository

[Fork](https://github.com/delafthi/nixpkgs-update-gha/fork) this repository to your GitHub account.

### 3. Enable GitHub Actions

In your fork, go to the [Actions](../../actions) tab and enable GitHub Actions workflows.

### 4. Configure GitHub Token

Create a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for nixpkgs operations:

1. Go to <https://github.com/settings/tokens> and generate a new **fine-grained** token with `pull_requests:write` and `contents:write` permissions.
2. In your fork, go to "Settings" > "Secrets and variables" > "Actions" and [add a new repository secret](../../settings/secrets/actions/new) with the name `GH_TOKEN` and set its value to the personal access token you generated.

### 5. Configure Required Variables

Set the required variables for the workflow:

1. In your fork, go to "Settings" > "Secrets and variables" > "Actions" > "Variables" tab
2. [Create the following repository variables](../../settings/variables/actions/new):
   - **`PACKAGES`** (required): Semicolon-separated list of packages to update
     - Simple format: `hello;neovim;firefox` (versions auto-discovered)
     - With explicit versions: `postman 7.20.0 7.21.2;hello`
     - **Note:** Most packages with GitHub releases, updateScripts, or standard sources will auto-discover the latest version.

   - **`NIXPKGS_FORK`** (required): Your nixpkgs fork repository (e.g., `yourname/nixpkgs`)

### 6. Adjust Update Schedule (optional)

The default schedule runs updates on Wednesday and Friday at 2 AM UTC. To customize this:

1. Edit `.github/workflows/update.yml`
2. Modify the cron expression on line 5:
   ```yaml
   - cron: "0 2 * * 3,5" # Wednesday and Friday at 2 AM UTC
   ```

Common cron patterns:

- `0 2 * * 3,5` - Wednesday and Friday at 2 AM UTC
- `0 2 * * 1,5` - Monday and Friday at 2 AM UTC
- `0 6 * * *` - Every day at 6 AM UTC
- `0 */12 * * *` - Every 12 hours
- `0 0 * * 0` - Every Sunday at midnight UTC

### 7. Configure Default Behavior (optional)

You can set default values for workflow behavior using repository variables:

1. In your fork, go to "Settings" > "Secrets and variables" > "Actions" > "Variables" tab
2. Create any of the following optional variables:

| Variable            | Description                                   | Default         | Required |
| ------------------- | --------------------------------------------- | --------------- | -------- |
| `SKIP_IF_PR_EXISTS` | Skip updates if a PR already exists           | `true`          | No       |
| `NIXPKGS_REVIEW`    | Run nixpkgs-review on updates                 | `true`          | No       |
| `NIXPKGS_REPO`      | Target repository (use your fork for testing) | `NixOS/nixpkgs` | No       |

**Note:** When manually triggering updates, you can override these variables by providing workflow inputs. If no input is provided for a setting, the corresponding repository variable will be used.

### 8. Configure External nixpkgs-review-gha (optional)

If you want to use [nixpkgs-review-gha](https://github.com/Defelo/nixpkgs-review-gha) for comprehensive external reviews:

1. Fork [nixpkgs-review-gha](https://github.com/Defelo/nixpkgs-review-gha) and set it up following its documentation
2. In your nixpkgs-update-gha fork, go to "Settings" > "Secrets and variables" > "Actions" > "Variables" tab
3. Create the following variables:
   - `TRIGGER_REVIEW_GHA`: Set to `true` to enable automatic triggering
   - `NIXPKGS_REVIEW_GHA_REPO`: Your fork of nixpkgs-review-gha (e.g., `yourname/nixpkgs-review-gha`)

When enabled, after creating a PR, this workflow will automatically trigger your nixpkgs-review-gha fork to run a full review with build results and reports posted directly on the PR.

## Usage

### Automatic Updates (Scheduled)

Once configured, the workflow will automatically run on the schedule defined in `.github/workflows/update.yml` (default: Wednesday and Friday at 2 AM UTC) and update all packages listed in the `PACKAGES` variable.

### Manual Updates (On-Demand)

To manually trigger updates:

1. Go to the [update workflow in the "Actions" tab](../../actions/workflows/update.yml)
2. Click "Run workflow"
3. (Optional) Enter a semicolon-separated list of packages to update (overrides `PACKAGES`)
   - Examples: `hello` or `postman 7.20.0 7.21.2;neovim`
4. (Optional) Override default settings:
   - **Skip if PR exists**: Skip packages that already have open PRs
   - **nixpkgs-review**: Run nixpkgs-review on updates
   - **Trigger external nixpkgs-review-gha**: Trigger your nixpkgs-review-gha fork for comprehensive reviews
5. Click "Run workflow"

**Note:** All inputs are optional. If not provided, the workflow will use the corresponding repository variables (`PACKAGES`, `SKIP_IF_PR_EXISTS`, `NIXPKGS_REVIEW`).

### Viewing Results

After the workflow runs:

1. Check the [Actions](../../actions) tab to see the workflow execution
2. Each package update runs as a separate job in the matrix
3. If PRs were created, you'll find links in the job logs
4. If nixpkgs-review is enabled, the report will be included in the PR body

## How It Works

### Workflow Overview

1. **prepare-matrix** job parses the package list (from workflow input or `PACKAGES` variable)
2. **update** job runs in parallel for each package using a matrix strategy
3. For each package:
   - Check if a PR already exists on the target repository
   - Skip if PR exists (unless `skip-if-pr-exists` is disabled)
   - Clone nixpkgs and setup git environment
   - Discover latest version if only package name provided (via nix-update's auto-discovery)
   - Run [nix-update](https://github.com/Mic92/nix-update) which:
     - Updates version strings and hashes automatically
     - Runs package-specific update scripts if available
     - Updates `cargoHash`, `vendorHash`, `npmDepsHash`, etc. for different build systems
   - Build the package with nixpkgs-review (if enabled)
   - Create a properly formatted commit
   - Create/update the PR using [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request)

### PR Format

Pull requests follow the nixpkgs standard format:

- Title: `package-name: old-version → new-version`
- Body includes:
  - Package description, homepage, and changelog (if available)
  - nixpkgs-review report with build results (if enabled)
  - Link to the update source

## Configuration Reference

### Repository Variables

| Variable                  | Description                                    | Default         | Required | Example                       |
| ------------------------- | ---------------------------------------------- | --------------- | -------- | ----------------------------- |
| `PACKAGES`                | Semicolon-separated list of packages to update | -               | Yes      | `hello;neovim;firefox`        |
| `NIXPKGS_FORK`            | Your fork of nixpkgs to push changes to        | -               | Yes      | `yourname/nixpkgs`            |
| `SKIP_IF_PR_EXISTS`       | Skip updates if a PR already exists            | `true`          | No       | `true`                        |
| `NIXPKGS_REVIEW`          | Run nixpkgs-review on updates                  | `true`          | No       | `true`                        |
| `NIXPKGS_REPO`            | Target repository for PRs                      | `NixOS/nixpkgs` | No       | `NixOS/nixpkgs`               |
| `TRIGGER_REVIEW_GHA`      | Trigger external nixpkgs-review-gha workflow   | `false`         | No       | `true`                        |
| `NIXPKGS_REVIEW_GHA_REPO` | Your fork of nixpkgs-review-gha                | -               | No       | `yourname/nixpkgs-review-gha` |

### Repository Secrets

| Secret     | Description                                                         | Default | Required |
| ---------- | ------------------------------------------------------------------- | ------- | -------- |
| `GH_TOKEN` | GitHub token with `pull_requests:write` and `contents:write` access | -       | Yes      |

### Workflow Inputs (Manual Dispatch)

| Input                | Description                                    | Default                     | Required |
| -------------------- | ---------------------------------------------- | --------------------------- | -------- |
| `packages`           | Semicolon-separated list of packages to update | (uses `PACKAGES`)           | No       |
| `skip-if-pr-exists`  | Skip packages that already have open PRs       | (uses `SKIP_IF_PR_EXISTS`)  | No       |
| `nixpkgs-review`     | Run nixpkgs-review on updates                  | (uses `NIXPKGS_REVIEW`)     | No       |
| `trigger-review-gha` | Trigger external nixpkgs-review-gha workflow   | (uses `TRIGGER_REVIEW_GHA`) | No       |
