# Agent Guidelines for nixpkgs-update-gha

## Commands

- **Format check**: `nix build .#checks.x86_64-linux.treefmt`
- **Format code**: `nix fmt`
- **Build flake**: `nix build`
- **Update flake**: `nix flake update`

## Code Style

- **Language**: Nix (flake-based) and GitHub Actions YAML
- **Formatting**: Use `nixfmt` for Nix files, `prettier` for YAML/Markdown
- **Keep-sorted**: Use `# keep-sorted start/end` comments for sorted lists (inputs, etc.)
<!-- keep-sorted end -->
- **Indentation**: 2 spaces for YAML, nixfmt defaults for Nix
- **Naming**: kebab-case for workflow files, job names, and step names
- **Comments**: Use shell comments in YAML run blocks to explain complex logic
- **Error handling**: Always check exit codes; use `::error::` and `::notice::` in workflows
- **Secrets**: Use `${{ secrets.GH_TOKEN }}` for GitHub operations requiring elevated permissions
- **Env vars**: Define at workflow level when used across multiple steps
- **Timeout**: Always set `timeout-minutes` on jobs (typically 10-30 minutes)
- **Permissions**: Explicitly declare minimal required permissions for each job
- **Conditionals**: Use `if:` with proper expression syntax; prefer `steps.id.outputs.var == 'value'`
