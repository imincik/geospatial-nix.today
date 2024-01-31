module NixConfig exposing (configTemplate)


configTemplate =
    """
{ inputs, config, pkgs, lib, ... }:

let
  geopkgs = inputs.geonix.packages.${pkgs.system};

in {
  name = "<NAME>";

  packages = [ <PACKAGES> ];

  languages.python = {
    enable = <PYTHON-ENABLED>;
    package = pkgs.python3.withPackages (p: [ <PY-PACKAGES> ]);
  };

  services.postgres = {
    enable = if config.container.isBuilding then false else <POSTGRES-ENABLED>;
    extensions = e: [ <PG-PACKAGES> ];
  };

  enterShell = ''
    <SHELL-HOOK>
  '';
}
"""
