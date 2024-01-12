This flake builds your Scala app in 2 different ways:

```shell
# as a regular JVM app
nix run .#jvm

# as a GraalVM native image
nix run .#graal
```

Whether or not a given platform is supported depends on
how your app is written and what dependencies it has.
You can easily remove unsupported platforms from the flake:
see `supported-platforms` in `flake.nix`.
