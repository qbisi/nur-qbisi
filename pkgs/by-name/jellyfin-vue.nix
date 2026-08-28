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
  version = "0.3.1-unstable-2026-08-28";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-vue";
    rev = "52fedc6f10dd1746ad5ce41337d88319daf68974";
    hash = "sha256-RAl+k3Q3UDu2lG6hTlMBAqaK8ceWxmC25yXiMN4a02w=";
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
