{ lib, stdenvNoCC, fetchFromGitHub, makeWrapper, jq, graphviz }:

stdenvNoCC.mkDerivation rec {
  pname = "nix-closure-graph";
  version = "2022-10-05";

  src = fetchFromGitHub {
    owner = "lf-";
    repo = "dotfiles";
    rev = "b4a7068429a69d6d0d360ac33c1c39d6d107a4b2";
    hash = "sha256-sfqa3llQCJaLSa8bS9yxT/hSxpH0LHx/HCrhzdQ8iR4=";
  } + "/programs/nix-closure-graph";

  buildInputs = [ ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    patchShebangs nix-closure-graph

    substituteInPlace nix-closure-graph \
      --replace '"$(dirname -- "$(realpath -- "''${BASH_SOURCE[0]}")")"' '${src}' \
      --replace ' jq ' ' ${jq}/bin/jq ' \
      --replace ' dot ' ' ${graphviz}/bin/dot '


    mkdir -p $out/bin
    cp nix-closure-graph $out/bin/
  '';

  meta = with lib; {
    description = "Draw a graph of a nix closure";
    homepage = "https://github.com/lf-/dotfiles/programs/nix-closure-graph";
    license = licenses.mit;
    maintainers = [ ];
  };
}
