# The Dotcomfy bashrc
AKA The .bashrc from Heaven™

Previously known as The .bashrc from Hell™, because having so much code in your environment used to be frowned upon. Renamed on popular demand (my wife suggested it).

## Disclaimer

Please read the disclaimer at the top of bashrc

## Getting started

### Back up your old .bashrc, if you want to hang on to it
    mv ~/.bashrc ~/.OLD.bashrc
### Download the bashrc using whatever HTTP downloader you prefer:
    wget -q -O ~/.bashrc https://raw.githubusercontent.com/dotcomfy/dotcomfy-bashrc/master/bashrc
    curl --output  ~/.bashrc https://raw.githubusercontent.com/dotcomfy/dotcomfy-bashrc/master/bashrc
### Source it
    . ~/.bashrc
### Make sure that your .bashrc is loaded by your profile, if it isn't already
    echo '[ -f ~/.bashrc ] && . ~/.bashrc' >> .bash_profile

## Automatic updates and reloads

Since long before Windows Update became an automated service, this bashrc has had an auto update feature :-)

You can run "shrcupd" manually, or just wait for it to occasionally ask you about updating. It also automatically reloads the file in any running shells when it detects a change to the files

## Customization

You can use ~/.local_bashrc for local customisations. There's an example file in this git repo.


## Other tips

If you can't change your login shell, but still want to run bash when it's available,
then this little hack can be quite useful.
I used to do this in an environment where I had a lot of different Unix flavours, but with shared home dirs (which allowed me to have the same profile everywhere). Bash was installed in different places depending on OS, and some didn't have Bash at all.

```
if bash --version > /dev/null && [ -z "$RUNNING_BASH" ] ; then
  #  echo "Will run bash"
  RUNNING_BASH="yes, actually"
  export RUNNING_BASH
  SHELL=`which bash`
  export SHELL
  exec bash
fi
```
