module HomePage exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


allPackages =
    [ "geopkgs.gdal", "geopkgs.gdal-minimal", "geopkgs.pdal", "geopkgs.grass", "geopkgs.qgis", "geopkgs.qgis-ltr", "pkgs.sl" ]


allPyPackages =
    [ "geopkgs.python3-fiona", "geopkgs.python3-gdal", "geopkgs.python3-geopandas", "geopkgs.python3-rasterio", "pkgs.python3Packages.numpy" ]


allPgPackages =
    [ "geopkgs.postgresql-postgis", "pkgs.postgresqlPackages.pgrouting" ]


aboutText =
    """
In a world of horrendously complex software developed by myriads of authors, be
smart, use Nix and create reproducible geospatial environment, lovely built to
work together on any modern Linux distribution.
"""


installNixTemplateComment =
    """
- Install Nix (if not already installed)
"""


installNixTemplate =
    """
curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
"""


initTemplateComment =
    """
- Run following commands to initalize new project
"""


initTemplate =
    """
mkdir my-project && cd my-project

git init
nix run github:imincik/geospatial-nix#geonixcli init
git add *
"""


configTemplateComment =
    """
- Copy and paste configuration to geonix.nix file
"""


configTemplate =
    """
{ inputs, config, pkgs, lib, ... }:

let
  geopkgs = inputs.geonix.packages.${pkgs.system};

  packages = [ <PACKAGES> ];
  python = pkgs.python3.withPackages (p: [ <PY-PACKAGES> ]);
  pgExtensions = [ <PG-PACKAGES> ];

in {
  name = "<NAME>";

  packages = packages;

  languages.python = {
    enable = <PYTHON-ENABLED>;
    package = python;
  };

  services.postgres = {
    enable = if config.container.isBuilding then false else <POSTGRES-ENABLED>;
    extensions = e: pgExtensions;
  };

  enterShell = ''
    <SHELL-HOOK>
  '';
}
"""


shellTemplateComment =
    """
- Run following command to enter shell environment
"""


shellTemplate =
    """
nix run github:imincik/geospatial-nix#geonixcli -- shell
"""


servicesTemplateComment =
    """
- Run following command to launch services
"""


servicesTemplate =
    """
nix run github:imincik/geospatial-nix#geonixcli -- up
"""


containerTemplateComment =
    """
- Run following commands to build and run environment in container
"""


containerTemplate =
    """
nix run github:imincik/geospatial-nix#geonixcli -- container shell

docker run --rm -it shell:latest
"""



-- MODEL
-- packages


type alias Packages =
    List String



-- languages


type alias LanguagePython =
    { enabled : Bool
    , packages : List String
    }


type alias Languages =
    { python : LanguagePython

    -- , xy: LanguageXY
    }



-- services


type alias ServicePostgres =
    { enabled : Bool
    , packages : List String
    }


type alias Services =
    { postgres : ServicePostgres

    -- , xy: ServiceXY
    }



-- shell hook


type alias EnterShell =
    String


type alias Config =
    { packages : Packages
    , languages : Languages
    , services : Services
    , enterShell : EnterShell
    }


type alias Model =
    { name : String
    , availablePackages : List String
    , selectedPackages : List String
    , pythonEnabled : String
    , availablePyPackages : List String
    , selectedPyPackages : List String
    , postgresEnabled : String
    , availablePgPackages : List String
    , selectedPgPackages : List String
    , config : Config
    , nixConfig : String
    }


