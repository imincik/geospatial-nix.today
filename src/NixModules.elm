module NixModules exposing (customProcess, jupyter, openGL, packages, postgres, python, qgis, shellHook)

-- default and example configuration values


qgis =
    { enabled = False
    , pythonPackages = []
    , plugins = []
    }


packages =
    { packages = []
    }


python =
    { enabled = False
    , packages = []
    , poetryEnabled = False
    }


jupyter =
    { enabled = False

    -- configuration
    , pythonPackages = []
    , listenAddress =
        { default = "localhost"
        , example = ""
        }
    , listenPort =
        { default = "8888"
        , example = ""
        }
    , rawConfig =
        { default = ""
        , example = """c.ServerApp.answer_yes = False
c.ServerApp.open_browser = False"""
        }
    }


postgres =
    { enabled = False
    , packages = []

    -- configuration
    , initdbArgs =
        { default = """"--locale=C"
"--encoding=UTF8\""""
        , example = ""
        }
    , initialScript =
        { default = ""
        , example = """CREATE EXTENSION postgis;
SELECT PostGIS_Full_Version();"""
        }
    , listenAddresses =
        { default = ""
        , example = "0.0.0.0"
        }
    , listenPort =
        { default = "5432"
        , example = ""
        }
    , settings =
        { default = ""
        , example = """log_connections = true;
log_statement = "all";"""
        }
    }


customProcess =
    { enabled = False

    -- configuration
    , exec =
        { default = ""
        , example = "python -m http.server"
        }
    }


openGL =
    { enabled = False }


shellHook =
    { enterShell =
        { default = ""
        , example = """echo "$USER, welcome to the ${config.name} environment !\""""
        }
    }
