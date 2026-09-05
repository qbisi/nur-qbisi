{
  stdenvNoCC,
  lib,
  fetchurl,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "geoip-loyalsoldier";
  version = "202609040655";

  src = fetchurl {
    url = "https://github.com/Loyalsoldier/geoip/releases/download/${finalAttrs.version}/Country.mmdb";
    hash = "sha256-AxvW6N/WLXC4HS1lzlSpLtfyHwYK3RfGbhaioOVdOkE=";
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