initialModel : Model
initialModel =
    { name = ""
    , availablePackages = allPackages
    , selectedPackages = []
    , pythonEnabled = "false"
    , availablePyPackages = allPyPackages
    , selectedPyPackages = []
    , postgresEnabled = "false"
    , availablePgPackages = allPgPackages
    , selectedPgPackages = []
    , config =
        { packages = []
        , languages =
            { python =
                { enabled = False
                , packages = []
                }
            }
        , services =
            { postgres =
                { enabled = False
                , packages = []
                }
            }
        , enterShell = ""
        }
    , nixConfig = ""
    }



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [] [ text "GEOSPATIAL NIX - the environment builder" ]
        , hr [] []

        -- options
        , div [ class "row" ]
            [ div [ class "col-md-6 border bg-light py-3 my-3" ]
                [ div [ class "name d-flex justify-content-between align-items-center" ]
                    [ input [ class "form-control form-control-lg", style "margin" "10px", placeholder "Environment name ...", value model.name, onInput UpdateName ] []
                    , button [ class "btn btn-primary btn-lg", onClick BuildConfig ] [ text "Create" ]
                    ]
                , div [ class "packages" ]
                    [ hr [] []
                    , p [ class "fw-bold fs-2" ] [ text "packages" ]
                    , toHtmlListAdd model.availablePackages model.selectedPackages AddPackage
                    , hr [] []
                    ]
                , div [ class "python" ]
                    [ p [ class "fw-bold fs-2 d-flex justify-content-between align-items-center" ] [ text "languages.python.enabled", button [ class "btn btn-info btn-sm", style "margin" "5px", onClick EnablePython ] [ text model.pythonEnabled ] ]
                    , p [ class "fw-bold fs-3" ] [ text "packages" ]
                    , toHtmlListAdd model.availablePyPackages model.selectedPyPackages AddPyPackage
                    , hr [] []
                    ]
                , div [ class "postgres" ]
                    [ p [ class "fw-bold fs-2 d-flex justify-content-between align-items-center" ] [ text "services.postgres.enabled", button [ class "btn btn-info btn-sm", style "margin" "5px", onClick EnablePostgres ] [ text model.postgresEnabled ] ]
                    , p [ class "fw-bold fs-3" ] [ text "packages" ]
                    , toHtmlListAdd model.availablePgPackages model.selectedPgPackages AddPgPackage
                    , hr [] []
                    ]
                , div [ class "shell-hook" ]
                    [ p [ class "fw-bold fs-3" ] [ text "shell hook" ]
                    , textarea [ class "form-control form-control-lg", placeholder "echo hello", value model.config.enterShell, onInput UpdateShellHook ] []
                    ]
                ]

            -- configuration
            , div [ class "col-md-6 bg-dark text-white py-3 my-3" ]
                [ if not (String.isEmpty model.nixConfig) then
                    div [ class "configuration" ]
                        [ h2 [] [ text "INSTALL NIX" ]
                        , pre [] [ span [] [ text installNixTemplateComment ], span [ class "text-warning" ] [ text installNixTemplate ] ]
                        , h2 [] [ text "START PROJECT" ]
                        , pre [] [ span [] [ text initTemplateComment ], span [ class "text-warning" ] [ text initTemplate ] ]
                        , h2 [] [ text "CONFIGURATION" ]
                        , pre [] [ span [] [ text configTemplateComment ], span [ class "text-warning" ] [ text model.nixConfig ] ]
                        ]

                  else
                    div []
                        [ h2 [] [ text "ABOUT" ]
                        , p [] [ text aboutText ]
                        , h3 [] [ text "USED TECHNOLOGIES" ]
                        , p []
                            [ a [ href "https://github.com/imincik/geospatial-nix", target "_blank" ] [ text "Geospatial NIX" ]
                            , text " , "
                            , a [ href "https://nixos.org", target "_blank" ] [ text "Nix and Nixpkgs" ]
                            , text " , "
                            , a [ href "https://devenv.sh/", target "_blank" ] [ text "Devenv" ]
                            , text " ."
                            , text " Read more about Nix at "
                            , a [ href "https://nix.dev", target "_blank" ] [ text "nix.dev" ]
                            , text " ."
                            ]
                        , h3 [] [ text "AUTHORS" ]
                        , text "Created by "
                        , a [ href "https://github.com/imincik", target "_blank" ] [ text "Ivan Mincik, @imincik" ]
                        , text "."
                        ]
                ]
            ]

        -- usage
        , if not (String.isEmpty model.nixConfig) then
            div [ class "row" ]
                [ div [ class "col-md-12 border bg-dark text-white py-3 my-3" ]
                    [ h2 [] [ text "ENTER ENVIRONMENT" ]
                    , pre [] [ span [] [ text shellTemplateComment ], span [ class "text-warning" ] [ text shellTemplate ] ]
                    , h2 [] [ text "LAUNCH SERVICES" ]
                    , pre [] [ span [] [ text servicesTemplateComment ], span [ class "text-warning" ] [ text servicesTemplate ] ]
                    , h2 [] [ text "RUN IN CONTAINER" ]
                    , pre [] [ span [] [ text containerTemplateComment ], span [ class "text-warning" ] [ text containerTemplate ] ]
                    ]
                ]

          else
            div [] []
        ]


