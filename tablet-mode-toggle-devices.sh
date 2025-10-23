#!/bin/bash

# List of devices to enable or disable
KEYBOARD_NAME="AT Translated Set 2 keyboard"
TOUCHPAD_NAME="Atmel maXTouch Touchpad"
DEVICES=("$KEYBOARD_NAME" "$TOUCHPAD_NAME")

# Last known state, required to only run the script once if the state changes, and not for each event reporting a switch to or from Tablet mode
last_state=""

# Function to get the event device path (e.g. /sys/class/input/eventX/device)
get_device_path() {
  # Get device id from libinput list-devices by name
  local device_info=$(libinput list-devices | grep -A10 "$DEVICE" | grep "Kernel:")

  # Extract event device, e.g. event2
  local event_device=$(echo "$device_info" | sed -E 's/.*event([0-9]+).*/event\1/')

  # Find and return the sysfs path
  echo "/sys/class/input/$event_device/device"
}

# Function to set the inhibited file for the devices to on or off
toggle_devices() {
  local state=$1
  
  for DEVICE in "${DEVICES[@]}"; do
    # Get the directory for the device
    local dev_path=$(get_device_path $DEVICE)
    
    # Check if directory exists and is valid
    if [ -z "$dev_path" ] || [ ! -d "$dev_path" ]; then
      echo "Could not find keyboard device path!"
      exit 1
    fi
  
    # Check if the device needs to be disabled or enabled
    if [ "$state" = "1" ]; then
      echo "Disabling $DEVICE"
      # DISABLE device by writing 1 to the inhibited file of the device
      echo "$state" | tee "$dev_path/inhibited" > /dev/null
      
   elif [ "$state" = "0" ]; then
      echo "Enabling $DEVICE"
      # ENABLE device by writing 0 to the inhibited file of the device
      echo "$state" | tee "$dev_path/inhibited" > /dev/null
    fi
  
  done
}

# Start with line buffering to check if Tablet mode is enabled or disabled
# -oL ensures that the standard output will be flushed after each newline, instead of waiting for large bufferd chunks
stdbuf -oL libinput debug-events | grep --line-buffered "SWITCH_TOGGLE" | while read -r line; do
  # When Tablet Mode is activated, disable the devices
  if echo "$line" | grep -q "state 1"; then
    if [ "$last_state" != "enabled" ]; then
      echo "Tablet mode Enabled"
      toggle_devices 1 # Disable device by writing a 1 to the inhibited file for the device
      last_state="enabled"
      fi
  # Else, if Tablet Mode is deactivated, enable the devices
  elif echo "$line" | grep -q "state 0"; then
    if [ "$last_state" != "disabled" ]; then
      echo "Tablet mode Disabled"
      toggle_devices 0 # Enable device by writing a 0 to the inhibited file for the device
      last_state="disabled"
      fi
  fi
done
