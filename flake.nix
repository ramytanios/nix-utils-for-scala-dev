{
  description = "Set of utils for scala development";

  outputs = { self }: {

    # Templates for developing scala-apps
    templates = {
      scala-cli-app = {
        src = ./templates/scala-cli-app;
        description = "A scala app built with scala-cli";
      };
    };

    # Packages for scala dev
    packages = { };

    # Apps for scala dev
    apps = { };
  };
}
