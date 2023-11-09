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
      LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";
      CARGO_NET_GIT_FETCH_WITH_CLI = "true";
    in rec {
      packages = {
        dc-times = naerskLib.buildPackage {
          name = "dc-times";
          src = ./.;
          inherit buildInputs LD_LIBRARY_PATH CARGO_NET_GIT_FETCH_WITH_CLI;
          nativeBuildInputs = nativeBuildInputs;
        };
        default = packages.dc-times;
      };
      devShells.default = pkgs.mkShell {
        inherit buildInputs LD_LIBRARY_PATH CARGO_NET_GIT_FETCH_WITH_CLI;
        nativeBuildInputs = nativeBuildInputs ++ [ rust-toolchain pkgs.rust-analyzer ];
        RUST_BACKTRACE = 1;
      };
    }
  );
}