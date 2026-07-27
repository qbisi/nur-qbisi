# Package Set Template

This template defines packages through an overlay first, then exposes the
overlay-built attributes as flake packages.

It also works as a non-flake package set:

```nix
let
  pkgs = import ./. { };
in
pkgs.hello-template
```

## Layout

- `default.nix` imports nixpkgs with this repository's overlay applied.
- `flake-compat.nix` loads the flake outputs for non-flake evaluation.
- `.github/workflows/update-flake-packages.yml` enumerates the current system's
  `packages.${system}` output and attempts to update every package with
  `nix-update` every day without failing the workflow when an update fails.
- `pkgs/default.nix` defines `overlays.default`, `nixosModules.default`, and `legacyPackages`.
- `pkgs/by-name/<name>.nix` defines normal packages.
- `pkgs/python-by-name/<name>.nix` defines Python packages.

The NixOS module applies this flake's default overlay to `nixpkgs.overlays`.

Python packages are exposed in two places:

- `legacyPackages.<system>.python3Packages.<name>`
- `packages.<system>.python3-<name>`

Normal packages are exposed as:

- `legacyPackages.<system>.<name>`
- `packages.<system>.<name>`

## Binary cache builds

The `Build master` workflow runs after pushes to `master`, including changes
created by the package and nixpkgs update workflows. It enumerates and builds
every package under `packages.${system}` on native `x86_64-linux` and
`aarch64-linux` runners, then pushes newly built store paths to Cachix.

Create the `cachix` environment under **Settings → Environments**, then define:

- environment variable `CACHIX_CACHE_NAME`: the cache name without the
  `.cachix.org` suffix;
- environment secret `CACHIX_AUTH_TOKEN`: a token with write access to that
  cache.
