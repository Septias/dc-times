{
  description = "Extract times from toggle";
  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.follows = "rust-overlay/flake-utils";
    nixpkgs.follows = "rust-overlay/nixpkgs";
    naersk.url = "github:nix-community/naersk";
  };
  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { overlays = [ (import rust-overlay) ]; inherit system; };
      naerskLib = pkgs.callPackage naersk {
        cargo = rust-toolchain;
        rustc = rust-toolchain;
      };
      buildInputs = with pkgs; [
        openssl
      ];
      nativeBuildInputs = with pkgs; [ pkg-config ];
      rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rustfmt" "rust-docs" "clippy"];
      };
      name = "dc-times";
    in rec {
      packages = {
        ${name} = naerskLib.buildPackage {
          inherit name;
          src = ./.;
          inherit buildInputs;
          nativeBuildInputs = nativeBuildInputs;
        };
        default = packages.${name};
      };
      devShells.default = pkgs.mkShell {
        inherit buildInputs;
        nativeBuildInputs = nativeBuildInputs ++ [ rust-toolchain pkgs.rust-analyzer ];
        RUST_BACKTRACE = 1;
      };
    }
  );
}
