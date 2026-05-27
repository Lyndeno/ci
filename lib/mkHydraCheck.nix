/*
  mkHydraCheck — produce a flake check that diffs a repo's committed
  .hydra/spec.json against the output of mkHydraSpec.

  If the files differ the check fails and prints the command to regenerate.

  Arguments:
    pkgs        – nixpkgs package set (required)
    specPackage – derivation produced by mkHydraSpec (required)
    specFile    – path to the committed spec.json in the consuming repo (required)
    name        – derivation name for this check
    updateCmd   – command printed when the check fails
*/
{
  inputs,
  flake,
}:
{
  pkgs,
  specPackage,
  specFile,
  name ? "hydra-spec-check",
  updateCmd ? "nix build .#hydra-spec && cp result .hydra/spec.json",
}:
pkgs.runCommand name {} ''
  if ! ${pkgs.diffutils}/bin/diff -q ${specPackage} ${specFile}; then
    echo ".hydra/spec.json is out of date, run:"
    echo "  ${updateCmd}"
    exit 1
  fi
  touch $out
''
