{ nixpkgs, flake-utils, typelevel-nix }:
{ shell-name, enable-node ? false, enable-native ? false
, additional-packages ? [ ] }:
let
  inherit (nixpkgs.lib) genAttrs;
  eachSystem = genAttrs flake-utils.lib.defaultSystems;
in {
  devShells = eachSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ typelevel-nix.overlay ];
      };
    in {
      default = pkgs.devshell.mkShell {
        imports = [ typelevel-nix.typelevelShell ];
        name = shell-name;
        typelevelShell = {
          jdk.package = pkgs.jdk;
          nodejs.enable = false;
          native.enable = true;
          native.libraries = with pkgs; [ zlib s2n-tls openssl ];
        };
        packages = with pkgs; [ which ] ++ additional-packages;
      };
    });
}
