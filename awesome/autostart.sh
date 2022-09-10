#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

# run dex $HOME/.config/autostart/arcolinux-welcome-app.desktop
#run xrandr --output VGA-1 --primary --mode 1360x768 --pos 0x0 --rotate normal
#run xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off
#autorandr horizontal

run xfce4-clipman
# run klipper
run nm-applet
run caffeine
# run bauh-tray
# run variety
# run xfce4-power-manager
# run blueberry-tray
run nitrogen --restore
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
# run /usr/lib/polkit-kde-authentication-agent-1
# run /usr/libexec/kf5/polkit-kde-authentication-agent-1
#run /usr/lib/polkit-1/polkit-agent-helper-1
run numlockx on
run volumeicon
# run xfce4-clipman
run "setxkbmap -option caps:swapescape"

# run "killall -9 redshift-gtk"
# run "killall -9 redshift"
# run "redshift-gtk -l 27.2046:77.4977"
# run conky -c $HOME/.config/awesome/system-overview
#you can set wallpapers in themes as well
# feh --bg-fill /usr/share/backgrounds/arcolinux/arco-wallpaper.jpg &
#run applications from startup
#run firefox
#run atom
#run dropbox
#run insync start
#run spotify
#run "picom --experimental-backend"
#run ckb-next -b
#run discord
#run telegram-desktop
#run "feh --bg-fill ~/Pictures/walltext.jpg"
