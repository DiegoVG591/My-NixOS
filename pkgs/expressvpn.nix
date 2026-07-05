{ autoPatchelfHook
, buildFHSEnv
, brotli
, fetchurl
, glib
, lib
, libcap_ng
, stdenv
, stdenvNoCC
, writeScript
, zlib
}:
let
  pname = "expressvpn";
  version = "14.2.0.13656";
  expressvpnBase = stdenvNoCC.mkDerivation {
    inherit pname version;
    src = fetchurl {
      url = "https://www.expressvpn.works/clients/linux/expressvpn-linux-universal-${version}_release.run";
      hash = "sha256-nXcO3GVIoXmU/RVxTFAwqPV2dnG3ayEXqIT31I2T8ss=";
    };
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ libcap_ng stdenv.cc.cc.lib brotli zlib glib ];
    autoPatchelfIgnoreMissingDeps = [ "*" ];
    dontConfigure = true;
    dontBuild = true;
    unpackPhase = ''
      runHook preUnpack
      sh $src --noexec --target ./evpn
      runHook postUnpack
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r evpn/x64/expressvpnfiles/* $out/
      substituteInPlace $out/bin/openvpn-updown.sh \
        --replace '/usr/bin/systemctl' 'systemctl' \
        --replace '/usr/bin/resolvectl' 'resolvectl'
      substituteInPlace $out/bin/openvpn-updown.sh \
        --replace \
        'export PATH="$arg_path"' \
        'export PATH="$arg_path:/run/current-system/sw/bin:/run/wrappers/bin"'
      substituteInPlace $out/bin/openvpn-updown.sh \
        --replace \
        'apply_nameservers() {' \
        'apply_nameservers() {
  systemd_apply
  return'
      sed -i 's|exec $(dirname $0)/expressvpn-openvpn-real|exec '"$out"'/bin/expressvpn-openvpn-real|g' $out/bin/expressvpn-openvpn
      patchelf --add-rpath $out/lib $out/plugins/tls/libqopensslbackend.so
      runHook postInstall
    '';
  };
  fhsTargetPkgs = pkgs: with pkgs; [
    expressvpnBase
    stdenv.cc.cc.lib
    libxkbcommon
    dbus.lib
    libGL
    zlib
    glib
    freetype
    fontconfig
    libcap_ng
    libatomic_ops
    wayland
    libsm
    libice
    libxau
    libxdmcp
    libdrm
    brotli
    iproute2
    iptables
    openssl
    systemd
  ];
  expressvpnDaemonFHS = buildFHSEnv {
    inherit version;
    pname = "expressvpn-daemon";
    runScript = "${expressvpnBase}/bin/expressvpn-daemon";
    targetPkgs = fhsTargetPkgs;
    extraBwrapArgs = [ "--bind" "/opt/expressvpn" "/opt/expressvpn" "--share-net" ];
  };
  expressvpnCtlFHS = buildFHSEnv {
    inherit version;
    pname = "expressvpnctl";
    runScript = "${expressvpnBase}/bin/expressvpnctl";
    targetPkgs = fhsTargetPkgs;
    extraBwrapArgs = [ "--bind" "/opt/expressvpn" "/opt/expressvpn" ];
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    ln -s ${expressvpnCtlFHS}/bin/expressvpnctl $out/bin/expressvpnctl
    ln -s ${expressvpnDaemonFHS}/bin/expressvpn-daemon $out/bin/expressvpn-daemon
    runHook postInstall
  '';
  meta = {
    description = "CLI client for ExpressVPN";
    homepage = "https://www.expressvpn.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
