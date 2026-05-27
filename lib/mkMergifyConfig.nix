/*
  mkMergifyConfig — generate a Mergify YAML configuration that automatically
  merges dependabot PRs once all Hydra CI checks pass.

  A check condition is emitted for every entry in `checks` using the pattern:
    check-success*=ci/hydra:<projectName>:*:<system>.<checkName>

  Arguments:
    pkgs        – nixpkgs package set (required)
    projectName – Hydra project name, used in the check condition strings (required)
    checks      – flake.checks attrset ({ system -> { name -> drv } }) (required)
    name        – derivation name for the generated file
*/
{
  inputs,
  flake,
  ...
}:
{
  pkgs,
  projectName,
  checks,
  name ? "mergify",
}: let
  inherit (pkgs) lib;

  checkConditions = lib.concatLists (
    lib.mapAttrsToList (
      system: systemChecks:
        lib.mapAttrsToList (
          checkName: _: "check-success*=ci/hydra:${projectName}:*:${system}.${checkName}"
        )
        systemChecks
    )
    checks
  );

  mergifyConfig = {
    pull_request_rules = [
      {
        name = "Automatically merge dependabot updates";
        conditions =
          [
            "author=dependabot[bot]"
          ]
          ++ checkConditions;
        actions.merge.method = "merge";
      }
    ];
  };
in
  (pkgs.formats.yaml {}).generate name mergifyConfig
