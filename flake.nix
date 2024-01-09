{
  description = "Set of utils for scala development";

  outputs = { self }: {

    # templates for developing scala-apps
    templates = {
      scala-cli-app = {
        src = ./templates/scala-cli-app;
        description = "A scala app built with scala-cli";
      };
    };

    # utils for building scala apps
    lib = {
      mkBuildScalaApp = import ./lib/build-scala-app.nix;
      mkTypelevelShell = import ./lib/scala-typelevel-devshell.nix;
    };

    # add dev shells

  };
}
