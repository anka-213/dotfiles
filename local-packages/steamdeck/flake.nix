{
  description = "Packages for steam deck";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      bclm = pkgs.buildPythonApplication rec {
        pname = "bclm";
        version = "3.10.8";
        src = pkgs.fetchPypi {
          inherit pname version;
          sha256 = "sha256-00000000000000000000000000000000000000000000";
        };
        doCheck = false;
        propagatedBuildInputs = [
          # Specify dependencies
          # pkgs.python3Packages.numpy
        ];
      };
    in
    {

      packages.x86_64-linux.bclm = bclm;

      packages.x86_64-linux.default = self.packages.x86_64-linux.bclm;

    };
}
