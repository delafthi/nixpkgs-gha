# Agent Guidelines for nixpkgs-update-gha

## Commands

- **Format check**: `nix build .#checks.x86_64-linux.treefmt`
- **Format code**: `nix fmt`
- **Build flake**: `nix build`
- **Update flake**: `nix flake update`

## Code Style

- **Comments**: Use shell comments in YAML run blocks to explain complex logic
- **Conditionals**: Use `if:` with proper expression syntax; prefer `steps.id.outputs.var == 'value'`
- **Env vars**: Define at workflow level when used across multiple steps
- **Error handling**: Always check exit codes; use `::error::` and `::notice::` in workflows
- **Formatting**: Use `nixfmt` for Nix files, `prettier` for YAML/Markdown
- **Indentation**: 2 spaces for YAML, nixfmt defaults for Nix
- **Language**: Nix (flake-based) and GitHub Actions YAML
- **Naming**: kebab-case for workflow files, job names, and step names
- **Permissions**: Explicitly declare minimal required permissions for each job
- **Secrets**: Use `${{ secrets.GH_TOKEN }}` for GitHub operations requiring elevated permissions
- **Sorted lists**: Use `# keep-sorted start/end` comments for sorted lists (inputs, etc.)
<!-- keep-sorted end -->
- **Timeout**: Always set `timeout-minutes` on jobs (typically 10-30 minutes)
