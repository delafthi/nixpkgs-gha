{
  description = "GitHub Automations for the nixpkgs I maintain";

  inputs = {
    # keep-sorted start
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # keep-sorted end
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem = {
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            keep-sorted.enable = true;
            nixfmt.enable = true;
            prettier.enable = true;
          };
        };
      };
    };
}
