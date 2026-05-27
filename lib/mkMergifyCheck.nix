/*
  mkMergifyCheck — produce a flake check that diffs a repo's committed
  .mergify.yml against the output of mkMergifyConfig.

  If the files differ the check fails and prints the command to regenerate.

  Arguments:
    pkgs            – nixpkgs package set (required)
    mergifyPackage  – derivation produced by mkMergifyConfig (required)
    mergifyFile     – path to the committed .mergify.yml in the consuming repo (required)
    name            – derivation name for this check
    updateCmd       – command printed when the check fails
*/
{
  inputs,
  flake,
  ...
}:
{
  pkgs,
  mergifyPackage,
  mergifyFile,
  name ? "mergify-check",
  updateCmd ? "nix build .#mergify && cp result .mergify.yml",
}:
pkgs.runCommand name {} ''
  if ! ${pkgs.diffutils}/bin/diff -q ${mergifyPackage} ${mergifyFile}; then
    echo ".mergify.yml is out of date, run:"
    echo "  ${updateCmd}"
    exit 1
  fi
  touch $out
''
