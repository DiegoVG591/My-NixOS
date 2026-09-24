{ config, pkgs, ... }:
{
  xdg.configFile."pipewire/pipewire.conf.d/10-virtual-mic.conf" = {
    text = ''
      context.objects = [
        {
          factory = adapter
          args = {
            factory.name     = support.null-audio-sink
            node.name        = "VirtualMicSink"
            node.description = "Virtual Mic Sink"
            media.class      = "Audio/Sink"
            audio.position   = [ FL FR ]
            monitor.channel-volumes = true
            monitor.passthrough = true
          }
        }
        {
          factory = adapter
          args = {
            factory.name     = support.null-audio-sink
            node.name        = "VirtualMic"
            node.description = "Virtual Microphone"
            media.class      = "Audio/Duplex"
            audio.position   = [ FL FR ]
          }
        }
        {
        factory = adapter
          args = {
            factory.name     = support.null-audio-sink
            node.name        = "SoundboardSink"
            node.description = "Soundboard"
            media.class      = "Audio/Sink"
            audio.position   = [ FL FR ]
            monitor.channel-volumes = true
            monitor.passthrough = true
          }
        }
      ]
    '';
  };
}
