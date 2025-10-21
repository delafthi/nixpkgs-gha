# nixpkgs-update-gha

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-blue.svg)](https://github.com/features/actions)

> [!WARNING]
> **This project is currently in testing phase.**
>
> Features may not work as expected and breaking changes may occur without notice. Use at your own risk.

Automate nixpkgs package maintenance with GitHub Actions. Keep your packages up-to-date with scheduled updates, automatic PR creation, and built-in quality checks using [nix-update](https://github.com/Mic92/nix-update) and [nixpkgs-review](https://github.com/Mic92/nixpkgs-review).

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [How It Works](#how-it-works)
- [Configuration Reference](#configuration-reference)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features

- **Automated updates**: Schedule updates with configurable cron expressions
- **Parallel processing**: Update multiple packages concurrently using GitHub Actions matrix
- **Smart PR management**: Automatic PR creation with duplicate detection
- **Version auto-discovery**: Automatically detect latest versions from GitHub, GitLab, PyPI, crates.io, and more
- **Quality checks**: Built-in nixpkgs-review integration for build verification
- **Manual control**: Trigger on-demand updates via GitHub Actions workflow_dispatch
- **Reliable updates**: Powered by [nix-update](https://github.com/Mic92/nix-update) for accurate version and hash updates

## Prerequisites

- A GitHub account with access to create repositories and personal access tokens
- A fork of [nixpkgs](https://github.com/NixOS/nixpkgs) to push update branches
- Basic familiarity with GitHub Actions and nixpkgs contribution workflow

## Setup

### 1. Fork nixpkgs

Fork nixpkgs to have a repository where update branches will be pushed:

1. Navigate to <https://github.com/NixOS/nixpkgs> and click **Fork**
2. Note your fork's repository name (format: `username/nixpkgs`)

### 2. Fork this repository

[Fork](https://github.com/delafthi/nixpkgs-update-gha/fork) this repository to your GitHub account.

### 3. Enable GitHub Actions

In your fork, go to the [Actions](../../actions) tab and enable GitHub Actions workflows.

### 4. Configure GitHub Token

Create a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for nixpkgs operations:

1. Navigate to <https://github.com/settings/tokens> and generate a new **fine-grained** token
2. Grant the following permissions:
   - `pull_requests:write` - Create and update pull requests
   - `contents:write` - Push branches to your nixpkgs fork
3. In your fork of nixpkgs-update-gha, navigate to **Settings** → **Secrets and variables** → **Actions**
4. [Add a new repository secret](../../settings/secrets/actions/new):
   - Name: `GH_TOKEN`
   - Value: Your generated personal access token

### 5. Configure Required Variables

Set the required variables for the workflow:

1. In your fork of nixpkgs-update-gha, navigate to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab
2. [Create the following repository variables](../../settings/variables/actions/new):

   **`PACKAGES`** (required)
   - Space-separated list of packages to update
   - Formats supported:
     ```
     hello neovim firefox                    # Auto-discover latest versions
     postman 7.20.0 7.21.2 hello            # Explicit version update for postman
     ```
   - Most packages with GitHub releases, updateScripts, or standard sources support auto-discovery

   **`NIXPKGS_FORK`** (required)
   - Your nixpkgs fork repository
   - Format: `username/nixpkgs`
   - Example: `octocat/nixpkgs`

### 6. Customize Update Schedule (optional)

The default schedule runs updates on **Wednesday and Friday at 2:00 AM UTC**. To customize:

1. Edit `.github/workflows/update.yml` in your fork
2. Modify the cron expression on line 5 under the `schedule` trigger

**Common cron patterns:**

| Pattern        | Schedule                         |
| -------------- | -------------------------------- |
| `0 2 * * 3,5`  | Wednesday and Friday at 2 AM UTC |
| `0 2 * * 1,5`  | Monday and Friday at 2 AM UTC    |
| `0 6 * * *`    | Every day at 6 AM UTC            |
| `0 */12 * * *` | Every 12 hours                   |
| `0 0 * * 0`    | Every Sunday at midnight UTC     |

> [!TIP]
> Use [crontab.guru](https://crontab.guru/) to create and validate cron expressions.

### 7. Configure Default Behavior (optional)

Customize workflow behavior with optional repository variables:

1. In your fork of nixpkgs-update-gha, navigate to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab
2. Create any of the following optional variables:

| Variable            | Description                                           | Default         |
| ------------------- | ----------------------------------------------------- | --------------- |
| `SKIP_IF_PR_EXISTS` | Skip updates if an open PR already exists             | `true`          |
| `NIXPKGS_REPO`      | Target repository for PRs (use your fork for testing) | `NixOS/nixpkgs` |

> [!TIP]
> When manually triggering updates via workflow_dispatch, you can override these defaults using workflow inputs.

### 8. Configure External nixpkgs-review-gha (optional)

Integrate [nixpkgs-review-gha](https://github.com/Defelo/nixpkgs-review-gha) for comprehensive external reviews:

1. Fork and configure [nixpkgs-review-gha](https://github.com/Defelo/nixpkgs-review-gha) following its documentation
2. In your nixpkgs-update-gha fork, navigate to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab
3. Create the following variables:

   | Variable                  | Description                     | Example                       |
   | ------------------------- | ------------------------------- | ----------------------------- |
   | `NIXPKGS_REVIEW_GHA`      | Enable automatic triggering     | `true`                        |
   | `NIXPKGS_REVIEW_GHA_REPO` | Your fork of nixpkgs-review-gha | `username/nixpkgs-review-gha` |

When enabled, the workflow will automatically trigger your nixpkgs-review-gha fork after PR creation, posting comprehensive build results and reports directly on the PR.

## Usage

### Scheduled Updates (Automatic)

Once configured, the workflow runs automatically based on the schedule defined in `.github/workflows/update.yml`:

- **Default schedule**: Wednesday and Friday at 2:00 AM UTC
- **Packages updated**: All packages listed in the `PACKAGES` repository variable
- **No manual intervention required**

### Manual Updates (On-Demand)

Trigger updates manually for specific packages or with custom settings:

1. Navigate to the [Actions tab](../../actions/workflows/update.yml)
2. Click **Run workflow**
3. Configure workflow inputs (all optional):

   | Input                      | Description                                             | Example                |
   | -------------------------- | ------------------------------------------------------- | ---------------------- |
   | Packages                   | Space-separated list of packages (overrides `PACKAGES`) | `hello neovim firefox` |
   | Skip if PR exists          | Skip packages with existing open PRs                    | ✓ (checked)            |
   | Trigger nixpkgs-review-gha | Trigger external comprehensive review                   | ☐ (unchecked)          |

4. Click **Run workflow**

> [!NOTE]
> If no inputs are provided, the workflow uses values from repository variables (`PACKAGES`, `SKIP_IF_PR_EXISTS`, `NIXPKGS_REVIEW_GHA`).

### Viewing Results

Monitor workflow execution and results:

1. Navigate to the [Actions tab](../../actions) to view workflow runs
2. Click on a workflow run to see details
3. Each package update executes as a separate job in a matrix
4. Successful updates will create PRs on nixpkgs with:
   - Standard nixpkgs PR title format: `package: old-version → new-version`
   - Package metadata (description, homepage, changelog)
   - nixpkgs-review build results (if enabled)
   - Links to job logs are available in the workflow summary

## How It Works

### Workflow Architecture

The update process consists of two main jobs:

#### 1. Prepare Matrix Job

- Parses the package list from workflow input or `PACKAGES` variable
- Validates required configuration (`NIXPKGS_FORK`)
- Creates a GitHub Actions matrix for parallel processing
- Passes configuration to update jobs

#### 2. Update Job (Parallel Execution)

Each package update runs independently with the following steps:

1. **PR Detection**
   - Query nixpkgs for existing open PRs for the package
   - Skip update if PR exists (configurable via `skip-if-pr-exists`)

2. **Environment Setup**
   - Clone nixpkgs repository
   - Install Nix with flakes support
   - Configure git identity for commits

3. **Version Discovery**
   - Auto-discover latest version using nix-update (if not explicitly provided)
   - Support for GitHub releases, GitLab, PyPI, crates.io, and other sources

4. **Package Update**
   - Run [nix-update](https://github.com/Mic92/nix-update) to:
     - Update version strings in package expressions
     - Recalculate and update hashes (SHA256, SRI)
     - Update language-specific hashes (`cargoHash`, `vendorHash`, `npmDepsHash`, etc.)
     - Execute package-specific update scripts

5. **Quality Verification**
   - Build package with [nixpkgs-review](https://github.com/Mic92/nixpkgs-review) (optional)
   - Generate build report

6. **PR Creation**
   - Create properly formatted commit
   - Push to your nixpkgs fork
   - Create or update PR using [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request)
   - Trigger external nixpkgs-review-gha (optional)

### PR Format

Pull requests adhere to nixpkgs standards:

**Title**

```
package-name: old-version → new-version
```

**Body Content**

- Package metadata (description, homepage)
- Changelog link (if available)
- nixpkgs-review build results (if enabled)
- Automatic labels: `automated-update` and package name
- Attribution to nixpkgs-update-gha

### Concurrency Control

The workflows implement concurrency controls to prevent conflicts and duplicate PRs:

**Workflow-level Concurrency**

- Multiple workflow runs on the same branch are prevented
- New manual triggers cancel any in-progress runs
- Scheduled runs complete without interruption

**Package-level Concurrency**

- Each package can only be updated by one job at a time
- Concurrent updates of different packages are allowed
- Package updates run with a maximum of 3 parallel jobs to prevent API rate limiting

**Benefits**

- Prevents duplicate PRs for the same package
- Avoids race conditions in PR existence checks
- Efficient resource utilization
- Respects GitHub API rate limits

## Configuration Reference

### Repository Variables

Configure these in **Settings** → **Secrets and variables** → **Actions** → **Variables** tab.

#### Required Variables

| Variable       | Description                                | Example                |
| -------------- | ------------------------------------------ | ---------------------- |
| `PACKAGES`     | Space-separated list of packages to update | `hello neovim firefox` |
| `NIXPKGS_FORK` | Your fork of nixpkgs                       | `username/nixpkgs`     |

#### Optional Variables

| Variable                  | Description                                  | Default         |
| ------------------------- | -------------------------------------------- | --------------- |
| `SKIP_IF_PR_EXISTS`       | Skip updates if an open PR already exists    | `true`          |
| `NIXPKGS_REPO`            | Target repository for PRs                    | `NixOS/nixpkgs` |
| `NIXPKGS_REVIEW_GHA`      | Trigger external nixpkgs-review-gha workflow | `false`         |
| `NIXPKGS_REVIEW_GHA_REPO` | Your fork of nixpkgs-review-gha              | -               |

### Repository Secrets

Configure these in **Settings** → **Secrets and variables** → **Actions** → **Secrets** tab.

| Secret     | Description                                                               | Required |
| ---------- | ------------------------------------------------------------------------- | -------- |
| `GH_TOKEN` | Fine-grained GitHub token with `pull_requests:write` and `contents:write` | Yes      |

### Workflow Inputs

Available when triggering workflows manually via `workflow_dispatch`. All inputs are optional and fall back to repository variables.

| Input                | Description                                  | Fallback Variable    |
| -------------------- | -------------------------------------------- | -------------------- |
| `packages`           | Space-separated list of packages to update   | `PACKAGES`           |
| `skip-if-pr-exists`  | Skip packages with existing open PRs         | `SKIP_IF_PR_EXISTS`  |
| `nixpkgs-review-gha` | Trigger external nixpkgs-review-gha workflow | `NIXPKGS_REVIEW_GHA` |

### Package Format

Specify packages in one of the following formats:

```bash
# Auto-discover latest versions (recommended)
hello neovim firefox

# Explicit version update (from old to new)
postman 7.20.0 7.21.2

# Mixed formats
postman 7.20.0 7.21.2 hello neovim
```

## Troubleshooting

### Workflow fails with "NIXPKGS_FORK variable is required"

**Cause**: The `NIXPKGS_FORK` repository variable is not set.

**Solution**: Follow [step 5](#5-configure-required-variables) to configure the required `NIXPKGS_FORK` variable.

### Package update is skipped

**Cause**: An open PR already exists for the package and `SKIP_IF_PR_EXISTS` is `true`.

**Solution**:

- Check nixpkgs for existing PRs with the package name
- Disable `skip-if-pr-exists` when manually triggering if you want to force update
- Close the existing PR if it's no longer needed

### nix-update fails to find package

**Cause**: Package name is misspelled or doesn't exist in nixpkgs.

**Solution**:

- Verify package name with: `nix search nixpkgs#packagename`
- Check the package exists in the nixpkgs repository
- Review the workflow logs for the exact error message

### PR creation fails with authentication error

**Cause**: The `GH_TOKEN` secret is invalid, expired, or lacks required permissions.

**Solution**:

- Regenerate your GitHub personal access token
- Ensure it has `pull_requests:write` and `contents:write` permissions
- Update the `GH_TOKEN` secret in repository settings

### nixpkgs-review build fails

**Cause**: Package has build errors or missing dependencies.

**Solution**:

- Review the nixpkgs-review output in the workflow logs
- Fix the package build errors manually
- The PR will still be created (nixpkgs-review runs with `continue-on-error`)
- Consider disabling `nixpkgs-review` for packages with known build issues

### Workflow times out

**Cause**: Package build takes longer than 30 minutes.

**Solution**:

- The workflow timeout can be adjusted in `.github/workflows/update-package.yml` (line 36)
- Consider splitting large packages into separate workflow runs

### Transient API failures

**Cause**: GitHub API rate limiting or temporary network issues.

**Solution**:

- The workflow automatically retries failed API calls up to 3 times
- If issues persist, re-run the failed workflow manually
- Check GitHub's [status page](https://www.githubstatus.com/) for ongoing incidents

## License

This project is licensed under the [MIT License](LICENSE).
