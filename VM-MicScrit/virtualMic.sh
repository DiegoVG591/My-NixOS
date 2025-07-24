#!/usr/bin/env bash

# Create a virtual sink named "VirtualSpeaker" to be used as a monitor in OBS
pactl load-module module-null-sink sink_name="VirtualSpeaker" sink_properties=device.description=VirtualSpeaker

# Create a virtual source named "VirtualMic" that will be visible in apps like Discord
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name="VirtualMic" sink_properties=device.description=VirtualMic

# Give PipeWire a moment to register the new devices before linking them
sleep 1

# Link the output of the speaker to the input of the microphone
pw-link VirtualSpeaker:monitor_FL VirtualMic:input_FL
pw-link VirtualSpeaker:monitor_FR VirtualMic:input_FR

echo "Virtual audio cable created successfully."
