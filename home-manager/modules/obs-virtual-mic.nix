{ config, pkgs, ... }:

{
  # REMOVE the services.pipewire.enable = true; line. 
  # It doesn't exist in Home Manager and you already enabled it in your system config.

  xdg.configFile."pipewire/pipewire.conf.d/10-virtual-mic.conf" = {
    text = ''
      context.modules = [
        {
          name = libpipewire-module-loopback
          args = {
            node.name = "OBS-Virtual-Mic"
            capture.props = {
              node.description = "Virtual Mic (from OBS)"
              audio.position = [ FL FR ]
            }
            playback.props = {
              node.description = "Virtual Mic (to OBS)"
              audio.position = [ FL FR ]
            }
          }
        }
      ]
    '';
  };
}
