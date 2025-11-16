#!/usr/bin/env bash

# Define the keyboard's MAC address
KEYBOARD_MAC="6C:93:08:66:C4:30" # Insert your keyboard Mac here

echo "Pairing and connecting to keyboard ($KEYBOARD_MAC)..."

# Pipe the full, correctly ordered sequence into bluetoothctl
(
    echo "scan on"
    sleep 15 # Wait for the device to be discovered
    
    # Finally, connect to activate the device
    echo "connect $KEYBOARD_MAC"
    sleep 5

    # Turn off scanning to save power
    echo "scan off"

) | bluetoothctl

echo "Script finished."
