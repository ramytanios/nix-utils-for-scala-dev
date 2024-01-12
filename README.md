# nix-utils-for-scala-dev

Based on:
1. [flake-templates](https://github.com/buntec/flake-templates)
2. [nix-utils](https://github.com/buntec/nix-utils)
3. [pkgs](https://github.com/buntec/pkgs)

A collection of nix flake templates:

To show a list of available templates:
```shell
nix flake show github:ramytanios/nix-utils-for-scala-dev --refresh
```

To create a new project from a template:
```shell
nix flake new -t github:ramytanios/nix-utils-for-scala-dev#scala-cli-app ./my-new-project --refresh
```

# Notes
It is recommended to add `--refresh` to the commands above to ensure you always get the latest version.
 nix-utils-for-scala-dev
Set of utils (pkgs, templates) specific for Scala development
