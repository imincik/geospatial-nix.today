module Texts exposing (aboutText, configTemplateComment, containerTemplate, containerTemplateComment, futurePlansText, initTemplate, initTemplateComment, installNixTemplate, installNixTemplateComment, servicesTemplate, servicesTemplateComment, shareTemplate, shareTemplateComment, shareTemplateComment2, shellTemplate, shellTemplateComment)

import Html exposing (a, text)
import Html.Attributes exposing (href, target)


aboutText =
    """
In a world of horrendously complex software developed by myriads of authors,
be smart, use Nix and create isolated and reproducible geospatial environments,
lovely built to work on any modern Linux machine.
"""


futurePlansText =
    """
What you see here, is only very early start of something great. Many more
features like configuration options for languages and services, geospatial
specific modules and user experience improvements are on the way.
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
nix run github:imincik/geospatial-nix#geonixcli -- init
git add flake.nix geonix.nix
"""


configTemplateComment =
    """
Copy and paste configuration to geonix.nix file
"""


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
