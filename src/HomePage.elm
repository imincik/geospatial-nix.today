module HomePage exposing (main)

import Browser
import Dict exposing (Dict)
import GeoPackages
import GeoPostgresqlPackages
import GeoPythonPackages
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Maybe exposing (withDefault)
import NixConfig
import NixModules
import Packages
import PostgresqlPackages
import PythonPackages
import QGISPackages
import QGISPlugins
import Regex
import Texts
    exposing
        ( aboutText
        , configTemplateComment
        , configTemplateCommentDocs
        , containerTemplate
        , containerTemplateComment
        , futurePlansText
        , initTemplate
        , initTemplateComment
        , installNixTemplate
        , installNixTemplateComment
        , servicesTemplate
        , servicesTemplateComment
        , shareTemplate
        , shareTemplateComment
        , shareTemplateComment2
        , shellTemplate
        , shellTemplateComment
        )



-- MODEL
-- packages


type alias Package =
    ( String, String )


type alias Packages =
    List Package


allPackages : Packages
allPackages =
    Packages.packages


allGeoPackages : Packages
allGeoPackages =
    GeoPackages.packages


allQGISPackages : Packages
allQGISPackages =
    QGISPackages.packages


allQGISPlugins : Packages
allQGISPlugins =
    QGISPlugins.packages


allPythonPackages : Packages
allPythonPackages =
    GeoPythonPackages.packages ++ PythonPackages.packages


allPostgresPackages : Packages
allPostgresPackages =
    GeoPostgresqlPackages.packages ++ PostgresqlPackages.packages


type alias Model =
    { configName : String

    -- packages
    , packagesAvailable : List Package
    , packagesGeoAvailable : List Package
    , configPackages : List Package
    , configGeoPackages : List Package

    -- apps
    , packagesQGISAvailable : List Package
    , packagesQGISPluginsAvailable : List Package
    , configQGISEnabled : Bool
    , configQGISPackage : Package
    , configQGISPythonPackages : List Package
    , configQGISPlugins : List Package

    -- python
    , packagesPythonAvailable : List Package
    , configPythonEnabled : Bool
    , configPythonPackages : List Package
    , configPythonPoetryEnabled : Bool

    -- jupyter
    , configJupyterEnabled : Bool
    , configJupyterPythonPackages : List Package
    , configJupyterListenAddress : String
    , configJupyterListenPort : String
    , configJupyterRawConfig : String

    -- postgresql
    , packagesPostgresAvailable : List Package
    , configPostgresEnabled : Bool
    , configPostgresPackages : List Package
    , configPostgresInitdbArgs : String
    , configPostgresInitialScript : String
    , configPostgresListenAddresses : String
    , configPostgresListenPort : String
    , configPostgresSettings : String

    -- custom process
    , configCustomProcessEnabled : Bool
    , configCustomProcessExec : String

    -- data
    , configDataFromUrlDatasets : String

    -- other
    , configOpenGLEnabled : Bool
    , configEnterShell : String

    -- nix config
    , nixInit : String
    , nixConfig : String

    -- UI section
    , uiActiveCategoryTab : String

    -- filters
    , uiFilterLimit : Int
    , uiFilterLimitDefault : Int
    , uiFilterPackages : Dict String String
    }


