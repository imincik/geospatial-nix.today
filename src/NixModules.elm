module NixModules exposing (customProcess, packages, pg_featureserv, postgres, python, shellHook)

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


pg_featureserv =
    { enabled = False

    -- configuration
    , postgresDatabase =
        { default = "postgres"
        }
    , settings =
        { default = ""
        , example = """Server.HttpPort = 9001;
Paging.LimitMax = 1000;"""
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


shellHook =
    { enterShell =
        { default = ""
        , example = """echo "$USER, welcome to the ${config.name} environment !\""""
        }
    }
