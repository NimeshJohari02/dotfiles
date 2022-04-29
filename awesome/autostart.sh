#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}
#run "dex $HOME/.config/autostart/arcolinux-welcome-app.desktop"
#run "xrandr --output VGA-1 --primary --mode 1360x768 --pos 0x0 --rotate normal"
#run "xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off"
run "nm-applet"
run "caffeine"
run "blueman-applet"
#run "cd rtl8812au && sudo ./installAndActivate.sh "
run "xfce4-clipman"
#run "blueberry-tray"
run "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
run "numlockx "
run "volumeicon"
run "setxkbmap -option caps:swapescape"
run "nitrogen --restore"
#run "conky -c $HOME/.config/awesome/system-overview"
#run "picom --experimental-backend"
#run "/usr/bin/emacs --daemon "
run "xinput --set-prop 12 'libinput Accel Speed' 1.0 "
