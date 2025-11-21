# default.nix
{
  pkgs ? import <nixpkgs> {},
  python ? pkgs.python313,
  nodejs ? pkgs.nodejs_24,
}: let
  pyPkgs = python.pkgs;

  # Ajusta esta línea según tu nixpkgs:
  # suele ser nodePackages o nodePackages_latest
  mermaidCli = nodejs.pkgs."@mermaid-js/mermaid-cli";
in
  pyPkgs.buildPythonPackage {
    pname = "mermaidxform-mkdocs-plugin";
    version = "0.1.0";

    src = ./src;
    format = "setuptools";

    # Ya no necesitamos nada aquí de Node
    nativeBuildInputs = [];

    propagatedBuildInputs =
      # deps de Python que quieres propagar
      (with pyPkgs; [
        mkdocs
        mkdocs-material
      ])
      ++
      # deps del sistema que también deben propagarse
      (with pkgs; [
        dejavu_fonts
        fontconfig
        fontconfig
        fontconfig.bin
        fontconfig.out
        google-fonts
        liberation_ttf
        noto-fonts
        noto-fonts-color-emoji
      ])
      ++ [
        mermaidCli
        nodejs
      ]
      ++ pkgs.lib.optional (pkgs.stdenv.isLinux) pkgs.chromium;

    doCheck = false;

    meta = with pkgs.lib; {
      description = "MkDocs plugin for Mermaid diagrams transformation";
      homepage = "https://example.com";
      license = licenses.mit;
      maintainers = [];
    };
  }
