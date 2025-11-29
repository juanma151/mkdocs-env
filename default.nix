{
  pkgs ? import <nixpkgs> {},
  nodePkgs ? pkgs.nodePackages,
  python ? pkgs.python313,
}: let
  # ========== IMPORTAR PAQUETES INTERNOS ==========
  mermaidPlaywrightCliSet = pkgs.callPackage ./pkgs/mermaid-playwright-cli/default.nix {
    inherit pkgs nodePkgs;
  };

  mermaidXformMkdocsPluginSet = pkgs.callPackage ./pkgs/mermaid-xform-mkdocs-plugin/default.nix {
    inherit pkgs python;
    inherit (mermaidPlaywrightCliSet) mermaidPlaywrightCli;
  };

  # ========== SHELL ==========
  mkdocsEnvSet = {
    mkdocsEnv = pkgs.mkShell {
      name = "mkdocs customized environment";
      version = "1.0.0";
      packages = [
        mermaidPlaywrightCliSet.mermaidPlaywrightCli
        mermaidXformMkdocsPluginSet.mermaidXformMkdocsPlugin
      ];
    };
  };

  # ========== FUSIONAR TODOS LOS SETS DE PAQUETES ==========
  exports_ =
    {}
    // mermaidPlaywrightCliSet
    // mermaidXformMkdocsPluginSet
    // mkdocsEnvSet;

  exports = pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) exports_;
in
  exports
