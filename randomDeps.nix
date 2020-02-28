let
  pkgs = import <nixpkgs> {};
  myHaskellPackageOverlay = self: super: {
    haskellPackages = super.haskellPackages.override {
      overrides = hself: hsuper: {
        mkDerivation = args: hsuper.mkDerivation (args // {
          doCheck = false;
          doHaddock = false;
          jailbreak = true;
        });
        random = pkgs.haskellPackages.callCabal2nix "random" (
            self.fetchFromGitHub {
              owner = "idontgetoutmuch";
              repo = "random";
              rev = "023e812545d2fac849ae64058d64590a63d2fe89";
              sha256 = "1yfmc766jki1s0pr4hrp29ngfyxznz71vg303b7hrvin411q8w4l";
              }) { };
      };
    };
  };

  nixpkgs = import <nixpkgs> { overlays = [ myHaskellPackageOverlay ]; };

in

# This example derivation file is assumed to be in the current directory.  "./default.nix" is
# the current file you are looking at.
import ./default.nix {
  reverseDepsOf = "random";
  inherit nixpkgs;
}
