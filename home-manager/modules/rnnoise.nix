# In /home/krieg/mysystem/home-manager/modules/rnnoise.nix
{ pkgs, ... }:

{
  home.file.".config/pipewire/pipewire.conf.d/99-input-denoising.conf" = {
    text = ''
      context.modules = [
        {
          name = libpipewire-module-filter-chain
          args = {
            node.description = "Studio Mic (RNNoise + EQ)"
            media.name       = "Studio Mic (RNNoise + EQ)"
            node.target      = "alsa_input.usb-Generic_Blue_Microphones_2112BAB09868-00.analog-stereo"
            capture.props = {
              node.name   = "capture.studio_mic"
              audio.rate  = 48000
            }
            playback.props = {
              node.name   = "studio_mic"
              media.class = "Audio/Source"
            }
            filter.graph = {
              nodes = [
                {
                  type  = ladspa
                  name  = rnnoise
                  plugin = ${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so
                  label = noise_suppressor_mono
                  control = {
                    "VAD Threshold (%)" = 5.0
                  }
                }
                {
                  type = builtin
                  name = eq
                  label = eq_15band
                  control = {
                    # Boost the 'body' of your voice around 250Hz and 400Hz
                    # Format is: Band_Number = Gain_in_dB
                    "band3.gain" = 2.0  # 250Hz
                    "band4.gain" = 1.5  # 400Hz
                  }
                }
              ]
              links = [
                { output = "rnnoise:out_1" input = "eq:in_1" }
                { output = "eq:out_1" input = "capture.studio_mic:in_1" }
              ]
            }
          }
        }
      ]
    '';
  };

  home.packages = [
    pkgs.rnnoise-plugin
  ];
}
