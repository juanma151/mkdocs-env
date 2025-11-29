{
  pkgs ? import <nixpkgs> {},
  python ? pkgs.python313,
  mermaidPlaywrightCli ? null,
}: let
  ## prepare the cli
  mermaidCli =
    if builtins.isNull mermaidPlaywrightCli
    then
      (
        if pkgs ? mermaidPlaywrightCli
        then pkgs.mermaidPlaywrightCli
        else null
      )
    else mermaidPlaywrightCli;

  # Python packages
  pythonPkgs = python.pkgs;

  ##
  mermaidXformMkdocsPlugin = pythonPkgs.buildPythonPackage {
    pname = "mermaid-xform-mkdocs-plugin";
    version = "1.0.0";

    # Código del plugin (incluye setup.py y la carpeta src/)
    src = ./src;

    # IMPORTANTE → usar setuptools en lugar del sistema PEP517
    format = "setuptools";

    # Necesario si quieres que Nix ejecute setup.py correctamente
    nativeBuildInputs = [
      pythonPkgs.setuptools
    ];

    # Dependencias del plugin
    propagatedBuildInputs =
      [
        pythonPkgs.mkdocs
        pythonPkgs.mkdocs-material
      ]
      ++ pkgs.lib.optional (! builtins.isNull mermaidCli) mermaidCli;

    # No hay tests
    doCheck = false;

    pythonImportsCheck = ["mermaidxform_mkdocs_plugin"];
  };

  ## shell
  mermaidXformMkdocsPluginShell = pkgs.mkShell {
    name = "mermaid-xform-mkdocs-plugin-shell";
    version = "1.0.0";
    buildInputs = [
      mermaidXformMkdocsPlugin
      python
    ];

    shellHook = ''
      echo "Entorno cargado:"
      echo "  - Plugin Mermaid XForm"
      echo "  - Ejecutable mmdc-pw disponible en PATH"
      echo "  - mkdocs listo para usar"
    '';
  };
in {
  inherit mermaidXformMkdocsPlugin mermaidXformMkdocsPluginShell;
}
