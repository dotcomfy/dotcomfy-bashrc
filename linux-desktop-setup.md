# Handy stuff for Linux on the desktop
I couldn not think of where to put these notes, so they can live here for now.

## Gnome: Classic move/resize behaviour using mouse buttons and keyboard modifier
Move with left mouse button, resize with right
https://unix.stackexchange.com/questions/28514/how-to-get-altright-mouse-to-resize-windows-again

Enable right button resize:
```
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
```

By default, gnome uses Super (Windows key), but that can be changed. If you have your mouse on the left, then you can change it to `'<Ctrl>'`, to avoid unnecessary keyboard gymnastics.

```
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier '<Alt>'
```

## Keyboard shortcuts in Gnome not working other than in default keyboard layout
```
ibus exit
```
