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

## Make things like visudo use the right editor (they ignore $EDITOR and use nano instead)
```
sudo update-alternatives --config editor
```

## Enable hibernate/suspend to disk

Unless you install uswsusp, then hibernate just shuts down
```
sudo apt install uswsusp
```

If swap has changed, then a new initrd needs to be generated:
```
sudo update-initramfs  -k '5.4.0-29-generic' -v -u
```

You also need to set the resume parameter for the kernel, which in turn sets /sys/power/resume

To enable it right away:
Use `lsblk` to find the swap device minor:major, then: `echo 259:7 > /sys/power/resume`

For kernel param, find the UUID using `blkid`
Set in /etc/default/grub, then run update-grub
Example:
```
GRUB_CMDLINE_LINUX_DEFAULT="text resume=UUID=b0e3fbc0-309f-41f9-871e-513eef6a2f30"

```

## USB Wake
Note that you may need to enable wakeup not only for the actual device, but also the parents
```
grep .  /sys/bus/usb/devices/*/product
grep . /sys/bus/usb/devices/*/power/wakeup
# Find the right devices, then:
echo enabled > /sys/bus/usb/devices/1-3.3.4/power/wakeup
echo enabled > /sys/bus/usb/devices/1-3.3/power/wakeup
echo enabled > /sys/bus/usb/devices/1-3/power/wakeup
```

If this all works, then put the commands into /etc/rc.local or similar

## L2TP VPN
Install the required software, and then you can set it up in Settings
```
sudo apt-get update
sudo apt-get install network-manager-l2tp
sudo apt-get install network-manager-l2tp-gnome
```


## Microsoft OneDrive
There are multiple options for OneDrive sync

Rclone
Sort of like rsync for cloud storage. Does not do two-way sync, but there are third party tools for this. Useful for backups?

https://www.insynchq.com/ - allegedly works with OneDrive and Team Sites

ExpanDrive

I know that when setting up GNOME. you get asked if you want to log into OneDrive and other online services, but I never used it myself. I have Nextcloud on a v-server and that is all I need.


## Various softwares that I tend to use
```
sudo apt-get install cvs
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
sudo apt-get install cifs-utils
sudo apt-get install inetutils-traceroute
```
