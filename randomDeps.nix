let
  myHaskellPackageOverlay = self: super: {
    haskellPackages = super.haskellPackages.override {
      overrides = hself: hsuper: {
        random =
          let newRandomSrc = builtins.fetchGit {
                url = "https://github.com/idontgetoutmuch/random.git";
                rev = "83262ccd8a2d4b8f29b14c535b6bdf997bc7a497";
                ref = "interface-to-performance";
              };
          in
          # Since cabal2nix has a transitive dependency on random, we need to
          # get the callCabal2nix function from the normal haskellPackages that
          # is not being overridden.
          (import <nixpkgs> {}).haskellPackages.callCabal2nix "random" newRandomSrc { };
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
