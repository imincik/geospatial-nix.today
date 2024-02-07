module HomePage exposing (main)

import Browser
import GeoPackages
import GeoPostgresqlPackages
import GeoPythonPackages
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import NixConfig
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



-- processes


type alias ProcessCustom =
    { exec : String
    }


type alias Processes =
    { custom : ProcessCustom

    -- , xy: ProcessXY
    }



-- shell hook


type alias EnterShell =
    String


type alias Config =
    { packages : Packages
    , languages : Languages
    , services : Services
    , processes : Processes
    , enterShell : EnterShell
    }



-- ui


type alias UI =
    { activeCategoryTab : String
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
    , nixInit : String
    , nixConfig : String
    , ui : UI
    }


initialModel : Model
initialModel =
    { name = "My geospatial environment"

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
        , processes =
            { custom =
                { exec = ""
                }
            }
        , enterShell = ""
        }
    , nixInit = ""
    , nixConfig = ""

    -- ui
    , ui =
        { activeCategoryTab = "packages"
        }
    }



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col-md-12 border fw-bold fs-1 py-3 my-3" ]
                [ p []
                    [ span [ style "margin-right" "10px" ] [ text "GEOSPATIAL NIX" ]
                    , span [ class "fs-2 text-decoration-underline text-secondary" ] [ text "the environment builder" ]
                    ]
                ]
            ]

        -- configuration options
        , div [ class "row" ]
            [ div [ class "col-md-6 border bg-light py-3 my-3" ]
                [ div [ class "name d-flex justify-content-between align-items-center" ]
                    [ input [ class "form-control form-control-lg", style "margin" "10px", placeholder "Environment name ...", value model.name, onInput UpdateName ] []
                    , button [ class "btn btn-primary btn-lg", onClick CreateEnvironment ] [ text "Create" ]
                    ]

                -- separator
                , div [] [ hr [] [] ]

                -- tabs
                , div [ class "d-flex btn-group align-items-center" ]
                    (mainCategoryHtmlTab [ "PACKAGES", "LANGUAGES", "SERVICES", "OTHER" ] model.ui.activeCategoryTab)

                -- packages
                , if model.ui.activeCategoryTab == "packages" then
                    div [ class "packages" ]
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

                  else
                    div [] []

                -- languages
                , if model.ui.activeCategoryTab == "languages" then
                    div [ class "languages" ]
                        [ hr [] []
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

                  else
                    div [] []

                -- services
                , if model.ui.activeCategoryTab == "services" then
                    div [ class "services" ]
                        [ hr [] []
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
                        , hr [] []
                        , p [ class "fw-bold fs-3" ] [ text "custom process" ]
                        , textarea [ class "form-control form-control-lg", placeholder "python -m http.server", value model.config.processes.custom.exec, onInput AddCustomProcess ] []
                        , br [] []
                        ]

                  else
                    div [] []

                -- other
                , if model.ui.activeCategoryTab == "other" then
                    div [ class "shell-hook" ]
                        [ hr [] []
                        , p [ class "fw-bold fs-3" ] [ text "shell hook" ]
                        , textarea [ class "form-control form-control-lg", placeholder "echo hello", value model.config.enterShell, onInput AddShellHook ] []
                        ]

                  else
                    div [] []
                ]

            -- configuration
            , div [ class "col-md-6 bg-dark text-white py-3 my-3" ]
                [ if not (String.isEmpty model.nixConfig) then
                    div [ class "configuration" ]
                        [ h2 [] [ text "INSTALL NIX" ]
                        , pre [] [ span [] [ text installNixTemplateComment ], span [ class "text-warning" ] [ text installNixTemplate ] ]
                        , h2 [] [ text "START PROJECT" ]
                        , pre [] [ span [] [ text initTemplateComment ], span [ class "text-warning" ] [ text model.nixInit ] ]
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


mainCategoryHtmlTab : List String -> String -> List (Html Msg)
mainCategoryHtmlTab buttons activeButton =
    let
        buttonItem =
            \item ->
                button
                    [ class
                        ("btn btn-lg "
                            ++ (if String.toLower item == activeButton then
                                    "btn-dark"

                                else
                                    "btn-secondary"
                               )
                        )
                    , onClick (SetActiveCategoryTab (String.toLower item))
                    ]
                    [ text item ]
    in
    List.map buttonItem buttons


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


optionalString : Bool -> String -> String
optionalString condition string =
    if condition then
        string

    else
        ""


environmentName : String -> String
environmentName name =
    String.toLower (String.replace " " "-" name)


packagesListToNamesList : List Package -> List String
packagesListToNamesList packages =
    List.map (\item -> Tuple.first item) packages


type Msg
    = SetActiveCategoryTab String
    | UpdateName String
    | AddPackage Package
    | EnablePython
    | AddPyPackage Package
    | EnablePostgres
    | AddPgPackage Package
    | AddCustomProcess String
    | AddShellHook String
    | FilterPackages String
    | FilterPyPackages String
    | FilterPgPackages String
    | UpdateFilterLimit
    | CreateEnvironment



-- UPDATE


buildNixInit : Model -> String
buildNixInit model =
    String.replace "<NAME>" (environmentName model.name) initTemplate


buildNixConfig : Model -> String
buildNixConfig model =
    let
        selectedPackages =
            packagesListToNamesList model.selectedPackages

        selectedPyPackages =
            packagesListToNamesList model.selectedPyPackages

        selectedPgPackages =
            packagesListToNamesList model.selectedPgPackages

        nixConfigBody =
            NixConfig.configNameTemplate
                ++ NixConfig.configPackagesTemplate
                ++ optionalString (model.pythonEnabled == "true") NixConfig.configPythonTemplate
                ++ optionalString (model.postgresEnabled == "true") NixConfig.configPostgresTemplate
                ++ optionalString (model.config.processes.custom.exec /= "") NixConfig.configCustomProcessTemplate
                ++ optionalString (model.config.enterShell /= "") NixConfig.configEnterShellTemplate

        nixConfig =
            String.replace "<CONFIG-BODY>" nixConfigBody NixConfig.configTemplate
    in
    String.replace "<NAME>" (environmentName model.name) nixConfig
        |> String.replace "<PACKAGES>" (String.join " " selectedPackages)
        |> String.replace "<PYTHON-ENABLED>" model.pythonEnabled
        |> String.replace "<PYTHON-PACKAGES>" (String.join " " selectedPyPackages)
        |> String.replace "<POSTGRES-ENABLED>" model.postgresEnabled
        |> String.replace "<POSTGRES-PACKAGES>" (String.join " " selectedPgPackages)
        |> String.replace "<CUSTOM-PROCESS>" model.config.processes.custom.exec
        |> String.replace "<SHELL-HOOK>" model.config.enterShell


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetActiveCategoryTab tab ->
            { model | ui = (\p -> { p | activeCategoryTab = tab }) model.ui }

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

        AddCustomProcess script ->
            { model | config = (\p -> { p | processes = { custom = { exec = script } } }) model.config }

        AddShellHook script ->
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

        CreateEnvironment ->
            { model | nixInit = buildNixInit model, nixConfig = buildNixConfig model }



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
