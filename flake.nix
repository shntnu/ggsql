{
  description = "ggsql dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            rustc
            cargo
            rustfmt
            clippy
            rust-analyzer
            pkg-config
            cmake
            clang
            tree-sitter
            nodejs
            wasm-pack
            binaryen
            llvm
            lld
          ];

          # nix cc-wrapper injects hardening flags (e.g. -fzero-call-used-regs)
          # that clang rejects when cross-compiling to wasm32-unknown-unknown.
          hardeningDisable = [ "all" ];

          shellHook = ''
            export LIBCLANG_PATH="${pkgs.libclang.lib}/lib"
          '';
        };
      });
}
