{ inputs, config, pkgs, lib, ... }:

let
  geopkgs = inputs.geonix.packages.${pkgs.system};

in
{
  packages = [
    geopkgs.geonixcli
    pkgs.fswatch
  ];

  scripts.make-package-files.exec = ''
    nixpkgs_version=$(nix flake metadata --json github:imincik/geospatial-nix \
      | jq --raw-output '.locks.nodes.nixpkgs.locked.rev')

    python_version=$(echo ${pkgs.python3.pythonVersion} | sed 's|\.||')

    postgresql_version=$(echo ${pkgs.postgresql.version} | sed 's|\..*||')


    packages_file="src/GeoPackages.elm"
    echo "module GeoPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json github:imincik/geospatial-nix  \
      --exclude "all-packages" \
      --exclude "geonix-base-image" \
      --exclude "geonixcli" \
      --exclude "unwrapped" \
      --exclude "postgresql." \
      --exclude "python.*" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|packages\.x86_64-linux\.|geopkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/Packages.elm"
    echo "module Packages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json nixpkgs/$nixpkgs_version  \
      --exclude "postgresql.*Packages" \
      --exclude "python.*Packages" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/GeoPythonPackages.elm"
    echo "module GeoPythonPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json github:imincik/geospatial-nix  \
      "python3-" \
      --exclude "all-packages" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|packages\.x86_64-linux\.|geopkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/PythonPackages.elm"
    echo "module PythonPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json nixpkgs/$nixpkgs_version \
      python''${python_version}Packages \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
      | sed 's|python3..Packages|python3Packages|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/GeoPostgresqlPackages.elm"
    echo "module GeoPostgresqlPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json github:imincik/geospatial-nix  \
      "postgresql_''${postgresql_version}" \
      --exclude "all-packages" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|packages\.x86_64-linux\.|geopkgs\.|g' \
      | sed 's|postgresql_..|postgresql|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file

    
    packages_file="src/PostgresqlPackages.elm"
    echo "module PostgresqlPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json nixpkgs/$nixpkgs_version \
      postgresql''${postgresql_version}Packages \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
      | sed 's|postgresql..Packages|postgresqlPackages|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file
  '';

  scripts.develop-elm-site.exec = ''
    fswatch -o src/HomePage.elm | xargs -I{} elm make src/HomePage.elm --output src/elm.js
  '';

  scripts.make-elm-site.exec = ''
    elm make src/HomePage.elm --output src/elm.js
  '';

  scripts.make-elm-site-prod.exec = ''
    elm make src/HomePage.elm --optimize --output src/elm.js
  '';
  
  languages.elm.enable = true;

  pre-commit.hooks = {
    elm-format = {
      enable = true;
    };

    elm-make = {
      enable = true;
      name = "elm-make";
      description = "Run elm-make";
      pass_filenames = false;
      entry = "${lib.getExe pkgs.elmPackages.elm} make src/HomePage.elm --output src/elm.js";
    };
  };
}
