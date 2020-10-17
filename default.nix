{ system ? builtins.currentSystem
, crossSystem ? null
, config ? { }
, sourcesOverride ? { }
, overlays ? [ ]
, localLib ? import ./nix/default.nix {
    inherit system crossSystem config sourcesOverride overlays;
  }
}:
let
  inherit (localLib) pkgs haskellPkgs;

  haskell-template = pkgs.recurseIntoAttrs (import ./haskell-template/default.nix {
    # haskell-template is a Haskell project. Therefore, we use the
    # special haskellPkgs package set to build it.
    pkgs = localLib.haskellPkgs;
  });

  source-code-checks = localLib.nix-pre-commit-hooks.run rec {
    src = ./.;
    hooks = {
      hlint.enable = true;
      ormolu.enable = true;
      cabal-fmt.enable = true;
      nixpkgs-fmt.enable = true;
    };

    # Override the default nix-pre-commit-hooks tools with the version
    # we're using in shells.
    tools = {
      inherit (haskellPkgs.haskell-hacknix.haskell-tools) hlint ormolu cabal-fmt;
      inherit (pkgs) nixpkgs-fmt;
    };
  };

  self = {
    inherit haskell-template;
    inherit source-code-checks;
  };
in
self
