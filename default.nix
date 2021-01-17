{ pkgs ? import <nixpkgs> { } }:

let
  lib = pkgs.lib;
  wasi-sdk = pkgs.callPackage ./wasi-sdk.nix { };

in pkgs.stdenvNoCC.mkDerivation rec {

  name = "clang-wasm";
  src = pkgs.fetchFromGitHub {
      owner = "hlolli";
      repo = "llvm-project";
      rev = "1d5e6020341c2bf978c3534e592fa5e50519d2b0";
      sha256 = "0l3pmwvdgqpnsf71iqrskkl2l6zw82i8ragjql1y3ycw35q0a295";
  };

  # src = builtins.path {
  #   path = ./.;
  #   filter = path: type: !lib.strings.hasSuffix ".nix" path;
  # };

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
  EXTRA_FLAGS = "-D__wasi__=1 -D__wasm32__=1 -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_MMAN  -fno-exceptions -mno-atomics";

  buildInputs = with pkgs; [ cmake git perl ninja python3 ];

  patchPhase = ''
    # find ./ -type f -exec sed -i -e 's/#include <setjmp.h>//g' {} \;
    # substituteInPlace llvm/CMakeLists.txt \
    #   --replace 'add_subdirectory(lib/Support)' "" \
    #   --replace 'add_subdirectory(lib/TableGen)' "" \
    #   --replace 'add_subdirectory(utils/TableGen)' ""

    substituteInPlace llvm/lib/Support/CMakeLists.txt \
      --replace CodeGenCoverage.cpp "" \
      --replace BuryPointer.cpp "" \
      --replace Debug.cpp "" \
      --replace DebugCounter.cpp "" \
      --replace Error.cpp "" \
      --replace ErrorHandling.cpp "" \
      --replace BinaryStreamError.cpp ""

    substituteInPlace llvm/cmake/modules/LLVMProcessSources.cmake \
      --replace 'SEND_ERROR "Found unknown source' \
                'WARNING "Found unknown source'
  '';

  buildPhase = ''
    # dont build benchmark util
    rm -rf llvm/utils/benchmark

    mkdir -p build/llvm
    cd build/llvm
    cmake -G Ninja \
      -DCMAKE_CROSSCOMPILING=True \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DLLVM_DEFAULT_TARGET_TRIPLE=wasm32-unknown-emscripten \
      -DLLVM_TARGET_ARCH=wasm32 \
      -DLLVM_TARGETS_TO_BUILD=WebAssembly \
      -DLLVM_ENABLE_PROJECTS="clang" \
      -DLLVM_INCLUDE_BENCHMARKS=0 \
      -DLLVM_INCLUDE_TESTS=0 \
      -DLLVM_INCLUDE_EXAMPLES=0 \
      -DLLVM_INCLUDE_RUNTIMES=0 \
      -DLLVM_INCLUDE_TOOLS=0 \
      -DLLVM_INCLUDE_UTILS=0 \
      -DCMAKE_C_FLAGS="${EXTRA_FLAGS}" \
      -DCMAKE_CXX_FLAGS="${EXTRA_FLAGS}" \
      ../../llvm

    cd ../../
    ninja -v -C build/llvm
  '';
}
