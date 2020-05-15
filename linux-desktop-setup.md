# Handy stuff for Linux on the desktop
I could not think of where to put these notes, so they can live here for now.

## Gnome: Classic move/resize behaviour using mouse buttons and keyboard modifier
Move with left mouse button, resize with right
https://unix.stackexchange.com/questions/28514/how-to-get-altright-mouse-to-resize-windows-again

Enable right button resize:
```
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
```

By default, gnome uses Super (Windows key), but that can be changed.
I have tried using control, which works better with the mouse on the left, but then ctrl-click stops working in web browsers.
Slightly better seems to be to remap the Windows menu key to be another Windows key (Super) and leave the setting on default.

Tweaks -> Keyboard & Mouse -> Additional Layout Options -> Alt/Win key behaviour -> Menu is mapped to Win

```
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier '<Alt>'
```

## Keyboard shortcuts in Gnome not working other than in default keyboard layout, in Wayland
This may have been fixed now.
```
ibus exit
```

## Other keyboard settings
Use gnome-tweak-tool
Under Additional Layout Options, you can disable caps lock
This also contains lots of other keyboard options


## Stuff to install
```
sudo apt-get install gnome-tweak-tool
sudo apt-get install git
sudo apt-get install net-tools
sudo apt-get install iperf3
sudo apt-get install passwordsafe
sudo apt-get install vim
sudo apt-get install mlocate
sudo apt-get install xev
sudo apt-get install x11-utils
sudo apt-get install dropbox
sudo apt-get install sux
sudo apt-get install pm-utils
sudo apt-get install gparted
sudo apt-get install terminator
```