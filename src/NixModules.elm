module NixModules exposing (customProcess, packages, postgres, python)

-- default and example configuration values


packages =
    { packages = []
    }


python =
    { enabled = False
    , packages = []
    , poetryEnabled = False
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
