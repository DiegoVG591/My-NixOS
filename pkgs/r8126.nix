{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  name = "r8126-${version}-${kernel.version}";
  version = "27721fb";

  src = fetchFromGitHub {
    owner = "openwrt";
    repo = "rtl8126";
    rev = "27721fbedc45897cf1f155f5eb44de76962a1ba8";
    hash = "sha256-0bivAMEcCRrefJjfN/wtMOSCGWbAsU5kfbJ/bpTi5+c=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

buildPhase = ''
  make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
    M=$(pwd) \
    modules
'';

installPhase = ''
  install -D r8126.ko \
    $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/ethernet/realtek/r8126.ko
'';

    meta = {
    description = "Realtek RTL8126 5GbE driver (OpenWrt upstream)";
    license = lib.licenses.gpl2Only;
  };
}
