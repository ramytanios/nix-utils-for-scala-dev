{
  description = "Hello world Scala app";
  inputs = {
    typelevel-nix.url = "github:typelevel/typelevel-nix";
    nixpkgs.follows = "typelevel-nix/nixpkgs";
    flake-utils.follows = "typelevel-nix/flake-utils";
    scala-dev.url = "github:ramytanios/nix-utils-for-scala-dev";
  };

  outputs = { self, nixpkgs, typelevel-nix, flake-utils, scala-dev, ... }:
    let
      version = if (self ? rev) then self.rev else "dirty";
      eachSystem = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    in {
      # devshells
      devShells = eachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ typelevel-nix.overlay ];
          };
        in {
          default = pkgs.devshell.mkShell {
            imports = [ typelevel-nix.typelevelShell ];
            name = "watch-shell";
            typelevelShell = {
              jdk.package = pkgs.jdk;
              nodejs.enable = false;
              native.enable = true;
              native.libraries = with pkgs; [ zlib s2n-tls openssl ];
            };
            packages = with pkgs; [ which ];
          };
        });

      # packages
      packages = eachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          buildScalaApp = scala-dev.lib.mkBuildScalaApp pkgs;
        in buildScalaApp {
          inherit version;
          pname = "app";
          src = ./src;
          supported-platforms = [ "jvm" ];
          sha256 = "";
        });

      checks = self.packages;
    };
}
