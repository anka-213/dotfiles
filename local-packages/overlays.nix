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
  (self: super:
    let
      # Pin all-hies
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
    in {
      gf = onlyBin (import gf-core { nixpkgs = super; });
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
    in let
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
    in {
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
      haskellBin = builtins.mapAttrs (k: v: onlyBin v) self.haskellPackages;
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

      src = if (self.stdenv.isDarwin) then
        self.fetchurl {
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
    go-fuse-version = self.callPackage ./go-fuse-version.nix {} ;
  })

  (self: super: {
    command-not-found-fish = self.writeShellScriptBin "cnf_fish.sh" ''
      source ${self.nix-index}/etc/profile.d/command-not-found.sh
      command_not_found_handle $@
    '' ;
  })
]
