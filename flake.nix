{
  description = "Set of utils for scala development";

  outputs = _: {

    # templates for developing scala-apps
    templates = {
      scala-cli-app = {
        src = ./templates/scala-cli-app;
        description = "A scala app built with scala-cli";
      };
    };
  };

}
