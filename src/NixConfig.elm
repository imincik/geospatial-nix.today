module NixConfig exposing
    ( configCustomProcessTemplate
    , configEnterShellTemplate
    , configNameTemplate
    , configOpenGLTemplate
    , configPackagesTemplate
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


configCustomProcessTemplate =
    """
  processes.custom.exec = ''
    <CUSTOM-PROCESS>
  '';
"""


configOpenGLTemplate =
    """
  nixgl.enable = true;
"""


configEnterShellTemplate =
    """
  enterShell = ''
    <SHELL-HOOK>
  '';
"""
