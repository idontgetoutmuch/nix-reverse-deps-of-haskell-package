let
  myHaskellPackageOverlay = self: super: {
    myHaskellPackages = super.haskellPackages.override {
    overrides = hself: hsuper: rec {
        mkDerivation = args: hsuper.mkDerivation (args // {
          doCheck = false;
          doHaddock = false;
          jailbreak = true;
        });
      random =
          let newRandomSrc = builtins.fetchGit {
                url = "https://github.com/idontgetoutmuch/random.git";
                rev = "023e812545d2fac849ae64058d64590a63d2fe89";
                ref = "avoid-name-clash";
              };
          in
            super.haskell.lib.dontCheck ((import <nixpkgs> {}).haskellPackages.callCabal2nix "random" newRandomSrc { });
      splitmix = super.haskell.lib.dontCheck (
        super.haskell.lib.doJailbreak (
          hself.callCabal2nix "splitmix" (builtins.fetchGit {
            url = "https://github.com/idontgetoutmuch/splitmix-1.git";
            rev = "1822b43149cd11ef4e5a0c1b2099b454cb0e6790";
            ref = "master";
          }) { }));
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
