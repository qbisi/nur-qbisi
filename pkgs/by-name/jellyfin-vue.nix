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
  version = "0.3.1-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-vue";
    rev = "f330ab9915816677743c49c9bec602d5f092526d";
    hash = "sha256-WEQFZe4C+zWw9PkZemXeMR1Mq0BWrGfXG4rRO3HiNbM=";
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
