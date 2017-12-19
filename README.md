The Dotcomfy bashrc - AKA The .bashrc from Hell (tm)

# Disclaimer

## Please read the disclaimer at the top of bashrc

# Getting started

## Back up your old .bashrc, if you want to hang on to it
    mv ~/.bashrc ~/.OLD.bashrc
## Download the bashrc
    wget  -q -O ~/.bashrc https://raw.githubusercontent.com/dotcomfy/dotcomfy-bashrc/master/bashrc
## Source it
    . ~/.bashrc
## Make sure that your .bashrc is loaded by your profile, if it isn't already
    echo '[ -f ~/.bashrc ] && . ~/.bashrc' >> .bash_profile


# Other tips

If you can't change your login shell, but still want to run bash when it's available,
then this little hack can be quite useful.
I used to do this in an environment where I had a lot of different Unix flavours, but with shared home dirs

```
if bash --version > /dev/null && [ -z "$RUNNING_BASH" ] ; then
  #  echo "will run bash"
  RUNNING_BASH="yes, actually"
  export RUNNING_BASH
  SHELL=`which bash`
  export SHELL
  exec bash
fi
```
