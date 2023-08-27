{
  description = "Packages for steam deck";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-darwin";
      # system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      bclm = pkgs.python3Packages.buildPythonApplication rec {
        pname = "bclm";
        version = "3.10.8";
        src = pkgs.python3Packages.fetchPypi {
          inherit pname version;
          sha256 = "sha256-0000000000000000000000000000000000000000000";
        };
        doCheck = false;
        propagatedBuildInputs = [
          # Specify dependencies
          # pkgs.python3Packages.numpy
        ];
      };
    in
    {

      packages.${system} = {
        bclm = bclm;
        default = self.packages.${system}.bclm;
      };
    };
}
