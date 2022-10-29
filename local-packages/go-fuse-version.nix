{ lib
, buildGoPackage
, fetchFromGitHub
, fuse
}:

buildGoPackage rec {
  pname = "go-fuse-version";
  version = "0.0.1";

  goPackagePath = "github.com/jbenet/go-fuse-version/fuse-version";
  buildInputs = [ fuse ];
  CGO_CFLAGS="-I${fuse}/include";

  src = fetchFromGitHub {
    owner = "jbenet";
    repo = "go-fuse-version";
    rev = "6d4c97bcf25310eb1652d13f26aac5d7c7ec37f7";
    sha256 = "NLiArOZmGoCyVWP7AHeSMTuAA+e5bkda5gHuFMP3l1Y=";
  };


  meta = with lib; {
    description = "Check version of fuse";
    homepage = "https://github.com/jbenet/go-fuse-version/fuse-version";
  };
}
