module NixConfig exposing
    ( configCustomProcessTemplate
    , configDataFromUrlTemplate
    , configEnterShellTemplate
    , configGRASSTemplate
    , configJupyterKernelsTemplate
    , configJupyterTemplate
    , configNameTemplate
    , configOpenGLTemplate
    , configPackagesTemplate
    , configPostgresTemplate
    , configPythonTemplate
    , configQGISTemplate
    , configTemplate
    )


configTemplate =
    """
{ inputs, config, lib, pkgs, ... }:

{
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


configGRASSTemplate =
    """
  applications.grass = {
    enable = <GRASS-ENABLED>;
    package = <GRASS-PACKAGE>;
    plugins = p: [ <GRASS-PLUGINS> ];
  };
"""


configQGISTemplate =
    """
  applications.qgis = {
    enable = <QGIS-ENABLED>;
    package = <QGIS-PACKAGE>;
    withGrass = <QGIS-WITH-GRASS>;
    pythonPackages = p: [ <QGIS-PYTHON-PACKAGES> ];
    plugins = p: [ <QGIS-PLUGINS> ];
  };
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


configJupyterTemplate =
    """
  services.jupyter = {
    enable = <JUPYTER-ENABLED>;
    <JUPYTER-KERNELS>
    ip = "<JUPYTER-LISTEN-ADDRESS>";
    port = <JUPYTER-LISTEN-PORT>;
    rawConfig = ''
      <JUPYTER-RAW-CONFIG>
    '';
  };
"""


configJupyterKernelsTemplate =
    """
    kernels = {
      geospatial =
        let
          env = pkgs.python3.withPackages (p: [ pkgs.python3Packages.ipykernel <JUPYTER-PYTHON-PACKAGES> ]);
          logoPath = "${env}/${env.sitePackages}/ipykernel/resources";
        in
        {
          displayName = "Geospatial Python kernel";
          language = "python";
          argv = [
            "${env.interpreter}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          logo32 = "${logoPath}/logo-32x32.png";
          logo64 = "${logoPath}/logo-64x64.png";
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


configDataFromUrlTemplate =
    """
  data.fromUrl = {
    enable = true;
    datasets = [ <DATA-FROM-URL-DATASETS> ];
  };
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
