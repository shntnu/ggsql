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
            # Force clang for wasm32 cross-compile. On macOS `cc` is clang by
            # default so locally this is a no-op; on Linux CI `cc` is gcc,
            # which lacks wasm builtins like __builtin_wasm_memory_size and
            # breaks cc-rs when tree-sitter builds stdlib.c for wasm.
            export CC_wasm32_unknown_unknown="${pkgs.clang}/bin/clang"
            export CXX_wasm32_unknown_unknown="${pkgs.clang}/bin/clang++"
          '';
        };
      });
}
