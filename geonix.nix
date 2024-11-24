{ inputs, config, pkgs, lib, ... }:

{
  packages = [ ];

  scripts.make-packages-db.exec = ''
    geonix_url="github:imincik/geospatial-nix.repo/latest"
    python_version=$(echo ${pkgs.python3.pythonVersion} | sed 's|\.||')
    postgresql_version=$(echo ${pkgs.postgresql.version} | sed 's|\..*||')


    packages_file="src/GRASSPackages.elm"
    echo "module GRASSPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      'legacyPackages.x86_64-linux.grass$' \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/GRASSPlugins.elm"
    echo "module GRASSPlugins exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      'legacyPackages.x86_64-linux.grassPlugins' \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/QGISPackages.elm"
    echo "module QGISPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      'legacyPackages.x86_64-linux.qgis$|legacyPackages.x86_64-linux.qgis-ltr$' \
      --exclude "unwrapped" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/QGISPlugins.elm"
    echo "module QGISPlugins exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      'legacyPackages.x86_64-linux.qgisPlugins|legacyPackages.x86_64-linux.qgisLTRPlugins' \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/Packages.elm"
    echo "module Packages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      --exclude "^packages\." \
      --exclude "postgresql.*Packages" \
      --exclude "python.*Packages" \
      --exclude "grass.*" \
      --exclude "grassPlugins.*" \
      --exclude "qgis.*" \
      --exclude "qgisPlugins.*" \
      --exclude "qgisLTRPlugins.*" \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/PythonPackages.elm"
    echo "module PythonPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      --exclude "^packages\." \
      python''${python_version}Packages \
      | jq -r 'to_entries[] | "  ,( \"\(.key)\", \"\(.value | .version)\" )"' \
      | sed 's|legacyPackages\.x86_64-linux\.|pkgs\.|g' \
      | sed 's|python3..Packages|python3Packages|g' \
    >> $packages_file
    echo "]" >> $packages_file
    sed -i '3s/  ,//' $packages_file
    ${lib.getExe pkgs.elmPackages.elm-format} --yes $packages_file


    packages_file="src/PostgresqlPackages.elm"
    echo "module PostgresqlPackages exposing (packages)" > $packages_file
    echo "packages = [" >> $packages_file
    nix search --json $geonix_url  \
      --exclude "^packages\." \
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