toHtmlListAdd : List String -> List String -> (String -> Msg) -> Html Msg
toHtmlListAdd availableItems selectedItems onClickAction =
    ul [ class "list-group" ] (List.map (toLiAdd selectedItems onClickAction) availableItems)


toLiAdd : List String -> (String -> Msg) -> String -> Html Msg
toLiAdd selectedItems onClickAction item =
    let
        buttonLabel =
            ">"

        buttonClass =
            if not (List.member item selectedItems) then
                "btn btn-secondary btn-sm"

            else
                "btn btn-success btn-sm"
    in
    li [ class "list-group-item d-flex justify-content-between align-items-center" ]
        [ text item, button [ class buttonClass, style "margin" "10px", onClick (onClickAction item) ] [ text buttonLabel ] ]


type Msg
    = UpdateName String
    | AddPackage String
    | EnablePython
    | AddPyPackage String
    | EnablePostgres
    | AddPgPackage String
    | UpdateShellHook String
    | BuildConfig



-- UPDATE


buildConfig : Model -> String
buildConfig model =
    String.replace "<NAME>" model.name configTemplate
        |> String.replace "<PACKAGES>" (String.join " " model.selectedPackages)
        |> String.replace "<PYTHON-ENABLED>" model.pythonEnabled
        |> String.replace "<PY-PACKAGES>" (String.join " " model.selectedPyPackages)
        |> String.replace "<POSTGRES-ENABLED>" model.postgresEnabled
        |> String.replace "<PG-PACKAGES>" (String.join " " model.selectedPgPackages)
        |> String.replace "<SHELL-HOOK>" model.config.enterShell


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateName name ->
            { model | name = name }

        AddPackage pkg ->
            if not (List.member pkg model.selectedPackages) then
                { model | selectedPackages = model.selectedPackages ++ [ pkg ] }

            else
                { model | selectedPackages = List.filter (\x -> x /= pkg) model.selectedPackages }

        EnablePython ->
            { model
                | pythonEnabled =
                    if model.pythonEnabled == "false" then
                        "true"

                    else
                        "false"
            }

        AddPyPackage pkg ->
            if not (List.member pkg model.selectedPyPackages) then
                { model | selectedPyPackages = model.selectedPyPackages ++ [ pkg ], pythonEnabled = "true" }

            else
                { model | selectedPyPackages = List.filter (\x -> x /= pkg) model.selectedPyPackages }

        EnablePostgres ->
            { model
                | postgresEnabled =
                    if model.postgresEnabled == "false" then
                        "true"

                    else
                        "false"
            }

        AddPgPackage pkg ->
            if not (List.member pkg model.selectedPgPackages) then
                { model | selectedPgPackages = model.selectedPgPackages ++ [ pkg ], postgresEnabled = "true" }

            else
                { model | selectedPgPackages = List.filter (\x -> x /= pkg) model.selectedPgPackages }

        UpdateShellHook script ->
            { model | config = (\p -> { p | enterShell = script }) model.config }

        BuildConfig ->
            { model | nixConfig = buildConfig model }



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
