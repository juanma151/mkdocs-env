{
  pkgs ? import <nixpkgs> {},
  nodePkgs ? pkgs.nodePackages,
}: let
  # ========== IMPORTAR PAQUETES INTERNOS ==========
  mermaidPlaywrightCliSet = pkgs.callPackage ./pkgs/mermaid-playwright-cli/default.nix {
    inherit pkgs nodePkgs;
  };

  # ========== FUSIONAR TODOS LOS SETS DE PAQUETES ==========
  exports_ =
    {}
    // mermaidPlaywrightCliSet;

  exports = pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) exports_;
in
  exports
