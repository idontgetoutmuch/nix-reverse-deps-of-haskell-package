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

in

{ nixpkgs ? import <nixpkgs> { overlays = [ myHaskellPackageOverlay ]; }, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, base, pcg-random, QuickCheck, random, splitmix, stdenv }:
      mkDerivation {
        pname = "nix-reverse-deps-of-haskell-package";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [ base pcg-random QuickCheck random splitmix ];
        license = stdenv.lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.myHaskellPackages
                       else pkgs.myHaskellPackages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
