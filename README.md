# nix-utils-for-scala-dev

*Work in progress -- still flaky* ❗

A collection of nix flake templates:

To show a list of available templates:
```shell
nix flake show github:ramytanios/nix-utils-for-scala-dev --refresh
```

To create a new project from a template:
```shell
nix flake new -t github:ramytanios/nix-utils-for-scala-dev#scala-cli-app ./my-new-project --refresh
```