initialModel : Model
initialModel =
    { configName = "My geospatial environment"

    -- packages
    , packagesAvailable = allPackages
    , packagesGeoAvailable = allGeoPackages
    , configPackages = NixModules.packages.packages
    , configGeoPackages = NixModules.packages.packages

    -- apps
    , packagesQGISAvailable = allQGISPackages
    , packagesQGISPluginsAvailable = allQGISPlugins
    , configQGISEnabled = NixModules.qgis.enabled
    , configQGISPackage = Maybe.withDefault ( "", "" ) (List.head allQGISPackages)
    , configQGISPythonPackages = NixModules.qgis.pythonPackages
    , configQGISPlugins = NixModules.qgis.plugins

    -- python
    , packagesPythonAvailable = allPythonPackages
    , configPythonEnabled = NixModules.python.enabled
    , configPythonPackages = NixModules.python.packages
    , configPythonPoetryEnabled = NixModules.python.poetryEnabled

    -- jupyter
    , configJupyterEnabled = NixModules.jupyter.enabled
    , configJupyterPythonPackages = NixModules.jupyter.pythonPackages
    , configJupyterListenAddress = NixModules.jupyter.listenAddress.default
    , configJupyterListenPort = NixModules.jupyter.listenPort.default
    , configJupyterRawConfig = NixModules.jupyter.rawConfig.default

    -- postgresql
    , packagesPostgresAvailable = allPostgresPackages
    , configPostgresEnabled = NixModules.postgres.enabled
    , configPostgresPackages = NixModules.postgres.packages
    , configPostgresInitdbArgs = NixModules.postgres.initdbArgs.default
    , configPostgresInitialScript = NixModules.postgres.initialScript.default
    , configPostgresListenAddresses = NixModules.postgres.listenAddresses.default
    , configPostgresListenPort = NixModules.postgres.listenPort.default
    , configPostgresSettings = NixModules.postgres.settings.default

    -- custom process
    , configCustomProcessEnabled = NixModules.customProcess.enabled
    , configCustomProcessExec = NixModules.customProcess.exec.default

    -- data
    , configDataFromUrlDatasets = NixModules.dataFromUrl.datasets.default

    -- other
    , configOpenGLEnabled = NixModules.openGL.enabled
    , configEnterShell = NixModules.shellHook.enterShell.default

    -- nix config
    , nixInit = ""
    , nixConfig = ""

    -- UI section
    , uiActiveCategoryTab = "packages"

    -- filters
    , uiFilterLimit = 3
    , uiFilterLimitDefault = 3
    , uiFilterPackages = Dict.empty
    }



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        -- header
        [ div [ class "row" ]
            [ div [ class "col-lg-12 border fw-bold fs-1 py-3 my-3" ]
                [ p []
                    [ span [ style "margin-right" "10px" ] [ text "GEOSPATIAL NIX" ]
                    , span [ class "fs-2 text-secondary" ] [ text "the reproducible geospatial environment" ]
                    ]
                ]
            ]

        -- configuration options
        , div [ class "row" ]
            [ div [ class "col-lg-6 border bg-light py-3 my-3" ]
                [ div [ class "name d-flex justify-content-between align-items-center" ]
                    [ input [ class "form-control form-control-lg", style "margin" "10px", placeholder "Environment name ...", value model.configName, onInput ConfigName ] []
                    , button [ class "btn btn-primary btn-lg", onClick CreateEnvironment ] [ text "Create" ]
                    ]

                -- separator
                , div [] [ hr [] [] ]

                -- tabs
                , div [ class "d-flex btn-group align-items-center" ]
                    (mainCategoryHtmlTab [ "PACKAGES", "LANGUAGES", "SERVICES", "DATA", "OTHER" ] model.uiActiveCategoryTab)

                -- qgis app
                , optionalHtmlDiv (model.uiActiveCategoryTab == "packages")
                    (div [ class "apps" ]
                        [ -- qgis
                          div [ class "qgis" ]
                            (optionalHtmlDivElements model.configQGISEnabled
                                [ hr [] []
                                , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                                    [ text "QGIS"
                                    , isEnabledButton model.configQGISEnabled ConfigQGISEnable
                                    ]
                                ]
                                [ p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                                    [ text "package"
                                    ]
                                , packagesHtmlList model.packagesQGISAvailable [ model.configQGISPackage ] model.uiFilterPackages "qgis" model.uiFilterLimit ConfigQGISSetPackage
                                , p [ class "text-secondary" ]
                                    [ packagesCountText (List.length model.packagesQGISAvailable) (List.length [ model.configQGISPackage ])
                                    , morePackagesButton model.uiFilterLimit model.uiFilterLimitDefault
                                    ]
                                , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                                    [ text "python"
                                    , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for Python packages ...", value (getFilterPackagesText model.uiFilterPackages "qgis-python-packages"), onInput (UiFilterPackages "qgis-python-packages") ] []
                                    ]
                                , packagesHtmlList model.packagesPythonAvailable model.configQGISPythonPackages model.uiFilterPackages "qgis-python-packages" model.uiFilterLimit ConfigQGISAddPythonPackage
                                , p [ class "text-secondary" ]
                                    [ packagesCountText (List.length model.packagesPythonAvailable) (List.length model.configQGISPythonPackages)
                                    , morePackagesButton model.uiFilterLimit model.uiFilterLimitDefault
                                    ]
                                , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                                    [ text "plugins"
                                    , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for plugins ...", value (getFilterPackagesText model.uiFilterPackages "qgis-python-plugins"), onInput (UiFilterPackages "qgis-python-plugins") ] []
                                    ]
                                , packagesHtmlList model.packagesQGISPluginsAvailable model.configQGISPlugins model.uiFilterPackages "qgis-python-plugins" model.uiFilterLimit ConfigQGISAddPlugin
                                , p [ class "text-secondary" ]
                                    [ packagesCountText (List.length model.packagesQGISPluginsAvailable) (List.length model.configQGISPlugins)
                                    , morePackagesButton model.uiFilterLimit model.uiFilterLimitDefault
                                    ]
                                ]
                            )
                        ]
                    )

                -- geospatial packages
                , optionalHtmlDiv (model.uiActiveCategoryTab == "packages")
                    (div [ class "packages" ]
                        [ hr [] []
                        , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                            [ text "PACKAGES"
                            , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for packages ...", value (getFilterPackagesText model.uiFilterPackages "packages"), onInput (UiFilterPackages "packages") ] []
                            ]
                        , p [ class "fw-bold fs-4" ]
                            [ text "geospatial"
                            ]
                        , packagesHtmlList model.packagesGeoAvailable model.configGeoPackages model.uiFilterPackages "packages" model.uiFilterLimit ConfigAddGeoPackage
                        , p [ class "text-secondary" ]
                            [ packagesCountText (List.length model.packagesGeoAvailable) (List.length model.configGeoPackages)
                            , morePackagesButton model.uiFilterLimit model.uiFilterLimitDefault
                            ]
                        ]
                    )

                -- packages
                , optionalHtmlDiv (model.uiActiveCategoryTab == "packages")
                    (div [ class "packages" ]
                        [ p [ class "fw-bold fs-4" ]
                            [ text "nixpkgs"
                            ]
                        , packagesHtmlList model.packagesAvailable model.configPackages model.uiFilterPackages "packages" model.uiFilterLimit ConfigAddPackage
                        , p [ class "text-secondary" ]
                            [ packagesCountText (List.length model.packagesAvailable) (List.length model.configPackages)
                            , morePackagesButton model.uiFilterLimit model.uiFilterLimitDefault
                            ]
                        ]
                    )

                -- languages
                , optionalHtmlDiv (model.uiActiveCategoryTab == "languages")
                    (div [ class "languages" ]
                        [ -- python
                          div [ class "python" ]
                            (optionalHtmlDivElements model.configPythonEnabled
                                [ hr [] []
                                , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                                    [ text "PYTHON"
                                    , isEnabledButton model.configPythonEnabled ConfigPythonEnable
                                    ]
                                ]
                                [ p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                                    [ text "packages"
                                    , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for Python packages ...", value (getFilterPackagesText model.uiFilterPackages "python"), onInput (UiFilterPackages "python") ] []
                                    ]
                                , packagesHtmlList model.packagesPythonAvailable model.configPythonPackages model.uiFilterPackages "python" model.uiFilterLimit ConfigPythonAddPackage
                                , p [ class "text-secondary" ]
                                    [ packagesCountText (List.length model.packagesPythonAvailable) (List.length model.configPythonPackages)
                                    , morePackagesButton model.uiFilterLimit model.uiFilterLimitDefault
                                    ]
                                , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                                    [ text "poetry"
                                    , isEnabledButton model.configPythonPoetryEnabled ConfigPythonPoetryEnable
                                    ]
                                ]
                            )
                        ]
                    )

                -- services
                , optionalHtmlDiv (model.uiActiveCategoryTab == "services")
                    (div [ class "services" ]
                        [ -- jupyter
                          div [ class "jupyter" ]
                            (optionalHtmlDivElements model.configJupyterEnabled
                                [ hr [] []
                                , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                                    [ text "JUPYTER"
                                    , isEnabledButton model.configJupyterEnabled ConfigJupyterEnable
                                    ]
                                ]
                                [ p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                                    [ text "python"
                                    , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for Python packages ...", value (getFilterPackagesText model.uiFilterPackages "jupyter-python-packages"), onInput (UiFilterPackages "jupyter-python-packages") ] []
                                    ]
                                , packagesHtmlList model.packagesPythonAvailable model.configJupyterPythonPackages model.uiFilterPackages "jupyter-python-packages" model.uiFilterLimit ConfigJupyterAddPythonPackage
                                , p [ class "text-secondary" ]
                                    [ packagesCountText (List.length model.packagesPythonAvailable) (List.length model.configJupyterPythonPackages)
                                    , morePackagesButton model.uiFilterLimit model.uiFilterLimitDefault
                                    ]
                                , p [ class "fw-bold fs-4" ]
                                    [ text "raw config"
                                    , useExampleButton ConfigJupyterRawConfig NixModules.jupyter.rawConfig.example
                                    , textarea [ class "form-control form-control-lg", placeholder NixModules.jupyter.rawConfig.example, value model.configJupyterRawConfig, onInput ConfigJupyterRawConfig ] []
                                    ]
                                , p [ class "fw-bold fs-4" ]
                                    [ text "listen address"
                                    , input [ class "form-control form-control-lg", value model.configJupyterListenAddress, onInput ConfigJupyterListenAddress ] []
                                    ]
                                , p [ class "fw-bold fs-4" ]
                                    [ text "port"
                                    , input [ class "form-control form-control-lg", value model.configJupyterListenPort, onInput ConfigJupyterListenPort ] []
                                    ]
                                ]
                            )

                        -- postgres
                        , div [ class "postgres" ]
                            (optionalHtmlDivElements model.configPostgresEnabled
                                [ hr [] []
                                , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                                    [ text "POSTGRESQL"
                                    , isEnabledButton model.configPostgresEnabled ConfigPostgresEnable
                                    ]
                                ]
                                [ p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                                    [ text "packages"
                                    , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for PostgreSQL packages ...", value (getFilterPackagesText model.uiFilterPackages "postgres-packages"), onInput (UiFilterPackages "postgres-packages") ] []
                                    ]
                                , packagesHtmlList model.packagesPostgresAvailable model.configPostgresPackages model.uiFilterPackages "postgres-packages" model.uiFilterLimit ConfigPostgresAddPackage
                                , p [ class "text-secondary" ]
                                    [ packagesCountText (List.length model.packagesPostgresAvailable) (List.length model.configPostgresPackages)
                                    , morePackagesButton model.uiFilterLimit model.uiFilterLimitDefault
                                    ]
                                , p [ class "fw-bold fs-4" ]
                                    [ text "initdb arguments"
                                    , textarea [ class "form-control form-control-lg", placeholder NixModules.postgres.initdbArgs.example, value model.configPostgresInitdbArgs, onInput ConfigPostgresInitdbArgs ] []
                                    ]
                                , p [ class "fw-bold fs-4" ]
                                    [ text "initial script"
                                    , useExampleButton ConfigPostgresInitialScript NixModules.postgres.initialScript.example
                                    , textarea [ class "form-control form-control-lg", placeholder NixModules.postgres.initialScript.example, value model.configPostgresInitialScript, onInput ConfigPostgresInitialScript ] []
                                    ]
                                , p [ class "fw-bold fs-4" ]
                                    [ text "settings"
                                    , useExampleButton ConfigPostgresSettings NixModules.postgres.settings.example
                                    , textarea [ class "form-control form-control-lg", placeholder NixModules.postgres.settings.example, value model.configPostgresSettings, onInput ConfigPostgresSettings ] []
                                    ]
                                , p [ class "fw-bold fs-4" ]
                                    [ text "listen addresses"
                                    , input [ class "form-control form-control-lg", value model.configPostgresListenAddresses, onInput ConfigPostgresListenAddresses ] []
                                    ]
                                , p [ class "fw-bold fs-4" ]
                                    [ text "port"
                                    , input [ class "form-control form-control-lg", value model.configPostgresListenPort, onInput ConfigPostgresListenPort ] []
                                    ]
                                ]
                            )

                        -- custom process
                        , div [ class "custom-process" ]
                            (optionalHtmlDivElements model.configCustomProcessEnabled
                                [ hr [] []
                                , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                                    [ text "CUSTOM PROCESS"
                                    , isEnabledButton model.configCustomProcessEnabled ConfigCustomProcessEnable
                                    ]
                                ]
                                [ p [ class "fw-bold fs-4" ]
                                    [ text "command"
                                    , useExampleButton ConfigCustomProcessExec NixModules.customProcess.exec.example
                                    , input [ class "form-control form-control-lg", placeholder NixModules.customProcess.exec.example, value model.configCustomProcessExec, onInput ConfigCustomProcessExec ] []
                                    ]
                                , br [] []
                                ]
                            )
                        ]
                    )

                -- data
                , optionalHtmlDiv (model.uiActiveCategoryTab == "data")
                    (div [ class "data" ]
                        [ div [ class "data-from-url" ]
                            [ hr [] []
                            , p [ class "fw-bold fs-4" ]
                                [ text "from URL"
                                , useExampleButton ConfigDataFromUrlEnable NixModules.dataFromUrl.datasets.example
                                , textarea [ class "form-control form-control-lg", placeholder NixModules.dataFromUrl.datasets.example, value model.configDataFromUrlDatasets, onInput ConfigDataFromUrlEnable ] []
                                ]
                            ]
                        ]
                    )

                -- other
                , optionalHtmlDiv (model.uiActiveCategoryTab == "other")
                    (div [ class "other" ]
                        [ -- openGL
                          div [ class "opengl" ]
                            [ hr [] []
                            , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                                [ text "openGL"
                                , isEnabledButton model.configOpenGLEnabled ConfigOpenGLEnable
                                ]
                            ]

                        -- shell hook
                        , div [ class "shell-hook" ]
                            [ hr [] []
                            , p [ class "fw-bold fs-4" ]
                                [ text "shell hook"
                                , useExampleButton ConfigShellHookEnable NixModules.shellHook.enterShell.example
                                , textarea [ class "form-control form-control-lg", placeholder NixModules.shellHook.enterShell.example, value model.configEnterShell, onInput ConfigShellHookEnable ] []
                                ]
                            ]
                        ]
                    )
                ]

            -- configuration
            , div [ class "col-lg-6 bg-dark text-white py-3 my-3" ]
                [ if not (String.isEmpty model.nixConfig) then
                    div [ class "configuration" ]
                        [ h2 [] [ text "INSTALL NIX" ]
                        , p [ style "margin-bottom" "0em" ] installNixTemplateComment
                        , pre [ class "text-warning" ] [ text installNixTemplate ]
                        , hr [] []
                        , h2 [] [ text "START PROJECT" ]
                        , p [ style "margin-bottom" "0em" ] [ text initTemplateComment ]
                        , pre [ class "text-warning" ] [ text model.nixInit ]
                        , hr [] []
                        , h2 [] [ text "CONFIGURATION" ]
                        , p [ style "margin-bottom" "0em" ] [ text configTemplateComment ]
                        , pre [ class "text-warning" ] [ text model.nixConfig ]
                        , p [ style "margin-bottom" "0em" ] configTemplateCommentDocs
                        , hr [] []
                        , h2 [] [ text "ENTER ENVIRONMENT" ]
                        , p [ style "margin-bottom" "0em" ] [ text shellTemplateComment ]
                        , pre [ class "text-warning" ] [ text shellTemplate ]
                        , hr [] []
                        , h2 [] [ text "LAUNCH SERVICES" ]
                        , p [ style "margin-bottom" "0em" ] [ text servicesTemplateComment ]
                        , pre [ class "text-warning" ] [ text servicesTemplate ]
                        , hr [] []
                        , h2 [] [ text "RUN IN CONTAINER" ]
                        , p [ style "margin-bottom" "0em" ] [ text containerTemplateComment ]
                        , pre [ class "text-warning" ] [ text containerTemplate ]
                        , hr [] []
                        , h2 [] [ text "SHARE ENVIRONMENT" ]
                        , p [ style "margin-bottom" "0em" ] [ text shareTemplateComment ]
                        , pre [ class "text-warning" ] [ text shareTemplate ]
                        , span [] [ text shareTemplateComment2 ]
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
                        , h3 [] [ text "DOCUMENTATION" ]
                        , p []
                            [ text "Check out our "
                            , a [ href "https://imincik.github.io/geospatial-nix.env", target "_blank" ] [ text "documentation" ]
                            , text " and read more about Nix at "
                            , a [ href "https://nix.dev", target "_blank" ] [ text "nix.dev." ]
                            ]
                        , h3 [] [ text "AUTHORS" ]
                        , text "Created by "
                        , a [ href "https://github.com/imincik", target "_blank" ] [ text "Ivan Mincik, @imincik" ]
                        , text "."
                        ]
                ]
            ]

        -- footer
        , div [ class "col-sm-12" ]
            [ hr [] []
            , p [ class "text-center" ]
                [ span [ class "text-secondary fs-6" ] [ text "Powered by " ]
                , a [ href "https://github.com/imincik/geospatial-nix", target "_blank" ] [ text "Geospatial NIX" ]
                , text " , "
                , a [ href "https://github.com/imincik/geospatial-nix.env", target "_blank" ] [ text "Geospatial NIX.env" ]
                , text " , "
                , a [ href "https://nixos.org", target "_blank" ] [ text "Nix and Nixpkgs" ]
                , text " ."
                ]
            ]
        ]



