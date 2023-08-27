{
  description = "My overrides on nixpkgs";

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs

  inputs.nixpkgs.url = "nixpkgs"; # = nixpkgs-unstable
  # GF-packages: anka-213/cclaw-nix-stuff

  # The flake in the current directory.
  # inputs.currentDir.url = ".";

  outputs = all@{ self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "x86_64-darwin" ];
      # systems = [ "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      overlays = import ./overlays.nix;
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = overlays;
        }
      );
    in
    {
      packages = forAllSystems (system: let myPkgs = nixpkgsFor.${system}; in {
        # inherit (nixpkgsFor.${system}) stan;
        inherit (nixpkgsFor.${system}) binwalk-full;
        inherit (nixpkgsFor.${system}) unison-ucm;
        # rstudioEnv = super.rstudioWrapper.override {
        rEnv = myPkgs.rWrapper.override {
            packages = with myPkgs.rPackages; [
                tidyverse
                dplyr
                fuzzyjoin
                random
                rjson
                Rcpp
                # ggplot2
                # reshape2
                ];
        };
      });

      legacyPackages = nixpkgsFor;

      # # Default overlay, for use in dependent flakes
      # overlay = final: prev: { };

      # # # Same idea as overlay but a list or attrset of them.
      # overlays = { exampleOverlay = self.overlay; };


      # # Used with `nixos-rebuild --flake .#<hostname>`
      # # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation
      # nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [{ boot.isContainer = true; }];
      # };

      # # Utilized by `nix develop`
      # devShell.x86_64-linux = rust-web-server.devShell.x86_64-linux;

      # # Utilized by `nix develop .#<name>`
      # devShells.x86_64-linux.example = self.devShell.x86_64-linux;

    };
}
