module NixConfig exposing
    ( configCustomProcessTemplate
    , configEnterShellTemplate
    , configNameTemplate
    , configPackagesTemplate
    , configPgFeatureservTemplate
    , configPostgresTemplate
    , configPythonTemplate
    , configTemplate
    )


configTemplate =
    """
{ inputs, config, lib, pkgs, ... }:

let
  geopkgs = inputs.geonix.packages.${pkgs.system};

in {
  <CONFIG-BODY>
}
"""


configNameTemplate =
    """
  name = "<NAME>";
"""


configPackagesTemplate =
    """
  packages = [ <PACKAGES> ];
"""


configPythonTemplate =
    """
  languages.python = {
    enable = <PYTHON-ENABLED>;
    package = pkgs.python3.withPackages (p: [ <PYTHON-PACKAGES> ]);
    poetry = {
      enable = <PYTHON-POETRY-ENABLED>;
      activate.enable = <PYTHON-POETRY-ENABLED>;
    };
  };
"""


configPostgresTemplate =
    """
  services.postgres = {
    enable = if config.container.isBuilding then false else <POSTGRES-ENABLED>;
    extensions = e: [ <POSTGRES-PACKAGES> ];
    initdbArgs = [ <POSTGRES-INITDB-ARGS> ];
    initialScript = "<POSTGRES-INITIAL-SCRIPT>";
    listen_addresses = "<POSTGRES-LISTEN-ADDRESSES>";
    port = <POSTGRES-LISTEN-PORT>;
    settings = { <POSTGRES-SETTINGS> };
  };
"""


configPgFeatureservTemplate =
    """
  services.pg_featureserv = {
    enable = <PG_FEATURESERV-ENABLED>;
    package = geopkgs.pg_featureserv;
    settings = { <PG_FEATURESERV-SETTINGS> };
  };
"""


configCustomProcessTemplate =
    """
  processes.custom.exec = ''
    <CUSTOM-PROCESS>
  '';
"""


configEnterShellTemplate =
    """
  enterShell = ''
    <SHELL-HOOK>
  '';
"""
