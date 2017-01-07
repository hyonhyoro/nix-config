{ stdenv, fetchurl, pkgconfig, openssl, perl, systemd }:

stdenv.mkDerivation rec {
  name = "yaskkserv-${version}";
  version = "1.1.0";

  src = fetchurl {
    url = "http://umiushi.org/~wac/yaskkserv/${name}.tar.gz";
    sha256 = "46e39dbe46a0eaafc477eed4ec8a2b98f47877d61b240ed0a185f86b8bc376f7";
  };

  buildInputs = [ pkgconfig openssl perl systemd ];

  preConfigure = ''
    substituteInPlace configure \
      --replace /usr/bin/perl ${perl}/bin/perl
  '';

  configureFlags = [
    "--compiler=g++"
    "--enable-google-japanese-input"
    "--disable-google-suggest"
    "--enable-syslog"
    "--enable-error-message"
    "--enable-https"
    "--disable-gnutls"
    "--enable-openssl"
    "--enable-systemd"
    "--precompile"
  ];

  installPhase = ''
    make install_hairy
  '';

  meta = with stdenv.lib; {
    description = "Yet Another SKK server";
    homepage = http://umiushi.org/~wac/yaskkserv/;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
