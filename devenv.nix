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

  packages = with pkgs; [ helm just ];

  scripts = {
    lint.exec = "helm lint charts/*";
    test.exec = "helm unittest charts/*";
    check.exec = "helm lint charts/* && helm unittest charts/*";
    template.exec = "helm template $1 charts/$1";
    package.exec = "helm package charts/$1";
  };

  tasks = {
    "charts:lint".exec = "helm lint charts/*";
    "charts:test".exec = "helm unittest charts/*";
    "charts:check".exec = "helm lint charts/* && helm unittest charts/*";
  };
}
