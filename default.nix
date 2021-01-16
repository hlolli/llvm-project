{ pkgs ? import <nixpkgs> { } }:

let
  lib = pkgs.lib;
  wasi-sdk = pkgs.callPackage ./wasi-sdk.nix { };

in pkgs.stdenvNoCC.mkDerivation rec {

  name = "clang-wasm";
  src = builtins.path {
    path = ./.;
    filter = path: type: !lib.strings.hasSuffix ".nix" path;
  };

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontStrip = true;
  PREFIX = "${placeholder "out"}";
  AR = "${wasi-sdk}/bin/ar";
  CC = "${wasi-sdk}/bin/clang";
  CPP = "${wasi-sdk}/bin/clang-cpp";
  CXX = "${wasi-sdk}/bin/clang++";
  LD = "${wasi-sdk}/bin/wasm-ld";
  NM = "${wasi-sdk}/bin/nm";
  OBJCOPY = "${wasi-sdk}/bin/objcopy";
  RANLIB = "${wasi-sdk}/bin/ranlib";


  buildInputs = with pkgs; [ cmake git perl ninja python3 ];

  buildPhase = ''
    # dont build benchmark util
    rm -rf llvm/utils/benchmark

    mkdir -p build/llvm
    cd build/llvm
    cmake -G Ninja \
      -DCMAKE_CROSSCOMPILING=True \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DLLVM_DEFAULT_TARGET_TRIPLE=wasm32-wasi \
      -DLLVM_TARGET_ARCH=wasm32 \
      -DLLVM_TARGETS_TO_BUILD=WebAssembly \
      -DLLVM_ENABLE_PROJECTS="clang" \
      -DLLVM_INCLUDE_BENCHMARKS=0 \
      -DLLVM_INCLUDE_TESTS=0 \
      -DLLVM_INCLUDE_EXAMPLES=0 \
      -DLLVM_INCLUDE_RUNTIMES=0 \
      -DLLVM_INCLUDE_TOOLS=0 \
      -DLLVM_INCLUDE_UTILS=0 \
      ../../llvm

    cd ../../
    ninja -v -C build/llvm
  '';
}
