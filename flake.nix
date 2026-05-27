{
  description = "Shared CI configuration";

  outputs = inputs:
    inputs.blueprint {
      inherit inputs;
      systems = ["x86_64-linux" "aarch64-linux"];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "";
    };
  };
}