-- HTML functions


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
                    , onClick (UiSetActiveCategoryTab (String.toLower item))
                    ]
                    [ text item ]
    in
    List.map buttonItem buttons


optionalHtmlDiv : Bool -> Html Msg -> Html Msg
optionalHtmlDiv condition divElement =
    if condition then
        divElement

    else
        div [] []


optionalHtmlDivElements : Bool -> List a -> List a -> List a
optionalHtmlDivElements condition first second =
    if condition then
        first ++ second

    else
        first


packagesHtmlList : List Package -> List Package -> Dict String String -> String -> Int -> (Package -> Msg) -> Html Msg
packagesHtmlList availableItems selectedItems filterDict filterCategory filterLimit onClickAction =
    let
        filter =
            withDefault "" (Dict.get filterCategory filterDict)

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


morePackagesButton : Int -> Int -> Html Msg
morePackagesButton filterLimit filterLimitDefault =
    button [ class "btn btn-sm btn-link", onClick UiUpdateFilterLimit ]
        [ if filterLimit < 4 * filterLimitDefault then
            text "show more"

          else
            text "show less"
        ]


useExampleButton : (String -> Msg) -> String -> Html Msg
useExampleButton onClickAction value =
    button [ class "btn btn-sm btn-link", onClick (onClickAction value) ] [ text "use example" ]


