{ projectSrc ? { outPath = ./.; }
, config ? {
    inHydra = true;
  }
, supportedSystems ? [ "x86_64-darwin" "x86_64-linux" ]
, scrubJobs ? true
, sourcesOverride ? { }
}:
let

  localLib = import nix/default.nix { inherit sourcesOverride; };

in
with import (localLib.fixedNixpkgs + "/pkgs/top-level/release-lib.nix")
{
  inherit supportedSystems scrubJobs;
  packageSet = import projectSrc;
  nixpkgsArgs = {
    inherit config;
  };
};

# Notes:
#
# From this point onward, `pkgs` contains all the attributes defined
# in our project's top-level default.nix: `tests`, `checks`, `shell`,
# etc.
let
  x86_64 = [ "x86_64-linux" "x86_64-darwin" ];
  x86_64_linux = [ "x86_64-linux" ];
  linux = [ "x86_64-linux" ];
  jobs = { native = mapTestOn (packagePlatforms pkgs); };
in
jobs
