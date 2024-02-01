module Texts exposing (aboutText, configTemplateComment, containerTemplate, containerTemplateComment, futurePlansText, initTemplate, initTemplateComment, installNixTemplate, installNixTemplateComment, servicesTemplate, servicesTemplateComment, shellTemplate, shellTemplateComment)


aboutText =
    """
In a world of horrendously complex software developed by myriads of authors,
be smart, use Nix and create isolated and reproducible geospatial environment,
lovely built to work on any modern Linux machine.
"""


futurePlansText =
    """
What you see here, is only very early start of something great. Many more
features like configuration options for languages and services, geospatial
specific modules and user experience improvements are on the way.
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
