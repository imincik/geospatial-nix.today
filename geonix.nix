{ inputs, config, pkgs, lib, ... }:

let
  geopkgs = inputs.geonix.packages.${pkgs.system};

in
{
  packages = [ ];

  scripts.make-packages-db.exec = ''
    geonix_url="github:imincik/geospatial-nix/latest"
    nixpkgs_version="${inputs.geonix.inputs.nixpkgs.rev}"
    python_version=$(echo ${pkgs.python3.pythonVersion} | sed 's|\.||')
    postgresql_version=$(echo ${pkgs.postgresql.version} | sed 's|\..*||')


    packages_file="src/GRASSPackages.elm"
    echo "module GRASSPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      "^grass" \
      --exclude "grass-plugin.*" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|packages\.x86_64-linux\.|geopkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/GRASSPlugins.elm"
    echo "module GRASSPlugins exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      "^grass-plugin" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|packages\.x86_64-linux\.|geopkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/QGISPackages.elm"
    echo "module QGISPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      "^qgis" \
      --exclude "qgis-plugin.*" \
      --exclude "qgis-ltr-plugin.*" \
      --exclude "unwrapped" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|packages\.x86_64-linux\.|geopkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/QGISPlugins.elm"
    echo "module QGISPlugins exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      "^qgis-plugin|^qgis-ltr-plugin" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|packages\.x86_64-linux\.|geopkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/GeoPackages.elm"
    echo "module GeoPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      --exclude "all-packages" \
      --exclude "unwrapped" \
      --exclude "postgresql." \
      --exclude "python.*" \
      --exclude "grass.*" \
      --exclude "qgis.*" \
      --exclude "nixGL" \
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
      --exclude "qgis.*" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/GeoPythonPackages.elm"
    echo "module GeoPythonPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
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
    nix search --json $geonix_url  \
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

  scripts.make-elm-site-dev.exec = ''
    find src/ -name "*.elm" \
      | ${pkgs.entr}/bin/entr -rn ${lib.getExe pkgs.elmPackages.elm} make src/HomePage.elm --output src/elm.js
  '';

  scripts.make-elm-site-prod.exec = ''
    ${lib.getExe pkgs.elmPackages.elm} make src/HomePage.elm --optimize --output src/elm.js
  '';
  
  processes.make-elm-site-dev.exec = ''
    trap "${config.scripts.make-elm-site-prod.exec}" SIGTERM

    echo -e "Open the app at $(pwd)/src/index.html .\n"
    ${config.scripts.make-elm-site-dev.exec}
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
      entry = config.scripts.make-elm-site-prod.exec;
    };
  };
}
