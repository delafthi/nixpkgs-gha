# nixpkgs-update-gha

> [!WARNING]
> **This project is currently in testing phase.**
> 
> Features may not work as expected and breaking changes may occur without notice. Use at your own risk.

Automatically update and maintain your nixpkgs packages using GitHub Actions.

## Features
- Scheduled package updates (configurable cron)
- Parallel updates for multiple packages
- Automatic PR creation to nixpkgs
- Duplicate PR detection
- Optional [nixpkgs-review-gha](https://github.com/Defelo/nixpkgs-review-gha) integration
- Manual on-demand updates

## Setup

### 1. Fork this repository
[Fork](https://github.com/delafthi/nixpkgs-update-gha/fork) this repository to your GitHub account.

### 2. Enable GitHub Actions
In your fork, go to the [Actions](../../actions) tab and enable GitHub Actions workflows.

### 3. Configure GitHub Token
Create a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for nixpkgs operations:

1. Go to <https://github.com/settings/tokens> and generate a new **classic** token with the `public_repo` scope.
2. In your fork, go to "Settings" > "Secrets and variables" > "Actions" and [add a new repository secret](../../settings/secrets/actions/new) with the name `GH_TOKEN` and set its value to the personal access token you generated.

### 4. Configure Watched Packages
Set the list of packages you want to automatically update:

1. In your fork, go to "Settings" > "Secrets and variables" > "Actions" > "Variables" tab
2. [Create a new repository variable](../../settings/variables/actions/new) with the name `WATCHING_PACKAGES`
3. Set its value to a space-separated list of package names (e.g., `hello nix-update nixpkgs-fmt`)

### 5. Adjust Update Schedule (optional)
The default schedule runs updates on Monday and Friday at 2 AM UTC. To customize this:

1. Edit `.github/workflows/update.yml`
2. Modify the cron expression on line 5:
   ```yaml
   - cron: "0 2 * * 1,5"  # Monday and Friday at 2 AM UTC
   ```

Common cron patterns:
- `0 2 * * 1,5` - Monday and Friday at 2 AM UTC
- `0 6 * * *` - Every day at 6 AM UTC
- `0 */12 * * *` - Every 12 hours
- `0 0 * * 0` - Every Sunday at midnight UTC

### 6. Configure Default Behavior (optional)
You can set default values for workflow behavior using repository variables:

1. In your fork, go to "Settings" > "Secrets and variables" > "Actions" > "Variables" tab
2. Create any of the following optional variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `FORCE_OPEN_PR` | `false` | Force opening PRs even if one exists |
| `OPEN_PR` | `true` | Automatically open PRs |
| `NIXPKGS_REVIEW_GHA_FORK` | (empty) | Your nixpkgs-review-gha fork (e.g., `username/nixpkgs-review-gha`) |
| `NIXPKGS_REPO` | `NixOS/nixpkgs` | Target repository (use your fork for testing) |

**Note:** Workflow dispatch inputs will override these variables when manually triggering updates.

## Usage

### Automatic Updates (Scheduled)
Once configured, the workflow will automatically run on the schedule defined in `.github/workflows/update.yml` (default: Monday and Friday at 2 AM UTC) and update all packages listed in the `WATCHING_PACKAGES` variable.

### Manual Updates (On-Demand)
To manually trigger updates:

1. Go to the [update workflow in the "Actions" tab](../../actions/workflows/update.yml)
2. Click "Run workflow"
3. (Optional) Enter a space-separated list of packages to update (overrides `WATCHING_PACKAGES`)
4. (Optional) Override default settings:
   - **Force open PR**: Create PR even if one already exists
   - **Open PR**: Automatically create a PR
   - **nixpkgs-review-gha fork**: Trigger automated reviews
   - **nixpkgs-repo**: Target repository (for testing with your fork)
5. Click "Run workflow"

**Note:** All inputs are optional and will use repository variable defaults if not specified.

### Viewing Results
After the workflow runs:

1. Check the [Actions](../../actions) tab to see the workflow execution
2. Each package update runs as a separate job in the matrix
3. If PRs were created, you'll find links in the job logs
4. If nixpkgs-review-gha is configured, reviews will be triggered automatically

## How It Works

### Workflow Overview
1. **prepare-matrix** job parses the package list (from workflow input or `WATCHING_PACKAGES` variable)
2. **update** job runs in parallel for each package using a matrix strategy
3. For each package:
   - Check if a PR already exists on NixOS/nixpkgs
   - Skip if PR exists (unless `force-open-pr` is enabled)
   - Clone nixpkgs and get current version
   - Run the package's update script
   - Detect version changes
   - Create a PR with the update
   - Optionally trigger nixpkgs-review-gha

### PR Format
Pull requests created by nixpkgs-update-gha follow a format similar to [nixpkgs-update](https://github.com/nix-community/nixpkgs-update):

- Title: `package-name: old-version -> new-version`
- Body includes:
  - Automatic update notice with link to this repository
  - List of updates performed
  - nixpkgs-review status and link (if configured)

## Configuration Reference

### Repository Variables
| Variable | Required | Default | Description | Example |
|----------|----------|---------|-------------|---------|
| `WATCHING_PACKAGES` | Yes | - | Space-separated list of packages to update | `hello nix-update` |
| `FORCE_OPEN_PR` | No | `false` | Force opening PRs even if one exists | `false` |
| `OPEN_PR` | No | `true` | Automatically open PRs | `true` |
| `NIXPKGS_REVIEW_GHA_FORK` | No | (empty) | Fork for triggering nixpkgs-review-gha | `username/nixpkgs-review-gha` |
| `NIXPKGS_REPO` | No | `NixOS/nixpkgs` | Target repository for PRs | `username/nixpkgs` |

### Repository Secrets
| Secret | Required | Description |
|--------|----------|-------------|
| `GH_TOKEN` | Yes | GitHub personal access token with `public_repo` scope |

### Workflow Inputs (Manual Dispatch)
| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `packages` | No | (uses `WATCHING_PACKAGES`) | Space-separated list of packages to update |
| `force-open-pr` | No | (uses `FORCE_OPEN_PR`) | Force opening a PR even if one exists |
| `open-pr` | No | (uses `OPEN_PR`) | Automatically open a PR |
| `nixpkgs-review-gha-fork` | No | (uses `NIXPKGS_REVIEW_GHA_FORK`) | Fork for triggering nixpkgs-review-gha |
| `nixpkgs-repo` | No | (uses `NIXPKGS_REPO`) | Target repository for PRs |

## Troubleshooting

### Updates not running automatically
- Check that GitHub Actions is enabled in your fork
- Verify the workflow is enabled in Actions tab
- Check that `WATCHING_PACKAGES` variable is set correctly

### PRs not being created
- Ensure `GH_TOKEN` secret is set with correct permissions
- Check workflow logs for error messages
- Verify the package name is correct

### No changes detected
- The package may already be up-to-date
- The package's update script may not have found a new version
- Check the workflow logs for details

## License

MIT
