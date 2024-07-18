[
  # ( # TODO: This style of haskell overlay conflicts with the one below
  #   let
  #   # Pin all-hies
  #   all-hies = fetchTarball {
  #     # Insert the desired all-hies commit here
  #     url = "https://github.com/infinisil/all-hies/tarball/b8fb659620b99b4a393922abaa03a1695e2ca64d";
  #     # Insert the correct hash after the first evaluation
  #     sha256 = "0br6wsqpfk1lzz90f7zw439w1ir2p54268qilw9l2pk6yz7ganfx";
  #   };
  #   in
  #   (import all-hies {}).overlay
  # )

  # (self: super: {
  #   nix-index = super.nix-index.override {};
  # })

  (self: super:
    let
      # Extract the bin directory to avoid conflict between haskellPackages
      # This still depends on lib, but has the advantage of not needing to
      # recompile the package
      onlyBin = pkg:
        super.buildEnv {
          name = "${pkg.name}";
          paths = [ pkg ];
          pathsToLink = [ "/bin" "/share" ];
        };
      gf-core = fetchTarball {
        # insert the desired all-hies commit here
        url = "https://github.com/anka-213/gf-core/archive/nix-support.tar.gz";
        # insert the correct hash after the first evaluation
        sha256 = "1gxaxbkb98xl4mlxs9i8sykcgyvjw2zv3l9whzvzvxwwhwj2jn0k";
      };
    in
    {
      gf = onlyBin (import gf-core { nixpkgs = super; });
      # agdaPackages = super.agdaPackages.override {
      #   Agda = self.haskellStatic.Agda;
      # };
      myAgda = with self.agdaPackages;
        self.agda.withPackages [ standard-library cubical ];

    })
  (self: super:
    let
      onlyBin = pkg:
        super.buildEnv {
          name = "${pkg.name}";
          paths = [ pkg ];
          pathsToLink = [ "/bin" "/share" ];
        };
    in
    let
      haskellOverrides = pkgs:
        with pkgs.haskellLib; {
          overrides = hself: hsuper: {
            # agda-bin = pkgs.haskell.lib.enableSeparateBinOutput hsuper.Agda;
            # retrie = pkgs.haskell.lib.dontCheck hsuper.retrie;
            # retrie = hsuper.retrie.override (drv: {
            # generateOptparseApplicativeCompletions
            retrie = (enableSeparateBinOutput (overrideCabal hsuper.retrie
              (drv: {
                testToolDepends = drv.testToolDepends or [ ]
                  ++ [ self.mercurial self.git ];
                broken = false;
              })));
            retrie-bin = generateOptparseApplicativeCompletions [ "retrie" ]
              (justStaticExecutables (dontCheck (markUnbroken hsuper.retrie)));
            myPkgs = pkgs;
            # duet = overrideCabal hsuper.duet (drv: {
            #   src = fetchTarball {
            #      url = "https://github.com/chrisdone/duet/archive/959d40db68f4c2df04cabb7677724900d4f71db4.tar.gz";
            #      sha256 = "05fza01r5bdsj430fiyhcs0lznzs45wfwkjjjqalz1ax5llrx4yv";
            #   };
            #   broken = false;
            # });
            # nix-shell -p "haskellPackages.ghcWithPackages (pkg: with pkg;[ (haskell.lib.doJailbreak fadno-xml) ])"
          };
        };
    in
    {
      binwalk-full = with self.python3Packages;
        toPythonApplication
          (binwalk-full.overridePythonAttrs { doCheck = false; });
      duet = super.haskell.lib.justStaticExecutables self.haskellPackages.duet;
      qutebrowser = self.libsForQt5.callPackage (./qutebrowser) { };
      agda-bin =
        super.haskell.lib.enableSeparateBinOutput super.haskellPackages.Agda;
      agda-low = super.lowPrio super.haskellPackages.Agda;
      # agda = super.haskellPackages.Agda;
      haskellPackages = super.haskellPackages.override haskellOverrides;
      wine = super.wine.override {
        vaSupport = false;
        v4lSupport = false;
      };
      stan = super.haskell.lib.justStaticExecutables super.haskellPackages.stan;
      hoogle = onlyBin super.haskellPackages.hoogle;
      # retrie = generateOptparseApplicativeCompletions i;
      retrie = self.haskellPackages.retrie-bin;
      # Avoids conflicts when installing. Full closure size, but doesn't require rebuilding
      haskellBin = builtins.mapAttrs (k: v: onlyBin v) self.haskellPackages;
      # Only the binaries, not the libraries
      haskellStatic =
        builtins.mapAttrs (k: v: super.haskell.lib.justStaticExecutables v)
          self.haskellPackages;
      # retrie = super.haskell.lib.generateOptparseApplicativeCompletions ["retrie"] self.haskellPackages.retrie.bin;
    })
  # (self: super: {
  #   haskellPackages = super.recurseIntoAttrs super.haskellPackages;
  # })
  (self: super: {
    unison-ucm = super.unison-ucm.overrideAttrs (super: rec {
      milestone_id = "M4b";
      version = "1.0.${milestone_id}-alpha";

      src =
        if (self.stdenv.isDarwin) then
          self.fetchurl
            {
              url =
                "https://github.com/unisonweb/unison/releases/download/release/${milestone_id}/ucm-macos.tar.gz";
              sha256 = "sha256-UjN1LDknPwAs1ci4HjflymlXBbm8D9d3lPAnoXPnWdY=";
            }
        else
          self.fetchurl {
            url =
              "https://github.com/unisonweb/unison/releases/download/release/${milestone_id}/ucm-linux.tar.gz";
            sha256 = "sha256-9XDVOpYhduhBtFqnMNtRPElsp88tKK3JmIGXORiTFFU=";
          };

    });
  })
  (self: super: {
    go-fuse-version = self.callPackage ./go-fuse-version.nix { };
  })
  (self: super: {
    nix-closure-graph = self.callPackage ./nix-closure-graph.nix { };
  })
  # (self: super: {
  #   gdb-codesigned = gdb;
  # })
  (self: super: {
    # Haskell 'go to (non-local)* definitions' VS Code extension
    haskell-gtd-nl =
      let inherit (self.haskellPackages) callCabal2nix;
        inherit (self.haskell.lib) justStaticExecutables doJailbreak dontCheck;
        don'tJailbreak = x: x;
      in
      justStaticExecutables (dontCheck (doJailbreak (callCabal2nix "haskell-gtd-nl"
        (
          self.fetchFromGitHub {
            owner = "kr3v";
            repo = "haskell-gtd-nl";
            rev = "d5650e4ba3f85b430ea8339d75284dc812c28226";
            sha256 = "sha256-hWT7nFcjR3pfb7I/auxdl+3Gi5xk++nBW40ipo1eHOw=";
          }
        )
        {
          ghc-lib-parser = self.haskellPackages.ghc-lib-parser_9_6_2_20230523;
        })));
  })
  (self: super: {
    command-not-found-fish = self.writeShellScriptBin "cnf_fish.sh" ''
      source ${self.nix-index}/etc/profile.d/command-not-found.sh
      command_not_found_handle $@
    '';
  })
]
