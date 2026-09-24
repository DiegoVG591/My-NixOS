{ inputs, config, lib, pkgs, ... }:
{
    hardware.nvidia.prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
    };
}
