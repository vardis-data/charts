{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.flakes.devenvModules.default ];

  name = "vardis/charts";

  packages = with pkgs; [
    helm
    just
  ];

  languages = {
    helm = {
      enable = true;
      plugins = [ "helm-unittest" ];
    };
    python = {
      enable = true;
      version = "3.14";
      uv.enable = true;
    };
  };

  scripts = {
    template.exec = "helm template $1 charts/$1";
    package.exec = "helm package charts/$1";
  };

  tasks = {
    "charts:lint".exec = "helm lint charts/*";
    "charts:test".exec = "helm unittest charts/*";
    "charts:check".exec = "helm lint charts/* && helm unittest charts/*";
  };

  git-hooks.hooks = {
    shellcheck.enable = true;
    shfmt.enable = true;
    yamlfmt.enable = true;
    yamllint.enable = true;
    helm-lint = {
      enable = true;
      name = "helm lint";
      entry = "helm lint charts/*";
      files = "^charts/";
      language = "system";
      pass_filenames = false;
    };
    helm-unittest = {
      enable = true;
      name = "helm unittest";
      entry = "helm unittest charts/*";
      files = "^charts/";
      language = "system";
      pass_filenames = false;
    };
  };
}
