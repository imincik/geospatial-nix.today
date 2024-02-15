module HomePage exposing (main)

import Browser
import GeoPackages
import GeoPostgresqlPackages
import GeoPythonPackages
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import NixConfig
import NixModules
import Packages
import PostgresqlPackages
import PythonPackages
import Texts
    exposing
        ( aboutText
        , configTemplateComment
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
    GeoPackages.packages ++ Packages.packages


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
    , configPackages : List Package

    -- python
    , packagesPythonAvailable : List Package
    , configPythonEnabled : Bool
    , configPythonPackages : List Package
    , configPythonPoetryEnabled : Bool

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

    -- other
    , configEnterShell : String

    -- nix config
    , nixInit : String
    , nixConfig : String

    -- UI section
    , uiActiveCategoryTab : String

    -- filters
    , uiFilterLimit : Int
    , uiFilterPackages : String
    , uiFilterPyPackages : String
    , uiFilterPgPackages : String
    }


initialModel : Model
initialModel =
    { configName = "My geospatial environment"

    -- packages
    , packagesAvailable = allPackages
    , configPackages = NixModules.packages.packages

    -- python
    , packagesPythonAvailable = allPythonPackages
    , configPythonEnabled = NixModules.python.enabled
    , configPythonPackages = NixModules.python.packages
    , configPythonPoetryEnabled = NixModules.python.poetryEnabled

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

    -- other
    , configEnterShell = ""

    -- nix config
    , nixInit = ""
    , nixConfig = ""

    -- UI section
    , uiActiveCategoryTab = "packages"

    -- filters
    , uiFilterLimit = 5
    , uiFilterPackages = ""
    , uiFilterPyPackages = ""
    , uiFilterPgPackages = ""
    }



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-12 border fw-bold fs-1 py-3 my-3" ]
                [ p []
                    [ span [ style "margin-right" "10px" ] [ text "GEOSPATIAL NIX" ]
                    , span [ class "fs-2 text-secondary" ] [ text "create, use and deploy today ..." ]
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
                    (mainCategoryHtmlTab [ "PACKAGES", "LANGUAGES", "SERVICES", "OTHER" ] model.uiActiveCategoryTab)

                -- packages
                , if model.uiActiveCategoryTab == "packages" then
                    div [ class "packages" ]
                        [ hr [] []
                        , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                            [ text "packages"
                            , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for packages ...", value model.uiFilterPackages, onInput UiFilterPackages ] []
                            ]
                        , packagesHtmlList model.packagesAvailable model.configPackages model.uiFilterPackages model.uiFilterLimit ConfigAddPackage
                        , p [ class "text-secondary" ]
                            [ packagesCountText (List.length model.packagesAvailable) (List.length model.configPackages)
                            , morePackagesButton model.uiFilterLimit
                            ]
                        ]

                  else
                    div [] []

                -- languages
                , if model.uiActiveCategoryTab == "languages" then
                    div [ class "languages" ]
                        [ hr [] []
                        , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                            [ text "PYTHON"
                            , isEnabledButton model.configPythonEnabled ConfigPythonEnable
                            ]
                        , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                            [ text "packages"
                            , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for Python packages ...", value model.uiFilterPyPackages, onInput UiFilterPythonPackages ] []
                            ]
                        , packagesHtmlList model.packagesPythonAvailable model.configPythonPackages model.uiFilterPyPackages model.uiFilterLimit ConfigPythonAddPackage
                        , p [ class "text-secondary" ]
                            [ packagesCountText (List.length model.packagesPythonAvailable) (List.length model.configPythonPackages)
                            , morePackagesButton model.uiFilterLimit
                            ]
                        , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                            [ text "poetry"
                            , isEnabledButton model.configPythonPoetryEnabled ConfigPythonPoetryEnable
                            ]
                        ]

                  else
                    div [] []

                -- services
                , if model.uiActiveCategoryTab == "services" then
                    div [ class "services" ]
                        [ hr [] []

                        -- postgres
                        , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                            [ text "POSTGRESQL"
                            , isEnabledButton model.configPostgresEnabled ConfigPostgresEnable
                            ]
                        , p [ class "fw-bold fs-4 d-flex justify-content-between align-items-center" ]
                            [ text "packages"
                            , input [ class "form-control form-control-md", style "margin-left" "10px", placeholder "Search for PostgreSQL packages ...", value model.uiFilterPgPackages, onInput UiFilterPostgresPackages ] []
                            ]
                        , packagesHtmlList model.packagesPostgresAvailable model.configPostgresPackages model.uiFilterPgPackages model.uiFilterLimit ConfigPostgresAddPackage
                        , p [ class "text-secondary" ]
                            [ packagesCountText (List.length model.packagesPostgresAvailable) (List.length model.configPostgresPackages)
                            , morePackagesButton model.uiFilterLimit
                            ]
                        , p [ class "fw-bold fs-3" ]
                            [ text "initdb arguments"
                            , textarea [ class "form-control form-control-lg", placeholder NixModules.postgres.initdbArgs.example, value model.configPostgresInitdbArgs, onInput ConfigPostgresInitdbArgs ] []
                            ]
                        , p [ class "fw-bold fs-3" ]
                            [ text "initial script"
                            , useExampleButton ConfigPostgresInitialScript NixModules.postgres.initialScript.example
                            , textarea [ class "form-control form-control-lg", placeholder NixModules.postgres.initialScript.example, value model.configPostgresInitialScript, onInput ConfigPostgresInitialScript ] []
                            ]
                        , p [ class "fw-bold fs-3" ]
                            [ text "settings"
                            , useExampleButton ConfigPostgresSettings NixModules.postgres.settings.example
                            , textarea [ class "form-control form-control-lg", placeholder NixModules.postgres.settings.example, value model.configPostgresSettings, onInput ConfigPostgresSettings ] []
                            ]
                        , p [ class "fw-bold fs-3" ]
                            [ text "listen addresses"
                            , useExampleButton ConfigPostgresListenAddresses NixModules.postgres.listenAddresses.example
                            , input [ class "form-control form-control-lg", placeholder NixModules.postgres.listenAddresses.example, value model.configPostgresListenAddresses, onInput ConfigPostgresListenAddresses ] []
                            ]
                        , p [ class "fw-bold fs-3" ]
                            [ text "port"
                            , input [ class "form-control form-control-lg", placeholder NixModules.postgres.listenPort.example, value model.configPostgresListenPort, onInput ConfigPostgresListenPort ] []
                            ]

                        -- custom process
                        , hr [] []
                        , p [ class "fw-bold fs-3 d-flex justify-content-between align-items-center" ]
                            [ text "CUSTOM PROCESS"
                            , isEnabledButton model.configCustomProcessEnabled ConfigCustomProcessEnable
                            ]
                        , p [ class "fw-bold fs-3" ]
                            [ text "command"
                            , useExampleButton ConfigCustomProcessExec NixModules.customProcess.exec.example
                            , input [ class "form-control form-control-lg", placeholder NixModules.customProcess.exec.example, value model.configCustomProcessExec, onInput ConfigCustomProcessExec ] []
                            ]
                        , br [] []
                        ]

                  else
                    div [] []

                -- other
                , if model.uiActiveCategoryTab == "other" then
                    div [ class "shell-hook" ]
                        [ hr [] []
                        , p [ class "fw-bold fs-3" ]
                            [ text "shell hook"
                            , useExampleButton ConfgiShellHookEnable NixModules.shellHook.enterShell.example
                            , textarea [ class "form-control form-control-lg", placeholder NixModules.shellHook.enterShell.example, value model.configEnterShell, onInput ConfgiShellHookEnable ] []
                            ]
                        ]

                  else
                    div [] []
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
    button [ class "btn btn-sm btn-link", onClick UiUpdateFilterLimit ]
        [ if filterLimit < 15 then
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


packagesListToNamesList : List Package -> List String
packagesListToNamesList packages =
    List.map (\item -> Tuple.first item) packages


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


type Msg
    = ConfigName String
    | ConfigAddPackage Package
    | ConfigPythonEnable
    | ConfigPythonAddPackage Package
    | ConfigPythonPoetryEnable
    | ConfigPostgresEnable
    | ConfigPostgresAddPackage Package
    | ConfigPostgresInitdbArgs String
    | ConfigPostgresInitialScript String
    | ConfigPostgresListenAddresses String
    | ConfigPostgresListenPort String
    | ConfigPostgresSettings String
    | ConfigCustomProcessEnable
    | ConfigCustomProcessExec String
    | ConfgiShellHookEnable String
      -- nix config
    | CreateEnvironment
      -- ui
    | UiSetActiveCategoryTab String
    | UiFilterPackages String
    | UiFilterPythonPackages String
    | UiFilterPostgresPackages String
    | UiUpdateFilterLimit



-- UPDATE


buildNixInit : Model -> String
buildNixInit model =
    String.replace "<NAME>" (environmentName model.configName) initTemplate


buildNixConfig : Model -> String
buildNixConfig model =
    let
        selectedPackages =
            packagesListToNamesList model.configPackages

        selectedPyPackages =
            packagesListToNamesList model.configPythonPackages

        selectedPgPackages =
            packagesListToNamesList model.configPostgresPackages

        nixConfigBody =
            NixConfig.configNameTemplate
                ++ NixConfig.configPackagesTemplate
                ++ optionalString model.configPythonEnabled NixConfig.configPythonTemplate
                ++ optionalString model.configPostgresEnabled NixConfig.configPostgresTemplate
                ++ optionalString model.configCustomProcessEnabled NixConfig.configCustomProcessTemplate
                ++ optionalString (model.configEnterShell /= "") NixConfig.configEnterShellTemplate

        nixConfig =
            String.replace "<CONFIG-BODY>" nixConfigBody NixConfig.configTemplate
    in
    String.replace "<NAME>" (environmentName model.configName) nixConfig
        |> String.replace "<PACKAGES>" (String.join " " selectedPackages)
        |> String.replace "<PYTHON-ENABLED>" (boolToString model.configPythonEnabled)
        |> String.replace "<PYTHON-PACKAGES>" (String.join " " selectedPyPackages)
        |> String.replace "<PYTHON-POETRY-ENABLED>" (boolToString model.configPythonPoetryEnabled)
        |> String.replace "<POSTGRES-ENABLED>" (boolToString model.configPostgresEnabled)
        |> String.replace "<POSTGRES-PACKAGES>" (String.join " " selectedPgPackages)
        |> String.replace "<POSTGRES-INITDB-ARGS>" (String.replace "\n" " " model.configPostgresInitdbArgs)
        |> String.replace "<POSTGRES-INITIAL-SCRIPT>" (String.replace "\n" " " model.configPostgresInitialScript)
        |> String.replace "<POSTGRES-LISTEN-ADDRESSES>" model.configPostgresListenAddresses
        |> String.replace "<POSTGRES-LISTEN-PORT>" model.configPostgresListenPort
        |> String.replace "<POSTGRES-SETTINGS>" (String.replace "\n" " " model.configPostgresSettings)
        |> String.replace "<CUSTOM-PROCESS>" model.configCustomProcessExec
        |> String.replace "<SHELL-HOOK>" model.configEnterShell


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

        ConfgiShellHookEnable script ->
            { model | configEnterShell = script }

        CreateEnvironment ->
            { model | nixInit = buildNixInit model, nixConfig = buildNixConfig model }

        -- UI section
        UiSetActiveCategoryTab tab ->
            { model | uiActiveCategoryTab = tab }

        UiUpdateFilterLimit ->
            { model
                | uiFilterLimit =
                    -- allow to increase limit up to 15 items
                    if model.uiFilterLimit < 15 then
                        model.uiFilterLimit + 5

                    else
                        5
            }

        UiFilterPackages pkg ->
            { model | uiFilterPackages = pkg }

        UiFilterPythonPackages pkg ->
            { model | uiFilterPyPackages = pkg }

        UiFilterPostgresPackages pkg ->
            { model | uiFilterPgPackages = pkg }



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
