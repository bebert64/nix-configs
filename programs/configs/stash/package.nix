{
  lib,
  stdenv,
  fetchurl,
}:
let
  version = "0.27.2";
  sources = {
    url = "https://github.com/stashapp/stash/releases/download/v${version}/stash-linux-arm64v8";
    hash = "sha256-Rb4x6iKx6T9NPuWWDbNaz+35XPzLqZzSm0psv+k2Gw4=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;

  pname = "stash";

  src = fetchurl { inherit (sources) url hash; };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/stash

    runHook postInstall
  '';

  meta = with lib; {
    description = "Stash is a self-hosted porn app";
    homepage = "https://github.com/stashapp/stash";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ Golo300 ];
    platforms = builtins.attrNames sources;
    mainProgram = "stash";
  };
})
