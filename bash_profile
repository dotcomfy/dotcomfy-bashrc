# Minimal .bash_profile that just reads .bashrc
[ -f ~/.bashrc ] && . ~/.bashrc

# To override a non-bash standard shell where you can't change it with chsh
#
## # If I'm able to run bash, and not running it already, then exec it
## if bash --version > /dev/null && [ -z "$RUNNING_BASH" ] ; then
## #  echo "will run bash"
##   RUNNING_BASH="yes, actually"
##   export RUNNING_BASH
##   SHELL=`which bash`
##   export SHELL
##   exec bash
## fi
##
