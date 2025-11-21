# flake.nix (en la raíz)
{
  description = "Utilidades MkDocs + plugin mermaidxform-mkdocs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      python = pkgs.python313;
      nodejs = pkgs.nodejs_24;

      # Llamamos al default.nix de la raíz,
      # que a su vez resuelve el plugin desde su default.nix
      super = pkgs.callPackage ./default.nix {
        inherit python nodejs;
      };
    in {
      # lib
      lib.buildMkdocsEnv = super.buildMkdocsEnv;
      lib.buildMkdocsShell = super.buildMkdocsShell;

      # Paquetes
      packages.mkdocs-env = super.mkdocsEnv;
      packages.mermaidxform-mkdocs-plugin = super.mermaidPlugin;
      packages.default = super.mkdocsEnv;

      # DevShells
      devShells.mkdocs = super.mkdocsShell;
      devShells.default = super.mkdocsShell;
    });
}
