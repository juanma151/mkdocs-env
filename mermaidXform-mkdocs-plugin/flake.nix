{
  description = "Flake para mermaidxform-mkdocs-plugin";

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

      mermaidxform-mkdocs-plugin = pkgs.callPackage ./default.nix {
        inherit python nodejs;
      };
    in {
      #########################
      # Paquete por defecto   #
      #########################
      packages.default = mermaidxform-mkdocs-plugin;

      #####################################
      # Shell de desarrollo
      #####################################
      devShells.default = pkgs.mkShell {
        packages = [
          (python.withPackages (ps: [
            mermaidxform-mkdocs-plugin
            ps.mkdocs
            ps.mkdocs-material
          ]))
          # Si quieres tener también mmdc a mano sin propagarlo:
          # pkgs.nodejs_22
          # pkgs.nodePackages_latest.mermaid-cli
        ];
      };

      #####################################
      # (Opcional) exponerlo como "lib"   #
      #####################################
      lib.pythonModule = mermaidxform-mkdocs-plugin;
    });
}
