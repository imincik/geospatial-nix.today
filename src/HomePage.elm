module HomePage exposing (main)

import Browser
import GeoPackages
import GeoPostgresqlPackages
import GeoPythonPackages
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import NixConfig exposing (configTemplate)
import Packages
import PostgresqlPackages
import PythonPackages
import Texts exposing (aboutText, configTemplateComment, containerTemplate, containerTemplateComment, futurePlansText, initTemplate, initTemplateComment, installNixTemplate, installNixTemplateComment, servicesTemplate, servicesTemplateComment, shareTemplate, shareTemplateComment, shareTemplateComment2, shellTemplate, shellTemplateComment)



-- MODEL
-- packages


type alias Package =
    ( String, String )


type alias Packages =
    List Package


allPackages : Packages
allPackages =
    GeoPackages.packages ++ Packages.packages


allPyPackages : Packages
allPyPackages =
    GeoPythonPackages.packages ++ PythonPackages.packages


allPgPackages : Packages
allPgPackages =
    GeoPostgresqlPackages.packages ++ PostgresqlPackages.packages



-- languages


type alias LanguagePython =
    { enabled : Bool
    , packages : Packages
    }


type alias Languages =
    { python : LanguagePython

    -- , xy: LanguageXY
    }



-- services


type alias ServicePostgres =
    { enabled : Bool
    , packages : Packages
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

    -- packages
    , availablePackages : List Package
    , selectedPackages : List Package

    -- python
    , pythonEnabled : String
    , availablePyPackages : List Package
    , selectedPyPackages : List Package

    -- postgresql
    , postgresEnabled : String
    , availablePgPackages : List Package
    , selectedPgPackages : List Package

    -- filters
    , filterLimit : Int
    , filterPackages : String
    , filterPyPackages : String
    , filterPgPackages : String

    -- config
    , config : Config
    , nixConfig : String
    }


