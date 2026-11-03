{
  fetchFromGitHub,
  fetchPnpmDeps,
  lib,
  nix-update-script,
  nodejs_24,
  pnpm_11,
  pnpmConfigHook,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jellyfin-vue";
  version = "0.3.1-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-vue";
    rev = "99ad28bb32f939d34160fc37406ecfa00d30c3c4";
    hash = "sha256-vsXdcEXzdZdXE8VbHq3U1y79gQ9Fd1Zixhrt3bad7vY=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-So8p9vSz/m19ERMnzsCe94wiXWazk1sk9tJjI4+N5mI=";
  };

  nativeBuildInputs = [
    nodejs_24
    pnpm_11
    pnpmConfigHook
  ];

  env = {
    COMMIT_HASH = finalAttrs.src.rev;
    IS_STABLE = 0;
  };

  buildPhase = ''
    runHook preBuild

    pnpm --filter @jellyfin-vue/frontend build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -a packages/frontend/dist $out/share/jellyfin-vue

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = {
    description = "Experimental web client for Jellyfin built with Vue.js";
    homepage = "https://github.com/jellyfin/jellyfin-vue";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
