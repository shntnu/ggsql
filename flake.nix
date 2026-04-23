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
            # Use unwrapped clang for wasm32 cross-compile. The nix cc-wrapper
            # injects host glibc into the include path, which breaks when
            # targetting wasm32 (clang finds gnu/stubs.h then fails on missing
            # gnu/stubs-32.h). The unwrapped binary has no such injection.
            # cargo itself also warns: "supplying --target wasm32-unknown-unknown
            # != x86_64-unknown-linux-gnu argument to a nix-wrapped compiler may
            # not work correctly - cc-wrapper is currently not designed with
            # multi-target compilers in mind."
            export CC_wasm32_unknown_unknown="${pkgs.llvmPackages.clang-unwrapped}/bin/clang"
            export CXX_wasm32_unknown_unknown="${pkgs.llvmPackages.clang-unwrapped}/bin/clang++"
            export AR_wasm32_unknown_unknown="${pkgs.llvmPackages.llvm}/bin/llvm-ar"
          '';
        };
      });
}
