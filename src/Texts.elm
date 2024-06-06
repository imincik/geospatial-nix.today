module Texts exposing
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

import Html exposing (a, text)
import Html.Attributes exposing (href, target)


aboutText =
    """
Create an isolated reproducible environment containing all software, services
and data declaratively configured in a single file. Run it on any Linux machine
or scale it with containers.
"""


futurePlansText =
    """
This is just very early start of a new tool which allows you to use very unique
features of Nix to power your geospatial projects. Many more features, services,
user experience improvements, MacOS and Kubernetes integration are on the way.
"""


installNixTemplateComment =
    [ text "Install Nix "
    , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
        [ text "(learn more about this installer)" ]
    ]


installNixTemplate =
    """
curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
"""


initTemplateComment =
    """
Run following commands to initalize a new project
"""


initTemplate =
    """
mkdir <NAME> && cd <NAME>

git init
nix run github:imincik/geospatial-nix.env/latest#geonixcli -- init
git add flake.nix geonix.nix
"""


configTemplateComment =
    """
Copy and paste configuration to geonix.nix file
"""


configTemplateCommentDocs =
    [ text "For more configuration options "
    , a [ href "https://imincik.github.io/geospatial-nix.env/configuration-options", target "_blank" ]
        [ text "check out documentation." ]
    ]


shellTemplateComment =
    """
Run following command to enter shell environment
"""


shellTemplate =
    """
nix run .#geonixcli -- shell
"""


servicesTemplateComment =
    """
Run following command to launch services
"""


servicesTemplate =
    """
nix run .#geonixcli -- up
"""


containerTemplateComment =
    """
Run following commands to build and run environment in container
"""


containerTemplate =
    """
nix run .#geonixcli -- container shell
docker run --rm -it shell:latest
"""


shareTemplateComment =
    """
Add environment lock file to git and push project to repository
"""


shareTemplate =
    """
git add flake.lock
git commit -m "My geospatial environment"
git push
"""


shareTemplateComment2 =
    """
Now, all your project collaborators can use exactly same environment
  containing exactly same versions of software.
"""
