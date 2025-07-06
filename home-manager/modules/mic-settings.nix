# In /home/krieg/mysystem/home-manager/modules/mic-settings.nix
{
  home.file.".config/wireplumber/main.lua.d/51-mic-volume.lua" = {
    text = ''
      rule = {
        matches = {
          {
            { "node.name", "equals", "alsa_input.usb-Generic_Blue_Microphones_2112BAB09868-00.analog-stereo" }
          }
        },
        apply_properties = {
          ["route.props"] = {
            ["channelVolumes"] = { 1.0, 1.0 }
          }
        }
      }
      table.insert(alsa_monitor.rules, rule)
    '';
  };
}