initialModel : Model
initialModel =
    { name = ""

    -- packages
    , availablePackages = allPackages
    , selectedPackages = []

    -- python
    , pythonEnabled = "false"
    , availablePyPackages = allPyPackages
    , selectedPyPackages = []

    -- postgresql
    , postgresEnabled = "false"
    , availablePgPackages = allPgPackages
    , selectedPgPackages = []

    -- filters
    , filterLimit = 5
    , filterPackages = ""
    , filterPyPackages = ""
    , filterPgPackages = ""

    -- config
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
        [ div [ class "row" ]
            [ div [ class "col-md-12 border fw-bold fs-1 py-3 my-3" ]
                [ p [] [ text "GEOSPATIAL NIX - the environment builder" ]
                ]
            ]

        -- options
        , div [ class "row" ]
            [ div [ class "col-md-6 border bg-light py-3 my-3" ]
                [ div [ class "name d-flex justify-content-between align-items-center" ]
                    [ input [ class "form-control form-control-lg", style "margin" "10px", placeholder "Environment name ...", value model.name, onInput UpdateName ] []
                    , button [ class "btn btn-primary btn-lg", onClick BuildConfig ] [ text "Create" ]
                    ]
                , div [ class "packages" ]
                    [ hr [] []
                    , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                        [ text "packages"
                        , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for packages ...", value model.filterPackages, onInput FilterPackages ] []
                        ]
                    , packagesHtmlList model.availablePackages model.selectedPackages model.filterPackages model.filterLimit AddPackage
                    , p [ class "text-secondary" ]
                        [ packagesCountText (List.length model.availablePackages) (List.length model.selectedPackages)
                        , morePackagesButton model.filterLimit
                        ]
                    ]
                , div [ class "languages" ]
                    [ p [ class "fw-bold fs-2" ] [ text "LANGUAGES" ]
                    , hr [] []
                    , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ] [ text "python.enabled", button [ class "btn btn-info btn-sm", style "margin" "5px", onClick EnablePython ] [ text model.pythonEnabled ] ]
                    , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                        [ text "packages"
                        , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for Python packages ...", value model.filterPyPackages, onInput FilterPyPackages ] []
                        ]
                    , packagesHtmlList model.availablePyPackages model.selectedPyPackages model.filterPyPackages model.filterLimit AddPyPackage
                    , p [ class "text-secondary" ]
                        [ packagesCountText (List.length model.availablePyPackages) (List.length model.selectedPyPackages)
                        , morePackagesButton model.filterLimit
                        ]
                    ]
                , div [ class "services" ]
                    [ p [ class "fw-bold fs-2" ] [ text "SERVICES" ]
                    , hr [] []
                    , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ] [ text "postgres.enabled", button [ class "btn btn-info btn-sm", style "margin" "5px", onClick EnablePostgres ] [ text model.postgresEnabled ] ]
                    , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                        [ text "packages"
                        , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for PostgreSQL packages ...", value model.filterPgPackages, onInput FilterPgPackages ] []
                        ]
                    , packagesHtmlList model.availablePgPackages model.selectedPgPackages model.filterPgPackages model.filterLimit AddPgPackage
                    , p [ class "text-secondary" ]
                        [ packagesCountText (List.length model.availablePgPackages) (List.length model.selectedPgPackages)
                        , morePackagesButton model.filterLimit
                        ]
                    ]
                , div [ class "shell-hook" ]
                    [ hr [] []
                    , p [ class "fw-bold fs-3" ] [ text "shell hook" ]
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
                        , h2 [] [ text "ENTER ENVIRONMENT" ]
                        , pre [] [ span [] [ text shellTemplateComment ], span [ class "text-warning" ] [ text shellTemplate ] ]
                        , h2 [] [ text "LAUNCH SERVICES" ]
                        , pre [] [ span [] [ text servicesTemplateComment ], span [ class "text-warning" ] [ text servicesTemplate ] ]
                        , h2 [] [ text "RUN IN CONTAINER" ]
                        , pre [] [ span [] [ text containerTemplateComment ], span [ class "text-warning" ] [ text containerTemplate ] ]
                        , h2 [] [ text "SHARE ENVIRONMENT" ]
                        , pre [] [ span [] [ text shareTemplateComment ], span [ class "text-warning" ] [ text shareTemplate ], span [] [ text shareTemplateComment2 ] ]
                        ]

                  else
                    div []
                        [ h2 [] [ text "ABOUT" ]
                        , p [] [ text aboutText ]
                        , h3 [] [ text "FUTURE PLANS" ]
                        , p [] [ text futurePlansText ]
                        , p []
                            [ text "If you have some ideas, please "
                            , a [ href "https://github.com/imincik/geospatial-nix.today/issues/new", target "_blank" ] [ text "share them with us." ]
                            ]
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
        ]


packagesHtmlList : List Package -> List Package -> String -> Int -> (Package -> Msg) -> Html Msg
packagesHtmlList availableItems selectedItems filter filterLimit onClickAction =
    let
        filteredItems =
            -- filter items
            List.filter (\item -> String.contains filter (Tuple.first item)) availableItems
                -- show only first x items
                |> List.take filterLimit
    in
    ul [ class "list-group" ] (List.map (packageHtmlItem selectedItems onClickAction) filteredItems)


packageHtmlItem : List Package -> (Package -> Msg) -> Package -> Html Msg
packageHtmlItem selectedItems onClickAction item =
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
        [ p [ class "fs-5" ]
            [ text (Tuple.first item)
            , span [ class "text-secondary fs-6" ] [ text ("  v" ++ Tuple.second item) ]
            ]
        , button [ class buttonClass, style "margin" "10px", onClick (onClickAction item), id "packagesList" ] [ text buttonLabel ]
        ]


packagesCountText : Int -> Int -> Html Msg
packagesCountText packagesCount selectedCount =
    text ("Available packages: " ++ String.fromInt packagesCount ++ " , selected: " ++ String.fromInt selectedCount)


morePackagesButton : Int -> Html Msg
morePackagesButton filterLimit =
    button [ class "btn btn-sm btn-link", onClick UpdateFilterLimit ]
        [ if filterLimit < 15 then
            text "show more"

          else
            text "show less"
        ]


packagesListToNamesList : List Package -> List String
packagesListToNamesList packages =
    List.map (\item -> Tuple.first item) packages


type Msg
    = UpdateName String
    | AddPackage Package
    | EnablePython
    | AddPyPackage Package
    | EnablePostgres
    | AddPgPackage Package
    | UpdateShellHook String
    | FilterPackages String
    | FilterPyPackages String
    | FilterPgPackages String
    | UpdateFilterLimit
    | BuildConfig



-- UPDATE


buildConfig : Model -> String
buildConfig model =
    let
        selectedPackages =
            packagesListToNamesList model.selectedPackages

        selectedPyPackages =
            packagesListToNamesList model.selectedPyPackages

        selectedPgPackages =
            packagesListToNamesList model.selectedPgPackages
    in
    String.replace "<NAME>" model.name configTemplate
        |> String.replace "<PACKAGES>" (String.join " " selectedPackages)
        |> String.replace "<PYTHON-ENABLED>" model.pythonEnabled
        |> String.replace "<PY-PACKAGES>" (String.join " " selectedPyPackages)
        |> String.replace "<POSTGRES-ENABLED>" model.postgresEnabled
        |> String.replace "<PG-PACKAGES>" (String.join " " selectedPgPackages)
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

        FilterPackages pkg ->
            { model | filterPackages = pkg }

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

        FilterPyPackages pkg ->
            { model | filterPyPackages = pkg }

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

        FilterPgPackages pkg ->
            { model | filterPgPackages = pkg }

        UpdateShellHook script ->
            { model | config = (\p -> { p | enterShell = script }) model.config }

        UpdateFilterLimit ->
            { model
                | filterLimit =
                    -- allow to increase limit up to 15 items
                    if model.filterLimit < 15 then
                        model.filterLimit + 5

                    else
                        5
            }

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
