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
  version = "0.3.1-unstable-2026-08-11";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-vue";
    rev = "6b35d977335cab224c4536d18dc22d15a63d5185";
    hash = "sha256-NBCSOqaUbwC87hFvzzogDRT3o1Rc3Nzze8ulQ6R8F4A=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-KaYnbpl+VGbpu4DwftcO3+zpV+nWBJZQgPqfruzehlk=";
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
