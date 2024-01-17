{ inputs, config, pkgs, lib, ... }:

let
  geopkgs = inputs.geonix.packages.${pkgs.system};

in {
  packages = [
    geopkgs.geonixcli
    pkgs.fswatch
  ];

  scripts.make-elm-site.exec = ''
    elm make src/HomePage.elm --output src/elm.js
  '';

  scripts.develop-elm-site.exec = ''
    fswatch -o src/HomePage.elm | xargs -I{} elm make src/HomePage.elm --output src/elm.js
  '';

  languages.elm.enable = true;
}
