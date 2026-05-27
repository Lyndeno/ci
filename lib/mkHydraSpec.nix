/*
  mkHydraSpec — generate a Hydra declarative project spec (the content of
  .hydra/spec.json) for a GitHub-hosted flake repository.

  By default the nixexpr input points at github:Lyndeno/ci so that Hydra
  fetches hydra/jobsets.nix from this CI flake.  Override nixexprOwner /
  nixexprRepo / nixexprBranch / nixexprPath when you want to point at a
  different evaluator.

  Arguments:
    pkgs            – nixpkgs package set (required)
    owner           – GitHub owner of the target repo (required)
    repo            – GitHub repository name (required)
    name            – derivation name for the generated file
    nixpkgsValue    – git input value for nixpkgs passed to jobsets.nix
    nixexprOwner    – owner of the repo containing jobsets.nix
    nixexprRepo     – repo containing jobsets.nix
    nixexprBranch   – branch to track for the nixexpr input
    nixexprPath     – path to jobsets.nix inside nixexprRepo
    checkinterval   – seconds between Hydra evaluation runs
    schedulingshares – relative scheduling weight for this jobset
*/
{
  inputs,
  flake,
}:
{
  pkgs,
  owner,
  repo,
  name ? "hydra-spec",
  nixpkgsValue ? "https://github.com/NixOS/nixpkgs nixos-unstable",
  nixexprOwner ? "Lyndeno",
  nixexprRepo ? "ci",
  nixexprBranch ? "master",
  nixexprPath ? "hydra/jobsets.nix",
  checkinterval ? 300,
  schedulingshares ? 100,
}: let
  spec = {
    inherit checkinterval schedulingshares;
    description = "Jobset evaluation for ${owner}/${repo}";
    emailoverride = "";
    enableemail = false;
    enabled = 1;
    hidden = false;
    inputs = {
      nixexpr = {
        emailresponsible = false;
        type = "git";
        value = "https://github.com/${nixexprOwner}/${nixexprRepo} ${nixexprBranch}";
      };
      nixpkgs = {
        emailresponsible = false;
        type = "git";
        value = nixpkgsValue;
      };
      owner = {
        emailresponsible = false;
        type = "string";
        value = owner;
      };
      pulls = {
        emailresponsible = false;
        type = "githubpulls";
        value = "${owner} ${repo}";
      };
      refs = {
        emailresponsible = false;
        type = "github_refs";
        value = "${owner} ${repo} heads";
      };
      repo = {
        emailresponsible = false;
        type = "string";
        value = repo;
      };
    };
    keepnr = 1;
    nixexprinput = "nixexpr";
    nixexprpath = nixexprPath;
    type = 0;
  };
in
  pkgs.runCommand name {} ''
    ${pkgs.jq}/bin/jq --sort-keys . \
      ${pkgs.writeText "spec-raw.json" (builtins.toJSON spec)} > $out
  ''
