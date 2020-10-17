{ system ? builtins.currentSystem
, crossSystem ? null
, config ? { }
, sourcesOverride ? { }
, overlays ? [ ]
, pkgs ? (import ../nix/default.nix {
    inherit system crossSystem config sourcesOverride overlays;
  }).haskellPkgs
}:
let
  inherit (pkgs.haskell-hacknix.lib)
    collectTests collectChecks filterByPrefix;

  inherit (pkgs.haskell-hacknix)
    cabalProject cache shellFor;

  src = pkgs.gitignoreSource ../.;

  isLocalPackage = filterByPrefix "haskell-template";

  mkSet = args':
    let
      args = {
        inherit src;
        subdir = "haskell-template";
      } // args';
      haskellPackages = cabalProject args;
      shell = shellFor haskellPackages args;
      cachedShell = cache shell;
      tests = collectTests isLocalPackage haskellPackages;
      checks = collectChecks isLocalPackage haskellPackages;
    in
    pkgs.recurseIntoAttrs {
      inherit haskellPackages shell cachedShell tests checks;
    };

  mkProfiledSet = args: mkSet ({
    enableLibraryProfiling = true;
    enableExecutableProfiling = true;
  } // args);

  ghc865Args = {
    compiler-nix-name = "ghc865";
  };
  ghc865 = mkSet ghc865Args;
  ghc865-profiled = mkProfiledSet ghc865Args;

  ghc884Args = {
    compiler-nix-name = "ghc884";
  };
  ghc884 = mkSet ghc884Args;
  ghc884-profiled = mkProfiledSet ghc884Args;

  ghc8102Args = {
    compiler-nix-name = "ghc8102";
  };
  ghc8102 = mkSet ghc8102Args;
  ghc8102-profiled = mkProfiledSet ghc8102Args;

in
{
  inherit ghc865 ghc865-profiled;
  inherit ghc884 ghc884-profiled;
  inherit ghc8102 ghc8102-profiled;
}
