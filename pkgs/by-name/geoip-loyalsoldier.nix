{
  stdenvNoCC,
  lib,
  fetchurl,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "geoip-loyalsoldier";
  version = "202608200014";

  src = fetchurl {
    url = "https://github.com/Loyalsoldier/geoip/releases/download/${finalAttrs.version}/Country.mmdb";
    hash = "sha256-4QZ+UDzeiZ4vT1hLxsX9e70/SaN06j6047F92lplTzI=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/clash/Country.mmdb

    runHook postInstall
  '';

  dontFixup = true;

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--flake" ]; };
    mmdb = "${finalAttrs.finalPackage}/share/clash/Country.mmdb";
  };

  meta = {
    description = "Enhanced edition of V2Ray rules dat files";
    homepage = "https://github.com/Loyalsoldier/geoip";
    license = with lib.licenses; [
      cc-by-40
      gpl3Plus
    ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})
