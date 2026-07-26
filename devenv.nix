{
  pkgs,
  inputs,
  ...
}:
let
  helm = pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [ pkgs.kubernetes-helmPlugins.helm-unittest ];
  };
in
{
  imports = [ inputs.flakes.devenvModules.default ];

  name = "vardis/charts";

  packages = with pkgs; [
    helm
    just
  ];

  languages.python = {
    enable = true;
    version = "3.14";
    uv.enable = true;
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
    yamllint = {
      enable = true;
      excludes = [ "templates" ];
    };
    helm-lint = {
      enable = true;
      name = "helm lint";
      entry = toString (pkgs.writeShellScript "helm-lint-on-change" ''
        set -e
        for chart in $(printf '%s\n' "$@" | cut -d/ -f1-2 | sort -u); do
          ${helm}/bin/helm lint "$chart"
        done
      '');
      files = "^charts/";
      language = "system";
      pass_filenames = true;
    };
    helm-unittest = {
      enable = true;
      name = "helm unittest";
      entry = toString (pkgs.writeShellScript "helm-unittest-on-change" ''
        set -e
        for chart in $(printf '%s\n' "$@" | cut -d/ -f1-2 | sort -u); do
          ${helm}/bin/helm unittest "$chart"
        done
      '');
      files = "^charts/";
      language = "system";
      pass_filenames = true;
    };
  };
}
