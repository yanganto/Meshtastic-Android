{
  description = "Meshtastic Android KMP development shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05-small";
    flake-parts.url = "github:hercules-ci/flake-parts";
    parachutes.url = "github:yanganto/parachutes";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./nix/devshells.nix
      ];

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args = {
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.parachutes.overlays.myMkShell ];
              config.android_sdk.accept_license = true;
              config.allowUnfree = true;
            };
          };
        };
    };
}
