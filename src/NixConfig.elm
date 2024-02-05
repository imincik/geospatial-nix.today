module NixConfig exposing (configCustomProcessTemplate, configEnterShellTemplate, configNameTemplate, configPackagesTemplate, configPostgresTemplate, configPythonTemplate, configTemplate)


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
  };
"""


configPostgresTemplate =
    """
  services.postgres = {
    enable = if config.container.isBuilding then false else <POSTGRES-ENABLED>;
    extensions = e: [ <POSTGRES-PACKAGES> ];
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