isEnabledButton : Bool -> Msg -> Html Msg
isEnabledButton isEnabled onClickAction =
    button
        [ class
            ("btn btn-sm "
                ++ (if isEnabled then
                        "btn-success"

                    else
                        "btn-secondary"
                   )
            )
        , style "margin" "5px"
        , onClick onClickAction
        ]
        [ text (boolToEnabledString isEnabled) ]



-- NON-HTML functions


optionalString : Bool -> String -> String
optionalString condition string =
    if condition then
        string

    else
        ""


environmentName : String -> String
environmentName name =
    String.toLower (String.replace " " "-" name)


packageToName : Package -> String
packageToName package =
    Tuple.first package


packagesListToNamesList : List Package -> List String
packagesListToNamesList packages =
    List.map (\item -> packageToName item) packages


boolToString : Bool -> String
boolToString value =
    if value then
        "true"

    else
        "false"


boolToEnabledString : Bool -> String
boolToEnabledString value =
    if value then
        "enabled"

    else
        "disabled"


getFilterPackagesText : Dict String String -> String -> String
getFilterPackagesText filterDict filterCategory =
    withDefault "" (Dict.get filterCategory filterDict)


nixCodeCleanup : String -> String
nixCodeCleanup code =
    let
        -- empty multiline string
        -- someConfig = ''
        --
        -- '';
        emptyMultiLineString =
            Regex.fromString "''\\n.*\n.*'';"

        emptyMultiLineStringRx =
            ( Maybe.withDefault Regex.never emptyMultiLineString, "\"\";" )
    in
    -- replace empty multiline string with ""
    Regex.replace (Tuple.first emptyMultiLineStringRx) (\_ -> Tuple.second emptyMultiLineStringRx) code


