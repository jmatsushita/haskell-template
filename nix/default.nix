{ system ? builtins.currentSystem
, crossSystem ? null
, config ? { }
, sourcesOverride ? { }
, overlays ? [ ]
}:
let
  sources = import ./sources.nix // sourcesOverride;

  fixedHacknix =
    let try = builtins.tryEval <hacknix>;
    in
    if try.success then
      builtins.trace "Using <hacknix>" try.value
    else
      sources.hacknix;

  hacknix = import fixedHacknix {
    inherit system crossSystem config sourcesOverride;
  };
  inherit (hacknix) lib;
  inherit (lib.fetchers) fixedNixpkgs;
  inherit (lib.hacknix) nixpkgs;

  localOverlays = hacknix.overlays.all
    ++ (
    map import [
    ]
  ) ++ overlays;

  pkgs = nixpkgs {
    overlays = localOverlays;
    inherit system crossSystem;
    inherit config;
  };

  fixedHaskellHacknix = lib.fetchers.fixedNixSrc "haskell-hacknix" sources.haskell-hacknix;
  haskellHacknix = import fixedHaskellHacknix {
    inherit system crossSystem config sourcesOverride;
  };
  haskellPkgs = haskellHacknix.pkgs;

  fixedNixPreCommitHooks = lib.fetchers.fixedNixSrc "pre-commit-hooks" sources.pre-commit-hooks;
  nix-pre-commit-hooks = import fixedNixPreCommitHooks;

  self = {
    inherit sources;
    inherit fixedNixpkgs;

    inherit pkgs;
    inherit haskellPkgs;

    inherit nix-pre-commit-hooks;
  };
in
self
