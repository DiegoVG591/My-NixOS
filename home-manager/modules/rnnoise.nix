# In /home/krieg/mysystem/home-manager/modules/rnnoise.nix
{ pkgs, ... }:

{
  home.file.".config/pipewire/pipewire.conf.d/99-input-denoising.conf" = {
    text = ''
      context.modules = [
        {
          name = libpipewire-module-filter-chain
          args = {
            node.description = "Denoised Blue Yeti"
            media.name       = "Denoised Blue Yeti"
            node.target      = "alsa_input.usb-Generic_Blue_Microphones_2112BAB09868-00.analog-stereo"
            capture.props = {
              node.name   = "capture.denoised_yeti"
              audio.rate  = 48000
            }
            playback.props = {
              node.name   = "denoised_yeti"
              media.class = "Audio/Source"
            }
            filter.graph = {
              nodes = [
                # --- THIS SECTION HAS BEEN CORRECTED ---
                {
                  type    = "spa-node"
                  name    = "denoiser"
                  factory = "audioconvert"
                  control = {
                    "noise.suppress_ms" = 10
                  }
                }
              ]
            }
          }
        }
      ]
    '';
  };
}
