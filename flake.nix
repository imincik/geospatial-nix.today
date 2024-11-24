{
  description = "Geospatial NIX";

  nixConfig = {
    extra-substituters = [
      "https://geonix-rolling.cachix.org"
    ];
    extra-trusted-public-keys = [
      "geonix-rolling.cachix.org-1:27FqadR8Jqcwl+OY7+JvhRJoWixjMwX8xrwc6kIBnDo="
    ];
    bash-prompt = "\\[\\033[1m\\][geonix]\\[\\033\[m\\]\\040\\w >\\040";
  };

  inputs = {
    geonix.url = "github:imincik/geospatial-nix.repo/latest";
    geoenv = {
      url = "github:imincik/geospatial-nix.env/latest";
      inputs.nixpkgs.follows = "geonix/nixpkgs";
    };
    nixpkgs.follows = "geonix/nixpkgs";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "geonix/nixpkgs";
    };
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        inputs.geoenv.flakeModule
      ];

      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.geonix.overlays.geonix self.overlays.custom ];
          config.allowUnfree = true;
        };

        devenv.shells.default = {
          imports = [
            ./geonix.nix
          ];
        };

        packages.geonixcli = inputs.geoenv.packages.${system}.geonixcli;
      };

      flake = {
        overlays = import ./overlays.nix;
      };
    };
}
