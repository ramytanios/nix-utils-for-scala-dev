{
  description = "Hello world Scala app";
  inputs = {
    typelevel-nix.url = "github:typelevel/typelevel-nix";
    nixpkgs.follows = "typelevel-nix/nixpkgs";
    flake-utils.follows = "typelevel-nix/flake-utils";
    my-utils.url = "github:ramytanios/nix-utils-scala-dev";
  };

  outputs = { self, nixpkgs, typelevel-nix, flake-utils, my-utils }:
    let
      inherit (flake-utils.lib) eachDefaultSystem;
      version = if (self ? rev) then self.rev else "dirty";

    in {
      # devshells
      devShells = eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ typelevel-nix.overlay ];
          };
        in {
          # dev shell
          default = pkgs.devshell.mkShell {
            imports = [ typelevel-nix.typelevelShell ];
            name = "app-dev-shell";
            typelevelShell = {
              jdk.package = pkgs.jdk;
              nodejs.enable = true;
              native.enable = true;
              native.libraries = with pkgs; [ zlib s2n-tls openssl ];
            };
            packages = with pkgs; [ which ];
          };

        });

      # packages
      packages = eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ ];
          };
          buildScalaApp = my-utils.lib.mkBuildScalaApp { inherit pkgs; };
        in buildScalaApp {
          pname = "app";
          inherit version;
          src = ./src;
          supported-platforms = [ "jvm" ];
        });
    };
}
