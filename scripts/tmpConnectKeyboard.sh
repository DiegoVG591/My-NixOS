#!/usr/bin/env bash

# Define the keyboard's MAC address
KEYBOARD_MAC="" # Insert your keyboard Mac here

echo "Pairing and connecting to keyboard ($KEYBOARD_MAC)..."

# Pipe the full, correctly ordered sequence into bluetoothctl
(
    echo "scan on"
    sleep 15 # Wait for the device to be discovered
    
    # 1. Pair first to establish a secure connection
    echo "pair $KEYBOARD_MAC"
    sleep 5 # Give it time to complete the pairing process
    
    # 2. Trust the device to authorize its services
    echo "trust $KEYBOARD_MAC"
    sleep 2

    # 3. Finally, connect to activate the device
    echo "connect $KEYBOARD_MAC"
    sleep 5

    # 4. Turn off scanning to save power
    echo "scan off"

) | bluetoothctl

echo "Script finished."
