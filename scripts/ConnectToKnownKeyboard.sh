#!/usr/bin/env bash
KEYBOARD_MAC="6C:93:08:66:C4:30"
echo "Pairing and connecting to keyboard ($KEYBOARD_MAC)..."
(
    echo "scan on"
    sleep 15
    echo "trust $KEYBOARD_MAC"
    echo "connect $KEYBOARD_MAC"
    sleep 5
    echo "scan off"
) | bluetoothctl
echo "Script finished."
