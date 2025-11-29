{
  pkgs ? import <nixpkgs> {},
  nodePkgs ? pkgs.nodePackages,
}: let
  # Linux: use Playwright portable Chromium
  # macOS: use system-installed Google Chrome
  chromiumPath =
    if pkgs.stdenv.isLinux
    then let
      pwBrowsers = pkgs.playwright-driver-browsers;
    in "${pwBrowsers.chromium}/chromium/chrome"
    else if pkgs.stdenv.isDarwin
    then "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    else throw "Unsupported system for Playwright Chromium";

  # Mermaid CLI
  mermaidCli = nodePkgs.mermaid-cli;

  mermaidPlaywrightCli = pkgs.stdenv.mkDerivation {
    pname = "mermaid-playwright-cli";
    version = "1.0";

    nativeBuildInputs = [pkgs.makeWrapper];
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin

      makeWrapper ${mermaidCli}/bin/mmdc $out/bin/mmdc-pw \
        --set PUPPETEER_SKIP_DOWNLOAD "true" \
        --set PUPPETEER_EXECUTABLE_PATH "${chromiumPath}" \
        --set CHROME_EXECUTABLE_PATH "${chromiumPath}"
    '';
  };
in {
  inherit mermaidPlaywrightCli;
}
