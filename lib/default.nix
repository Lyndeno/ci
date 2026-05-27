{
  inputs,
  flake,
  ...
}: {
  mkHydraSpec = import ./mkHydraSpec.nix {inherit inputs flake;};
  mkHydraCheck = import ./mkHydraCheck.nix {inherit inputs flake;};
  mkMergifyConfig = import ./mkMergifyConfig.nix {inherit inputs flake;};
  mkMergifyCheck = import ./mkMergifyCheck.nix {inherit inputs flake;};
}
