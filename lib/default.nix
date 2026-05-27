{
  inputs,
  flake,
  ...
}: {
  mkHydraSpec = import ./mkHydraSpec.nix {inherit inputs flake;};
  mkHydraCheck = import ./mkHydraCheck.nix {inherit inputs flake;};
}
