# In /home/krieg/mysystem/home-manager/modules/obs-virtual-mic.nix

{ config, pkgs, ... }:

{
  # Ensure the user's PipeWire service is active
  services.pipewire.enable = true;

  # This block creates the configuration file for our virtual mic
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
