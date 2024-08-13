{
  description = "Caddy with Hetzner DNS plugin and a Go dev shell";

  # The NixOS version must contain the required Go version as described in:
  # https://github.com/caddyserver/caddy?tab=readme-ov-file#build-from-source
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    systems.url = github:nix-systems/default;

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs = {
        systems.follows = "systems";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;
    in

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages.caddy = pkgs.buildGoModule {
            pname = "caddy";
            inherit version;
            src = ./caddy-src;
            runVend = true;
            vendorHash = "sha256-XYfO/fAZzBJQPP4qa9vOMonQMVNb4ZeHxiyjKhpKvRE=";
          };

          defaultPackage = self.packages.${system}.caddy;

          devShells.default = import ./shell.nix { inherit pkgs; };
        }
      );
}