type Msg
    = ConfigName String
    | ConfigAddPackage Package
    | ConfigAddGeoPackage Package
    | ConfigQGISEnable
    | ConfigQGISSetPackage Package
    | ConfigQGISAddPythonPackage Package
    | ConfigQGISAddPlugin Package
    | ConfigPythonEnable
    | ConfigPythonAddPackage Package
    | ConfigPythonPoetryEnable
    | ConfigJupyterEnable
    | ConfigJupyterAddPythonPackage Package
    | ConfigJupyterListenAddress String
    | ConfigJupyterListenPort String
    | ConfigJupyterRawConfig String
    | ConfigPostgresEnable
    | ConfigPostgresAddPackage Package
    | ConfigPostgresInitdbArgs String
    | ConfigPostgresInitialScript String
    | ConfigPostgresListenAddresses String
    | ConfigPostgresListenPort String
    | ConfigPostgresSettings String
    | ConfigCustomProcessEnable
    | ConfigCustomProcessExec String
    | ConfigDataFromUrlEnable String
    | ConfigOpenGLEnable
    | ConfigShellHookEnable String
      -- nix config
    | CreateEnvironment
      -- ui
    | UiSetActiveCategoryTab String
    | UiFilterPackages String String
    | UiUpdateFilterLimit



-- UPDATE


