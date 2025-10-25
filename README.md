# 2 in 1 Laptops on Linux | Tablet Mode Toggle Keyboard and Trackpad ON or OFF
Bash script for 2 in 1 laptops to automatically disable the keyboard when turning on tablet mode. Specifically for Linux devices running GNOME on Wayland which can't use xinput.

## Setup
Edit the .sh file to the name of the devices you want to switch off. To find the device name you can use `libinput list-devices`. Place the file in desired folder.

## Setting up to run as Service
Edit the .service file to point to the tablet-mode-toggle-devices.sh script, and place in /etc/systemd/system/.

Reload to recognize the new service file:
`sudo systemctl daemon-reload`

Enable the service to start automatically on boot
`sudo systemctl enable tablet-mode-toggle.service`

Start the service immideatly
`sudo systemctl start tablet-mode-toggle.service`

Check if the service is running
`sudo systemctl status tablet-mode-toggle.service`
