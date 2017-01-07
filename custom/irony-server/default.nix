{ stdenv, fetchFromGitHub, cmake, llvmPackages, emacs }:

stdenv.mkDerivation rec {
  name = "irony-server-${version}";
  version = "0.2.2-cvs";

  src = fetchFromGitHub {
    owner = "Sarcasm";
    repo = "irony-mode";
    rev = "bfe703a4c0e91a960c606bf2420b1f118e53a0a6";
    sha256 = "idy0as8n5syf4cbpdpw7fpd205jzkj0k7av1c73nxvd4zd28pxj2";
  };

  buildInputs = [ cmake llvmPackages.llvm llvmPackages.clang emacs ];

  preConfigure = ''
    cd server
  '';

  cmakeFlags = [
    "-DLIBCLANG_LIBRARY=${llvmPackages.clang.cc}/lib/libclang.so"
    "-DLIBCLANG_INCLUDE_DIR=${llvmPackages.clang.cc}/include"
  ];

  meta = with stdenv.lib; {
    description = "A C/C++ minor mode for Emacs powered by libclang";
    homepage = https://github.com/Sarcasm/irony-mode;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