buildNixInit : Model -> String
buildNixInit model =
    String.replace "<NAME>" (environmentName model.configName) initTemplate


buildNixConfig : Model -> String
buildNixConfig model =
    let
        selectedPackages =
            packagesListToNamesList model.configGeoPackages ++ packagesListToNamesList model.configPackages

        selectedQGISPackage =
            packageToName model.configQGISPackage

        selectedQGISPythonPackages =
            packagesListToNamesList model.configQGISPythonPackages

        selectedQGISPlugins =
            packagesListToNamesList model.configQGISPlugins

        selectedPyPackages =
            packagesListToNamesList model.configPythonPackages

        selectedJupyterPythonKernels =
            if List.length model.configJupyterPythonPackages > 0 then
                NixConfig.configJupyterKernelsTemplate

            else
                ""

        selectedJupyterPythonPackages =
            packagesListToNamesList model.configJupyterPythonPackages

        selectedPgPackages =
            packagesListToNamesList model.configPostgresPackages

        nixConfigBody =
            NixConfig.configNameTemplate
                ++ NixConfig.configPackagesTemplate
                ++ optionalString model.configQGISEnabled NixConfig.configQGISTemplate
                ++ optionalString model.configPythonEnabled NixConfig.configPythonTemplate
                ++ optionalString model.configJupyterEnabled NixConfig.configJupyterTemplate
                ++ optionalString model.configPostgresEnabled NixConfig.configPostgresTemplate
                ++ optionalString model.configCustomProcessEnabled NixConfig.configCustomProcessTemplate
                ++ optionalString (model.configDataFromUrlDatasets /= "") NixConfig.configDataFromUrlTemplate
                ++ optionalString model.configOpenGLEnabled NixConfig.configOpenGLTemplate
                ++ optionalString (model.configEnterShell /= "") NixConfig.configEnterShellTemplate

        nixConfig =
            String.replace "<CONFIG-BODY>" nixConfigBody NixConfig.configTemplate
    in
    String.replace "<NAME>" (environmentName model.configName) nixConfig
        -- packages
        |> String.replace "<PACKAGES>" (String.join " " selectedPackages)
        -- qgis
        |> String.replace "<QGIS-ENABLED>" (boolToString model.configQGISEnabled)
        |> String.replace "<QGIS-PACKAGE>" selectedQGISPackage
        |> String.replace "<QGIS-PYTHON-PACKAGES>" (String.join " " selectedQGISPythonPackages)
        |> String.replace "<QGIS-PLUGINS>" (String.join " " selectedQGISPlugins)
        -- python
        |> String.replace "<PYTHON-ENABLED>" (boolToString model.configPythonEnabled)
        |> String.replace "<PYTHON-PACKAGES>" (String.join " " selectedPyPackages)
        |> String.replace "<PYTHON-POETRY-ENABLED>" (boolToString model.configPythonPoetryEnabled)
        -- jupyter
        |> String.replace "<JUPYTER-ENABLED>" (boolToString model.configJupyterEnabled)
        |> String.replace "<JUPYTER-KERNELS>" selectedJupyterPythonKernels
        |> String.replace "<JUPYTER-PYTHON-PACKAGES>" (String.join " " selectedJupyterPythonPackages)
        |> String.replace "<JUPYTER-LISTEN-ADDRESS>" model.configJupyterListenAddress
        |> String.replace "<JUPYTER-LISTEN-PORT>" model.configJupyterListenPort
        |> String.replace "<JUPYTER-RAW-CONFIG>" (String.replace "\n" "\n      " model.configJupyterRawConfig)
        -- postgres
        |> String.replace "<POSTGRES-ENABLED>" (boolToString model.configPostgresEnabled)
        |> String.replace "<POSTGRES-PACKAGES>" (String.join " " selectedPgPackages)
        |> String.replace "<POSTGRES-INITDB-ARGS>" (String.replace "\n" " " model.configPostgresInitdbArgs)
        |> String.replace "<POSTGRES-INITIAL-SCRIPT>" (String.replace "\n" " " model.configPostgresInitialScript)
        |> String.replace "<POSTGRES-LISTEN-ADDRESSES>" model.configPostgresListenAddresses
        |> String.replace "<POSTGRES-LISTEN-PORT>" model.configPostgresListenPort
        |> String.replace "<POSTGRES-SETTINGS>" (String.replace "\n" " " model.configPostgresSettings)
        -- data
        |> String.replace "<DATA-FROM-URL-DATASETS>" (String.replace "\n" " " model.configDataFromUrlDatasets)
        -- other
        |> String.replace "<CUSTOM-PROCESS>" model.configCustomProcessExec
        |> String.replace "<SHELL-HOOK>" model.configEnterShell
        -- nix code cleanup
        |> nixCodeCleanup


