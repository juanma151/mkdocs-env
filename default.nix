# buildMkdocs.nix
{
  pkgs ? import <nixpkgs> {},
  python ? pkgs.python313,
  nodejs ? pkgs.nodejs_24,
}: let
  pyPkgs = python.pkgs;
  mermaidCli = nodejs.pkgs."@mermaid-js/mermaid-cli";

  mkdocsWithPdf = pyPkgs.buildPythonPackage rec {
    pname = "mkdocs-with-pdf";
    version = "0.9.3";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-vaM3XXBA0biHHaF8bXHqc2vcpsZpYI8o7WJ3EDHS4MY=";
    };
    pyproject = true;
    build-system = with pyPkgs; [setuptools wheel];
    propagatedBuildInputs = with pyPkgs; [
      beautifulsoup4
      libsass
      lxml
      markdown
      mkdocs
      mkdocs-material
      pyyaml
      weasyprint
    ];
    doCheck = false;
  };

  mermaidPlugin =
    import ./mermaidXform-mkdocs-plugin {inherit pkgs python nodejs;};

  chromePath =
    if pkgs.stdenv.isDarwin
    then "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    else if pkgs.stdenv.isLinux
    then "${pkgs.chromium}/bin/chromium"
    else "";

  envline = key: val: "--set ${key} \"${val}\"";

  puppeteerConfig =
    if pkgs.stdenv.isDarwin || pkgs.stdenv.isLinux
    then [
      (envline "PUPPETEER_SKIP_DOWNLOAD" "true")
      (envline "PUPPETEER_EXECUTABLE_PATH" chromePath)
    ]
    else [];

  fontsConfig =
    if pkgs.stdenv.isDarwin
    then [
      (envline "FONTCONFIG_PATH" "${pkgs.fontconfig.out}/etc/fonts")
      (envline "FONTCONFIG_FILE" "${pkgs.fontconfig.out}/etc/fonts/fonts.conf")
      (envline "XDG_DATA_DIRS"
        "${pkgs.fontconfig.out}/share:${pkgs.fontconfig.out}/lib:${pkgs.google-fonts}/share:${pkgs.dejavu_fonts}/share")
    ]
    else [];

  envConfig = builtins.concatStringsSep " " (puppeteerConfig ++ fontsConfig);

  wrapline_nopdf = binFile: "wrapProgram $out/bin/${binFile} ${envConfig}";
  wrapline_pdf = binFile: "${wrapline_nopdf binFile} ${envline "ENABLE_PDF_EXPORT" "1"}";

  wrapline = pdf:
    if pdf
    then wrapline_pdf
    else wrapline_nopdf;

  wrapcommands = pdf: cmds:
    builtins.concatStringsSep "\n" (builtins.map (cmd: (wrapline pdf cmd)) cmds);

  wraptext = ''
    ${wrapcommands false ["mmdc" "mkdocs"]}
    ${wrapcommands true ["mkdocs-pdf"]}
  '';

  buildMkdocsEnv = {
    extraPython ? ps: [],
    extraSystem ? [],
  }: let
    pythonEnv = python.withPackages (ps:
      [mkdocsWithPdf mermaidPlugin]
      ++ (with ps; [
        beautifulsoup4
        libsass
        lxml
        markdown
        mkdocs
        mkdocs-material
        pip
        pymdown-extensions
        pyyaml
        setuptools
        weasyprint
        wheel
      ])
      ++ (extraPython ps));

    systemDeps =
      [mermaidCli]
      ++ (with pkgs; [
        dejavu_fonts
        fontconfig
        fontconfig.bin
        fontconfig.out
        google-fonts
        liberation_ttf
        noto-fonts
        noto-fonts-color-emoji
      ])
      ++ pkgs.lib.optional (pkgs.stdenv.isLinux) pkgs.chromium ++ extraSystem;

    mkdocsEnvBase = pkgs.buildEnv {
      name = "mkdocs-base-env";
      paths = [pythonEnv] ++ systemDeps;
      pathsToLink = ["/bin"];
    };
  in
    pkgs.stdenv.mkDerivation {
      pname = "mkdoc-env";
      version = "2.0";
      buildInputs = [pkgs.makeWrapper];
      unpackPhase = "true";

      installPhase = ''
        mkdir -p $out/bin
        cp -r ${mkdocsEnvBase}/bin/* $out/bin/

        ## Copy mkdocs into mkdocs-pdf to add the PDF variant
        cp ${mkdocsEnvBase}/bin/mkdocs $out/bin/mkdocs-pdf
      '';

      postFixup = wraptext;
    };

  buildMkdocsShell = {
    extraPython ? ps: [],
    extraSystem ? [],
  }: let
    pythonEnv = buildMkdocsEnv {inherit extraPython extraSystem;};
  in
    pkgs.mkShell {
      packages = [pythonEnv];
    };

  mkdocsEnv = buildMkdocsEnv {};

  mkdocsShell = pkgs.mkShell {
    packages = [mkdocsEnv];
  };
in {
  inherit buildMkdocsEnv buildMkdocsShell mkdocsEnv mkdocsShell mermaidPlugin;
}
