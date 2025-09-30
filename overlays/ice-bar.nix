final: prev: {
  ice-bar = prev.ice-bar.overrideAttrs (old: {
    version = "0.11.13-dev.2";
    src = final.fetchurl {
      url = "https://github.com/jordanbaird/Ice/releases/download/0.11.13-dev.2/Ice.zip";
      sha256 = "sha256-wbuqcfYev+Xuko95CvYJY6nyAjZNY/eNLGs+xRBc9KA="; # nix store prefetch-file https://github.com/jordanbaird/Ice/releases/download/0.11.13-dev.2/Ice.zip
    };
  });
}