update : Msg -> Model -> Model
update msg model =
    case msg of
        ConfigName name ->
            { model | configName = name }

        ConfigAddPackage pkg ->
            if not (List.member pkg model.configPackages) then
                { model | configPackages = model.configPackages ++ [ pkg ] }

            else
                { model | configPackages = List.filter (\x -> x /= pkg) model.configPackages }

        ConfigAddGeoPackage pkg ->
            if not (List.member pkg model.configGeoPackages) then
                { model | configGeoPackages = model.configGeoPackages ++ [ pkg ] }

            else
                { model | configGeoPackages = List.filter (\x -> x /= pkg) model.configGeoPackages }

        ConfigQGISEnable ->
            { model
                | configQGISEnabled =
                    if not model.configQGISEnabled then
                        True

                    else
                        False
            }

        ConfigQGISSetPackage pkg ->
            { model | configQGISPackage = pkg }

        ConfigQGISAddPythonPackage pkg ->
            if not (List.member pkg model.configQGISPythonPackages) then
                { model | configQGISPythonPackages = model.configQGISPythonPackages ++ [ pkg ] }

            else
                { model | configQGISPythonPackages = List.filter (\x -> x /= pkg) model.configQGISPythonPackages }

        ConfigQGISAddPlugin pkg ->
            if not (List.member pkg model.configQGISPlugins) then
                { model | configQGISPlugins = model.configQGISPlugins ++ [ pkg ] }

            else
                { model | configQGISPlugins = List.filter (\x -> x /= pkg) model.configQGISPlugins }

        ConfigPythonEnable ->
            { model
                | configPythonEnabled =
                    if not model.configPythonEnabled then
                        True

                    else
                        False
            }

        ConfigPythonAddPackage pkg ->
            if not (List.member pkg model.configPythonPackages) then
                { model | configPythonPackages = model.configPythonPackages ++ [ pkg ], configPythonEnabled = True }

            else
                { model | configPythonPackages = List.filter (\x -> x /= pkg) model.configPythonPackages }

        ConfigPythonPoetryEnable ->
            { model
                | configPythonPoetryEnabled =
                    if not model.configPythonPoetryEnabled then
                        True

                    else
                        False
                , configPythonEnabled =
                    if not model.configPythonPoetryEnabled then
                        True

                    else
                        -- not a typo, don't disable python when disabling poetry
                        True
            }

        ConfigJupyterEnable ->
            { model
                | configJupyterEnabled =
                    if not model.configJupyterEnabled then
                        True

                    else
                        False
            }

        ConfigJupyterAddPythonPackage pkg ->
            if not (List.member pkg model.configJupyterPythonPackages) then
                { model | configJupyterPythonPackages = model.configJupyterPythonPackages ++ [ pkg ], configJupyterEnabled = True }

            else
                { model | configJupyterPythonPackages = List.filter (\x -> x /= pkg) model.configJupyterPythonPackages }

        ConfigJupyterListenAddress val ->
            { model | configJupyterListenAddress = val }

        ConfigJupyterListenPort val ->
            { model | configJupyterListenPort = val }

        ConfigJupyterRawConfig val ->
            { model | configJupyterRawConfig = val }

        ConfigPostgresEnable ->
            { model
                | configPostgresEnabled =
                    if not model.configPostgresEnabled then
                        True

                    else
                        False
            }

        ConfigPostgresAddPackage pkg ->
            if not (List.member pkg model.configPostgresPackages) then
                { model | configPostgresPackages = model.configPostgresPackages ++ [ pkg ], configPostgresEnabled = True }

            else
                { model | configPostgresPackages = List.filter (\x -> x /= pkg) model.configPostgresPackages }

        ConfigPostgresInitdbArgs val ->
            { model | configPostgresInitdbArgs = val }

        ConfigPostgresInitialScript val ->
            { model | configPostgresInitialScript = val }

        ConfigPostgresListenAddresses val ->
            { model | configPostgresListenAddresses = val }

        ConfigPostgresListenPort val ->
            { model | configPostgresListenPort = val }

        ConfigPostgresSettings val ->
            { model | configPostgresSettings = val }

        ConfigCustomProcessEnable ->
            { model
                | configCustomProcessEnabled =
                    if not model.configCustomProcessEnabled then
                        True

                    else
                        False
            }

        ConfigCustomProcessExec script ->
            { model | configCustomProcessExec = script, configCustomProcessEnabled = True }

        ConfigDataFromUrlEnable datasets ->
            { model | configDataFromUrlDatasets = datasets }

        ConfigOpenGLEnable ->
            { model
                | configOpenGLEnabled =
                    if not model.configOpenGLEnabled then
                        True

                    else
                        False
            }

        ConfigShellHookEnable script ->
            { model | configEnterShell = script }

        CreateEnvironment ->
            { model | nixInit = buildNixInit model, nixConfig = buildNixConfig model }

        -- UI section
        UiSetActiveCategoryTab tab ->
            { model | uiActiveCategoryTab = tab }

        UiUpdateFilterLimit ->
            { model
                | uiFilterLimit =
                    -- allow to increase limit up to 4 times default items
                    if model.uiFilterLimit < 4 * model.uiFilterLimitDefault then
                        2 * model.uiFilterLimit

                    else
                        model.uiFilterLimitDefault
            }

        UiFilterPackages category filter ->
            { model | uiFilterPackages = Dict.insert category filter model.uiFilterPackages }



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
