{
  description = "Monorepo for mermaid-playwright-cli and future packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        ########################################
        # BASE PACKAGES (PKGS, NODE, NODEPACKS)
        ########################################
        pkgs = import nixpkgs {inherit system;};

        # Best available nodejs binary
        nodejsBin =
          if pkgs ? nodejs_20
          then pkgs.nodejs_20
          else pkgs.nodejs;

        # Best available nodePackages set
        nodePkgs =
          if pkgs ? nodePackages_20
          then pkgs.nodePackages_20
          else if pkgs ? nodePackages
          then pkgs.nodePackages
          else pkgs.nodePackages_latest;

        ########################################
        # IMPORT MONOREPO TOP-LEVEL PACKAGE SET
        ########################################
        top = import ./default.nix {
          inherit pkgs nodePkgs;
        };
      in {
        ########################################
        # PACKAGES (nix build, nix profile install)
        ########################################
        packages =
          top
          // {
            default = top.mermaidPlaywrightCli;
          };

        ########################################
        # APPS (nix run)
        ########################################
        apps.default = {
          type = "app";
          program = "${top.mermaidPlaywrightCli}/bin/mmdc-pw";
          meta.description = "mmdc-pw: mermaid playwright cli";
        };

        ########################################
        # DEV SHELL (nix develop)
        ########################################
        devShells.default = pkgs.mkShell {
          packages = [
            top.mermaidPlaywrightCli
            nodejsBin
            pkgs.python3
          ];
        };
      }
    );
}
