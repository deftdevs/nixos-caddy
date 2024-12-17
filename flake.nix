{
  description = "Caddy with Hetzner DNS plugin and a Go dev shell";

  # The NixOS version must contain the required Go version as described in:
  # https://github.com/caddyserver/caddy?tab=readme-ov-file#build-from-source
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

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
          defaultPackage = self.packages.${system}.caddy;

          packages.caddy = pkgs.buildGoModule {
            pname = "caddy";
            inherit version;
            src = ./src/caddy;
            runVend = true;
            vendorHash = "sha256-B7bXvCLp3cIx+dNI0GQqY5QgP6uKisYdDp/G7zPrhuw=";
          };

          packages.caddy-dns-cloudflare = pkgs.buildGoModule {
            pname = "caddy";
            inherit version;
            src = ./src/caddy-dns-cloudflare;
            runVend = true;
            vendorHash = "sha256-dEuxEG6mW2V7iuSXvziR82bmF+Hwe6ePCfdNj5t3t4c=";
          };

          packages.caddy-dns-hetzner = pkgs.buildGoModule {
            pname = "caddy";
            inherit version;
            src = ./src/caddy-dns-hetzner;
            runVend = true;
            vendorHash = "sha256-GKMB7/jSKY9CHRGEd45xAdu4nX1aFOBoGZh7mfPOUOk=";
          };

          devShells.default = import ./shell.nix { inherit pkgs; };
        }
      );
}
