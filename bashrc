# The .bashrc from Heaven (tm)
# Previously known as The .bashrc from Hell
# https://github.com/dotcomfy/dotcomfy-bashrc/
#
###############################################################################
#
# Copyright (c) 1999-2022 Linus / Dotcomfy
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################
#
# To see the different sections in this file, run: shrcinfo
#
# Despite the name, this code should also work with other Bourne style shells.
# I've used it in plain old Bourne Shell, Korn, and probably others,
# but it's been a few years, and I might have added something that's
# incompatible
#
# Local customizations are done in .local_shellrc
#
# DISCLAIMER: Please do not use this .bashrc without FULLY understanding
# what it does. For all you know, it could be doing some really evil stuff.
#
# TODO:
# - Documentation and usable list of functions and aliases
# - Clean up stuff that I never use. The world has moved on a bit since 1999
#
# From 1999 to Dec 2010, this file was just kept in RCS on one of my servers
# As of Dec 2010, it is on github
# Last RCS version:
# $Header: /home/linus/RCS/.bashrc,v 1.338 2010/12/22 13:29:51 linus Exp $
#
# Populated by commit hook
DCMF_BASHRC_VERSION='Git version'

# Source custom stuff, if it's there
[ -f /etc/profile.d/custom.sh ] && . /etc/profile.d/custom.sh

# Not much point in doing any of this stuff unless we're on a tty, is it?
# Ansible requests a TTY but sets TERM to "dumb", so we abort for that, too
if ! tty >/dev/null -o [ "$TERM" = "dumb" ]; then
  return
fi

###
##### SETTINGS
### Specific for the usage of the .bashrc and its functions
###
toolsbase="https://t.dotcomfy.net" # location of traceroute, ping, etc tools
dlbase="https://bashrc.dotcomfy.net" # where files are downloaded from
githubbase="https://raw.githubusercontent.com/dotcomfy/dotcomfy-bashrc/master"
shrc_age_file="$HOME/.shrc_age_file" # File where a time stamp is stored
shrc_max_age=3 # Ask for update if .bashrc age is older than this (in days)
updatefile_tmp="${TMPDIR:-/tmp}/.updatefile_tmp.$LOGNAME.$$"
# (Gnome) Notify if we're using any other keyboard layout
default_kbd_layout="gb"
# Profile files that we watch for changes. Changes to these trigger a reload.
potential_profile_watch_files="$BASH_SOURCE ~/.local_shellrc ~/.bash_profile ~/.bashrc ~/.profile /etc/profile.d/custom.sh"
# Normally, with screen, you want to attach to an existing session (-D) and with UTF-8 enabled (-U)
gnu_screen_base_cmd='screen -D -U'
# Where is our OneDrive mounted, if we use it
onedrive_mountpath=/mnt/onedrive-vm
# Settings for ocd() functionality
dcmf_ocd_directories="$HOME"
dcmf_ocd_cache=~/.dcmf-ocd-cache
dcmf_ocd_cache_ttl=7200
# GUI file manager used on unix-like systems. Could be set to "true" as a no-op
unixish_gui_file_manager=thunar

# The location of this file, probably in the user's home directory
# During development, the file may be loaded from several locations, and we don't want to override the first one (which is probably the "real" file)
if [ -n "$shrc_home" ] ; then
  # We've already set this, no need to do anything
  true
elif [ -z "$BASH_SOURCE" ] ; then
  # We don't know what file we're in, assume ~/.bashrc
  shrc_home="$HOME/.bashrc"
else
  # This file is the bashrc
  shrc_home=$BASH_SOURCE
fi

###
##### SHELL VARIABLES
### Stuff used by various commands/applications, or the shell itself
# Locale, doesn't work on Termux in Android
if [ "$OSTYPE" = "linux-gnu" ] ; then
  LANG=en_GB.utf8 export LANG
  LANGUAGE=en_GB.utf8 export LANGUAGE # Only used by Perl?
  LC_TIME=en_GB export LC_TIME
  LC_NUMERIC=en_GB export LC_NUMERIC
  LC_ALL=en_GB.utf8 export LC_ALL
fi

# The One True Text Editor (TM)
EDITOR=vi export EDITOR
# Warnings when compiling
CFLAGS=-Wall export CFLAGS
# Don't keep bg, fg or exit in history
HISTIGNORE="&:[bf]g:exit" export HISTIGNORE
# Keep a decent sized history
HISTSIZE=5000 export HISTSIZE
# I prefer less as a pager, if it exists
if [ -z "$PAGER" ] ; then PAGER=less ; export PAGER ; fi
# Override some standard settings for less
# -M gives a more verbose prompt
# -F display the contents and quit if contents fit within terminal height
# -R handle escape characters - ANSI colours, etc
# -X stops less from redrawing on quit, so that output remains on terminal
LESS="-M -F -R -X"
export LESS
# Set USER and HOSTNAME if they aren't set
if [ -z "$USER" -a ! -z "$LOGNAME" ] ; then
  USER=$LOGNAME
elif [ -z "$USER" ] ; then
  LOGNAME=$(id -un)
  USER=$LOGNAME
fi
export USER LOGNAME
if [ -z "$HOSTNAME" ] ; then
  HOSTNAME=$(hostname) export HOSTNAME
fi
CVS_RSH=/usr/bin/ssh ; export CVS_RSH
# Debugger prompt
PS4='$0:$LINENO: ' ; export PS4
# MySQL prompt, hostname:databasename
MYSQL_PS1="$(hostname -s):\d> " export MYSQL_PS1
# Used as the default title on screen windows
# For new screens, it's allso affected by shelltitle in .screenrc
SCREEN_TITLE=" "
# Download location
shrc_url="$dlbase/latest/?h=$(hostname)&u=$USER" # download location of .bashrc


###
##### Shell options,
### Changing a few defaults
###
if [ -n "$BASH" ] ; then
  shopt -s histappend
  shopt -s dirspell
  shopt -s cdspell
  shopt -s autocd
  shopt -s histreedit
fi

###
##### COLOURS
### used in prompts, etc
###
BLACK="\033[0;30m"
BLACKWHITE="\033[0;40m"
RED="\033[0;31m"
REDWHITE="\033[0;41m"
GREEN="\033[0;32m"
GREENWHITE="\033[0;42m"
YELLOW="\033[0;33m"
YELLOWWHITE="\033[0;43m"
BLUE="\033[0;34m"
BLUEWHITE="\033[0;44m"
PURPLE="\033[0;35m"
PURPLEWHITE="\033[0;45m"
TEAL="\033[0;36m"
TEALWHITE="\033[0;46m"
WHITE="\033[0;37m"
ENDCOLOUR="\e[m"


###
##### HELPER FUNCTIONS
### Used by other functions throughout the .bashrc
### These need to be listed early, to make them accessible to others

# Print something on stderr
warn(){
  echo "$@" >&2
}

# Picks a screen session to load/start, based on some commons screen session names, as configured in $screen_session_alternatives (set this in .local_shellrc)
# I use this on some of my servers where I have different named screen sessions, with different environments, for different dev projects
screen_session_picker(){
  echo "Please choose one of the following screen sessions"
  echo "For a generic session for this host, choose 0 or 1"
  echo "To list active sessions, type 'l' (lowercase L)"
  echo "Use 'q' or any other invalid answer to quit"
  local _screen_session
  select _screen_session in $(hostname -s) $screen_session_alternatives; do break ; done
  echo "You selected: $REPLY / $_screen_session"
  if [ "$_screen_session" = "$(hostname -s)" -o "$REPLY" = "0" ] ; then
    echo "Loading generic screen session"
    $gnu_screen_base_cmd -R $(hostname -s)
  elif [ "$REPLY" = "l" ]; then
    screen_active_session_picker
  elif [ -z "$_screen_session" ] ; then
    echo "No valid selection, quitting"
  else
    echo "Running selected: $_screen_session"
    $_screen_session
  fi
}


screen_auto_attacher(){
  # If we're not already in screen, and the "s" alias is defined, then reattach screen
  if [ -z "$STY" -a -z "$first_load_of_dotcomfy_bashrc_completed" -a "$screen_auto_attach" = "yes" ] ; then
    $screen_alias
  fi
}

# Picks one of the current running screen sessions, and loads it
screen_active_session_picker(){
  local _selected_session
  running_screen_sessions=$(screen -ls | grep '^\s' | awk '{print $1}' | grep -v '^\s$')
  select _selected_session in $running_screen_sessions ; do break ; done
  $gnu_screen_base_cmd -r $_selected_session
}

# This is the setup for the stuff that watches the various profile files. It gets used by shrc_reloader
add_watched_profile_files(){
  local _file
  for _file in $*; do
    # Using eval, so that tilde expansion works
    _file=$(eval echo $_file)
    #echo "Considering watch file: $_file"
    if [ -f $_file -a -r $_file ] && ! echo $profile_watch_files | grep "$_file" >/dev/null ; then
      #echo "Adding: $_file"
      profile_watch_files="$profile_watch_files $_file"
    fi
  done
}

# Loads one or more profile files, and adds them to list of watched files. Watched files get reloaded when a change is detected.
add_profile_files(){
  local _file
  for _file in $*; do
    [ -f $_file ] && . $_file
  done
  add_watched_profile_files $*
}

# Check if a pid is running
isrunning(){
  kill -0 $1 > /dev/null 2>&1
}

# Dump a web page to stdout, in a reasonably usable format (HTML removed)
# Uses lynx - could be rewritten to use something else
wwwdump(){
  local url
  # replace selected special chars...
  url=`echo $* | sed 's/ /%20/g' | sed 's/"/%22/g'`
  # Using curl and piping to lynx, since curl has better handling of multi-domain SSL certificates
  curl -L $url | lynx -stdin -hiddenlinks=ignore -nolist -dump
}

# Make ssh aliases - takes a list of host names and creates ssh aliases for them
# Helper function to be used from .local_shellrc
# Example: mksshalias -s "foo bar.example.com baz"
# To specify a username, use: MKSSHALIAS_USER=user@
mksshalias(){
  local shorten="N"
  local hostname
  local shortcut
  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME [-s] <space separated list of hosts>"
    return 1
  fi

  # Shorted hostnames passed to screen_ssh if first argument is "-s"
  if [ "$1" == "-s" ] ; then shorten="Y" ; shift ; fi

  while [ ! -z $1 ] ; do
    hostname=$1 ; shift

    if [ $shorten == "Y" ] ; then
      # strip everything after the first dot, strip username@
      shortcut=`echo $hostname | sed 's/\..*// ; s/.*@//'`
    else
      shortcut=$hostname
    fi
   title=$shortcut
   alias $shortcut="screen_ssh $MKSSHALIAS_USER$hostname $title"
   done
}

set_screen_title(){
  # To make screen titles get set, one of these conditions needs to be met:
  # screen_title_prefix - for example, on host1.example.com, I may set this to "host1:", so if I'm editing some_script.sh, screen title gets set to host1:some_script.sh
  # $STY - this gets set on the server that screen runs on, usually bouncer
  # For any other server that I ssh to, the screen title gets set to the hostname of the server, when I launch the SSH command. This makes for shorter titles.
  [ -z "$STY" ] && [ -z "$screen_title_prefix" ] && return
  local newtitle="${screen_title_prefix}${1}"
  [ -z "$newtitle" ] && newtitle=$(hostname -s)
  echo -ne "\ek$newtitle\e\\"
}


# sets the title in x terminals, used by cd() and others to update title bars
# the variables xtitle1 and xtitle2 can be set in local shellrc,
# to prepend or append a string to the title
xtitle(){
  case $TERM in
   *term* | *color | rxvt | vt100 | vt220 | cygwin | screen* )
      echo -n -e "\033]0;${xtitle_prefix}${xtitle1}${*}${xtitle2}\007" ;;
   *)  ;;
     esac
}

# sets the title to "default"
xbacktitle(){
  xtitle "$USER@$HOSTNAME:$PWD"
}

# Ask for yes or no answer - return 1 unless answer contains n|N
askyesno(){
  echo -n "$@ [Y|n] " ; read yesno
  case "$yesno" in
    n*|N*) return 1 ;;
    *) return 0 ;;
  esac
}

# Check if a lock file exists
# used by virt(), ali(), spam()
checklockf(){
  local lockfile=$1
  local file=$2
  if [ -e $lockfile ] ; then
    echo "Lockfile found: $lockfile"
    ls -l $lockfile
    echo "Someone else is probably editing $file"
    echo "If this is not the case, please delete $lockfile"
    return 1
  elif ! touch $lockfile ; then
    echo "Failed to create lock file: $lockfile"
    return 1
  else
    return 0
  fi
}

# Lock a file, and edit it with sudo.
# The locking stuff is kind of overkill, I suppose, as long as I always use vi
# But could be useful for others
# This used to be called sudoedit, but now that's a symlink to sudo, at least on Ubuntu
sudoeditor(){
  local file=$1
  if [ ! -f "$file" ] ; then echo "File does not exist: $file" ; return 1 ; fi
  local name=$(basename $file)
  local lockfile=${TMPDIR:-/tmp}/.$name.lock
  local md5before=$(sudo md5sum $file)
  echo "Running sudo editor"
  if ! checklockf $lockfile $file ; then return 1 ; fi
  sudo $EDITOR $file
  rm -f $lockfile
  local md5after=$(sudo md5sum $file)
  if [ "$md5before" = "$md5after" ]; then
    echo "No changes to file: $file"
    return 1
  else
    echo "Changes made to file: $file"
    return 0
  fi
}

# Part convenience, part play :)
# Either reruns previous command with sudo, or just acts as an alias for sudo
please(){
  local runcmd=""
  if [ $# -gt 0 ] ; then
    runcmd="$*"
  else
    runcmd="$(fc -n -l -2 -2 | sed 's/^\s*//')"
    echo "Rerunning with sudo: $runcmd"
  fi
  # Rewrite history, so that the previous command is the sudo command, rather than "please"
  history -s sudo $runcmd
  sudo $runcmd
}

# Similar to please, but reruns previous command with the "z" (decompressing) version of the previous command
zplease(){
  fc -s cat=zcat diff=zdiff less=zless grep=zgrep
}

# Use RCS to check out all files in current directory (if under version control)
alias coall="rcsall co -l"
alias ciall="rcsall ci -u"
alias diffall="rcsall rcsdiff"

rcsall(){
  $* $(find RCS -type f)
}

###
###
##### COMMAND ALIASES
### General command aliases - includes a few default flags and stuff
###
alias dyndns="sudo reason=manual_config sh /etc/dhcp/dhclient-exit-hooks"
alias obsdcvs="cvs -d anoncvs@anoncvs.se.openbsd.org:/cvs"
alias lock="clear ; lock -p -n ; echo \"Welcome back, it's \`date\`\""
alias eterm="Eterm -x -O --scrollbar 0 --menubar 0"
alias xlock="xlock -mode matrix"
alias stddate="date \"+%Y-%m-%d %H:%M:%S\""
alias datestring="date \"+%Y%m%d-%H%M%S\""
alias ls="ls -F"
alias ll="ls -lF"
alias la="ls -aF"
alias lt="ls -lt"
alias xvbg="xv -root -rmode 5 -maxpect -quit" # set X background with xv
alias dotrc=". $shrc_home"
alias linusping="ping -p 6c696e7573" # sends "linus" as byte padding in packet
alias suidfind="find / -perm -4000 -or -perm -2000"
alias calentool="calentool -D 2 -e" # ISO date format and week starts on monday
alias prtdiag='/usr/platform/`uname -i`/sbin/prtdiag' # Diag command on Suns
alias s_client="openssl s_client -connect" # "ssl telnet"
alias ps1="set_primary_prompt"
alias nom="echo 'Nom nom!' ; npm" # For Tin <3
# The alias for screen gets set *after* loading local bashrc, since it depends on settings from it

# Allows running functions and aliases with sudo (eg, "runsudo m4mc")
alias runsudo="sudo bash -i -c"
# Set the character set in terminal back to the standard one (useful when screwed up, eg by accidentally viewing a binary file)
alias unscrew="perl -e 'printf(\"%c\n\", 15); '"
# screw terminal (set it into graphics mode) - if you've got "unscrew", you've gotta have "screw"
alias screw="perl -e 'printf(\"%c\n\", 14); '"
alias ..='cd ..'
alias ...='cd ../..'
alias path='echo -e ${PATH//:/\\n}'
alias exit='kill -9 $$'
# I generally always want cvs to be quiet
alias cvs="cvs -q"
# Compression is almost always a good idea for scp
alias scp="scp -C"
# Convert to lowercase
alias lowercase="sed -e 's/./\L&/g'"
# Opens a file manager window in the current directory. Handy only because it does the same thing in Windows command prompt, which has become a habit of mine.
alias start.="$unixish_gui_file_manager ."
# Edit .local_shellrc
alias vilshrc="vi ~/.local_shellrc"


###
### File fetching aliases
# Get the standard .bash_profile
alias bpget="updatefile ~/.bash_profile $githubbase/bash_profile"

# Get a skeleton .local_shellrc
alias lsget="updatefile ~/.local_shellrc $githubbase/local_shellrc"

# Get/update  the standard .screenrc
alias screenrcget="no_source_after_update=true updatefile ~/.screenrc $githubbase/.screenrc"

###
### Whois aliases, and a bit of DNS
###
alias internic="whois -h whois.internic.net"
alias arin="whois -h whois.arin.net"
alias ripe="whois -h whois.ripe.net"
alias apnic="whois -h whois.apnic.net"
alias lacnic="whois -h whois.lacnic.net"
alias nsi="whois -h whois.networksolutions.com"
alias uk="whois -h whois.nic.uk"
alias geektool="whois -h whois.geektools.com"
alias gtldns="dig @a.gtld-servers.net ns"


###
##### PROGRAMMABLE COMMAND COMPLETION
###

# Only do this if the complete command exists (BASH 2.04 and later, methinks)
if complete > /dev/null 2>&1 ; then
  # I used to have a bunch of these, but got annoyed with most of them, and deleted them one at a time...
  # now only keeping directories for cd, which I guess is kind of handy
  complete -d cd
fi

###
##### STUFF REQUIRED BY LOCAL SHELLRC
###

# Function to save some typing when adding stuff to $PATH
pathadd(){

  local quiet="yes" # Quiet by default
  if [ "$1" = "-v" ] ; then quiet="" ; shift ; fi

  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME path (path elements separated by whitespace)"
    return 1
  fi

  # Go through the directories, add them to $PATH if they exist
  while [ ! -z "$1" ] ; do
    local newdir=$1; shift

    if [ -d $newdir ] ; then
      # Lame test to see if directory is already in path
      # Look for beginning-of-line or colon, followed by dir, followed by colon or end-of-line
      if echo $PATH | egrep '(^|:)'"$newdir"'(:|$)' > /dev/null ; then
        [ -z "$quiet" ] && echo "$newdir is already in PATH"
      else
        PATH=$PATH:$newdir
        [ -z "$quiet" ] && echo "Added $newdir to PATH:" && echo "$PATH"
      fi
    else
      [ -z "$quiet" ] && echo "Directory $newdir doesn't exist"
    fi
  done

  export PATH
}

###
### Local config file - local_shellrc
###
# local_shellrc needs to be able to override the above settings
[ -f ~/.local_shellrc ] && . ~/.local_shellrc
# .local_shellrc can look for this variable to avoid running the same
# command twice
# Example:
# echo "This gets run every time"
# if [ "$local_shellrc_run" = "1" ] ; then return ; fi
# echo "This only gets run the first time"
local_shellrc_run=1


# This depends on $screen_session_alternatives, which may be set in local shellrc
# Screen alias - if we're not in screen
if [ ! -z "$STY" ] ; then
  screen_alias="echo 'You ARE already in screen!'"
elif [ -n "$screen_session_alternatives" ] ; then
  screen_alias="screen_session_picker"
else
  screen_alias="$gnu_screen_base_cmd -R"
fi
alias s="$screen_alias"
# Reattach, if enabled
screen_auto_attacher

###
###
##### FUNCTIONS / UTILS
### Some of these are old shell scripts or small perl scripts
### that are quite handy to have available on any host I might log in to

# Find a file (or many files, or all files) and edit it in vi
vifind(){
  vi $(find . -name '*'$*'*' -type f)
}

# Snippet for bringing all windows to the viewable desktop area in X
# Works on Ubuntu 21.04 / XFCE
gather_windows(){
  # Offsets, to allow for menu bars etc
  local offset_x=70
  local offset_y=0

  # Get the current desktop size
  desktop=$(wmctrl -d | awk '{print $9}')
  IFS=x read dt_x dt_y <<< $(echo $desktop)
  # Remove a little bit, since windows seem to take up a tiny bit more space than expected
  let dt_y=$dt_y-27
  let dt_x=$dt_x-10

  wmctrl -l -G | while read id sticky curr_x curr_y curr_w curr_h host win_title; do
    # Move only non-sticky windows
    [ $sticky  -eq 0 ] || continue
    # echo "Window: <$win_title>, x: $offset_x, y: $offset_y, $curr_w, $curr_y"
    # If window is taller or wider than desktop, then shrink it to the desktop size
    new_width=$(( curr_w < dt_x ?  curr_w : dt_x))
    new_height=$(( curr_h < dt_y ?  curr_h : dt_y))
    # Move to top left corner, and resize if applicable
    wmctrl -i -r $id -e 0,$offset_x,$offset_y,$new_width,$new_height
  done
}

# Simillar to above, but maximise all instead
maximise_windows(){
  wmctrl -l | while read id sticky foo ; do
    [ $sticky  -eq 0 ] || continue
    wmctrl -i -r $id -b add,maximized_horz,maximized_vert
  done
}

# Probably obvious by now?
unmaximise_windows(){
  wmctrl -l | while read id sticky foo ; do
    [ $sticky  -eq 0 ] || continue
    wmctrl -i -r $id -b remove,maximized_horz,maximized_vert
  done
}

# When recovering a file from a crashed vi session, or after a reboot, there are too many manual steps
virecover(){
  local orgfile="$1"
  local swpfile="$(dirname $orgfile)/$(basename $orgfile | sed -r 's/^([^\.])/.\1/').swp"
  echo "Details of original file and swap file"
  if [ ! -f "$swpfile" ] ; then
    echo "No swapfile, let's just edit"
    vi "$orgfile"
    return
  fi
  ls -l "$orgfile" "$swpfile"
  vi -r "$orgfile"
  echo "If you're happy with recovery, please press ENTER to remove $swpfile and begin editing"
  read foo
  rm "$swpfile"
  vi "$orgfile"
}

unalias pmlog >/dev/null 2>&1
pmlog(){
  pmdir="$HOME/.pm"
  pmlog="$pmdir/procmail.log"
  pmbak="$pmdir/procmail.log-$(date '+%Y%m%d-%H%M%S')"
  [ -f "$pmlog" ] || (echo "No procmail log file: $pmlog" ; return)
  if [ -s $pmlog ] ; then
    cp $pmlog $pmbak
    gzip $pmbak
    echo "Saved $pmbak.gz"
  else
    echo "$pmlog is empty"
  fi
  mailstat -l $pmlog | $PAGER
}

# Sort, uniq with a count, and sort again, to see how many times each line occurs in input
groupby(){
  sort | uniq -c | sort -n
}

# Find the IP address in a string, which contains only one IP in the first place
findip(){
  perl -pe 's/.*?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/'
}
# Convert IP address to network address, used when faffing with FW rules and stuff
# Assumes input that it just an IP address, or at least at the end of a line
# Example for ipto16: 192.168.1.1 --> 192.168.0.0/16
ipto8(){
  sed -r 's/(\.[0-9]+){3}$/.0.0.0\/8/'
}
ipto16(){
  sed -r 's/(\.[0-9]+){2}$/.0.0\/16/'
}
ipto24(){
  sed -r 's/(\.[0-9]+){1}$/.0\/24/'
}

# Hibernate and suspend functions
# This can be combined with defining a piece of code to run prior to suspend/hibernate, for example
# presuspend='echo "Pausing Spotify"; pause'
pmhibernate(){
  eval $_dcmf_presuspend
  echo "Hibernating at $(date)"
  sudo systemctl hibernate
}

pmsuspend(){
  eval $_dcmf_presuspend
  echo "Suspending at $(date)"
  sudo systemctl suspend
}



# Check that OneDrive is mounted, and go to the relevant folder
# This assumes that onedrive_mountpath is set correctly, and has an entry in fstab
onedrivemnt(){
  if mountpoint -q $onedrive_mountpath ; then
    echo "OneDrive is already mounted at $onedrive_mountpath"
  else
    echo "Mounting OneDrive at $onedrive_mountpath"
    sudo mount $onedrive_mountpath || echo "Mount failed"
  fi
  mountpoint -q $onedrive_mountpath && $unixish_gui_file_manager $onedrive_mountpath
}

# Edit procmailrc, using RCS
vipmrc(){
  editfile ~/.procmailrc
}

# Check time since last successful update of this file
# Used by the update checker
shrc_check_age(){
  local age_seconds
  local age_days
  # get date of current .bashrc from age file
  shrc_date=$(cat $shrc_age_file 2>/dev/null)
  if [ -z "$shrc_date" ] ; then shrc_date=0 ; fi

  # compare to current date
  # some strftime(3) implementations don't have %s - so use Perl to get
  # seconds since epoc
  let age_seconds=$(perl -e 'print time();')-$shrc_date

  # translate into days
  let age_days=$age_seconds/68400 # age in days

  echo $age_days
}

profile_last_loaded_at=$(date +%s)
shrc_reloader(){
  if [ "$DCMF_OS" = "osx" -o "$DCMF_OS" = "obsd" ] ; then
    statcmd="stat -f %m"
  else
    statcmd="stat --format %Y"
  fi
  profile_files_on_disk_modified_at=$($statcmd $profile_watch_files | sort -rn | head -1)
  # echo "Comparing $profile_last_loaded_at against $profile_files_on_disk_modified_at"
  if [ -z "$profile_last_loaded_at" -o $profile_files_on_disk_modified_at -gt $profile_last_loaded_at ]; then
    echo "Detected change in one of the profile files, reloading dotcomfy bashrc"
    dotrc
    profile_last_loaded_at=$(date +%s)
  fi
}
add_watched_profile_files $potential_profile_watch_files
if ! echo "$PROMPT_COMMAND" | grep shrc_reloader >/dev/null ; then
  PROMPT_COMMAND="shrc_reloader; reset_term_titles; $PROMPT_COMMAND"
fi

# check version of .bashrc

# Sending / receiving files via transfer.sh, encrypted
transfersend(){
  local infile=$1
  local oldpwd="$(pwd)"
  cd $(dirname $infile)
  infile=$(basename $infile)
  echo "In $(pwd) working on $infile"
  aescat $infile > $infile.enc
  local res=$(cat $infile.enc | curl -X PUT -T "-" https://transfer.sh/$infile)
  echo
  echo "Sent to transfer.sh: $res"
  rm $infile.enc
  cd "$oldpwd"
}

transferget(){
  local url=$1
  local fname=$(echo $url | sed 's/.*\///')
  local tmpfile=${TMPDIR:-/tmp}/$fname.$$.$(datestring)
  echo "Saving to: $fname"
  if [ -f $fname ] ; then
    local remotefile=$fname
    fname=$fname.$(datestring)
    echo "$remotefile exists, saving to $fname instead"
  fi
  curl $url > $tmpfile
  aescat $tmpfile > $fname
  rm $tmpfile
  echo "Saved $fname"
}


# Runs html2haml on a file, and renames it from .html.erb to .html.haml
# Also ensures that ERB comments are parseable by html2haml, by adding a space (<%# Hello %> should be <% # Hello %>)
# This is not an issue for comments starting with "<%-#"
erb2haml(){
  local _infile="$1"
  _tmpfile="$_infile.tmp.$$"
  _hamlfile="$(echo $_infile | sed 's#\.erb$#.haml#')"
  # Add space
  perl -pi -e 's/<%#/<% #/g' $_infile
  html2haml $_infile $_tmpfile
  mv $_tmpfile $_infile
  git mv $_infile $_hamlfile
}


# Put timestamps on the output of any command
timestamp(){
  while read line ; do echo "$(date) $line" ; done
}
# Ping output with a timestamp
timeping(){
  ping $* | timestamp
}


# LSOF functions, for some handy sets of commands. Probably only works on Linux.
list_deleted_open_files(){
  (
    # First, a hack to get a header
    lsof -p 1 | head -1
    # Then, loop over all running processes, and for each process, look for deleted files
    # To avoid noise, we grep out /dev/zero
    for pid in $(ps aux | awk '{print $2}' |  grep -v PID) ; do lsof -p $pid ; done | grep deleted | grep -v '(deleted)/dev/zero (stat: No such file or directory)'
  ) | column -t
}
list_large_open_files(){
 (
   echo "Size Path"
   lsof +D / | awk '{print $7 " " $9}' | grep -v ^SIZE| sort -u | sort -rn
 ) | column -t
}

# Take table, such as the output from MySQL, and turn it into CSV
# If a value in a row contains a space, followed by a pipe, and onother space, it
# will incorrectly parse it as two values, and make separate columns in the output
# +-----------+---------+
# | column1   | column2 |
# +-----------+---------+
# | foo | bar | baz     |
# +-----------+---------+
# Will incorrectly become:
# "column1","column2"
# "foo","bar","baz"
# Instead of:
# "column1","column2"
# "foo | bar","baz"
# Tough cheese, but that's just what you get :-)
csvify_table(){
  grep -v '^+' | sed 's/^| */"/; s/  *| *$/"/; s/ * | * /","/g'
}

# Convert MySQL output to CSV, including column names, which are lost when using 'INTO OUTFILE' to produce CSV
mysql_dump_csv(){
  # This argument handling probably only works in BASH, but it's a tradeoff for being able to quote just the last argument (the query)
  # The query is the very last argument
  local mysql_query="${@: -1}"
  # The other arguments are passed on as-is to MySQL
  local mysql_args=${@:1:$(($#-1))}
  #echo "db args: $mysql_args, query: $mysql_query" >&2
  mysql --table --column-names $mysql_args -e "$mysql_query" | csvify_table
}

# Resize images, using imagemagick "convert"
resizeimg(){
  local newres="${RES:-1440}"
  for file in "$@"; do
    origfile="preresize-$file"
    mv -i "$file" "$origfile"
    echo "Converting $file to $newres, keeping $origfile"
    convert "$origfile" -resize $newres -strip "$file"
  done
}


# A function for concatenating audio files. Supports any input formats that Sox supports, such as wav and MP3
# Works by converting all input files into raw format, concatenating the raw files,
# and then converting to the desired format
audioconcat(){
  # Put all temp files in their own directory - easy to clean up, and no permission issues as long as we've got temp space
  local tmpdir=${TMPDIR:-/tmp}/audioconcat.$$.tmp

  # The last argument is the output file
  eval local outfile=\${$#}

  # Options for sox, adjust as necessary
  local soxoptions="--rate 48000 --channels 2 --encoding signed-integer --bits 24"

  # There should be at least three arguments - two input files and an output file
  if [ $# -lt 3 ] ; then
    echo "Usage: audioconcat [ files ] <outfile>"
    echo "Example: audioconcat input1.wav input2.wav output.wav"
    return 1
  fi

  # Abort if we can't create the temp directory
  mkdir $tmpdir || ( echo "Failed to create temp dir: $tmpdir" ; return 1)

  echo "Concatenating all files into $outfile"
  echo "Using options for sox: $soxoptions"
  echo

  count=0
  while [ $# -gt 1 ] ; do
    local thisfile=$1 ; shift
    local count=$(expr $count + 1)

    # Abort if any of the files don't exist
    if ! [ -r $thisfile ] ; then
      echo "File does not exist or is not readable: $thisfile, aborting"
      rm -rf $tmpdir
      return 1
    fi

    local thistempfile=$tmpdir/outtemp.$count.raw
    # Store this file in the list of files we've processed, and the name of the temp file for concatenating
    local inputfiles="$inputfiles $thisfile"
    local rawtempfiles="$rawtempfiles $thistempfile"
    echo "Processing: $thisfile ($thistempfile)"
    sox $thisfile $soxoptions $thistempfile
  done

  # Do the actual concatenation of files
  cat $rawtempfiles > $tmpdir/concatenated.raw

  echo "Creating output file: $outfile"
  sox $soxoptions $tmpdir/concatenated.raw $outfile

  echo "Done, created $outfile from:$inputfiles"
  #rm -rf $tmpdir
}

# Print info about the host you're on, who you're logged in as, etc
wtf(){
  firstcolumn=20
  if type inxi >/dev/null> /dev/null 2>&1;then
    inxi
    inxi -S
    inxi -B
    inxi -D
  fi
  echo "Hostname:     $(hostname)"
  echo "OS:           $(uname -a)"
  if [ $(uname -s) = "Linux" ] ; then
    echo
    echo "Linux Release info:"
    if [ -f /etc/os-release ] ; then
      . /etc/os-release
      echo "$PRETTY_NAME"
    elif [ -f /etc/lsb-release ] ; then
      . /etc/lsb-release
      echo "$DISTRIB_DESCRIPTION"
    elif [ -f /etc/redhat-release ] ; then
      cat /etc/redhat-release
    else
      cat /etc/*release | sort -u
    fi
  fi
  echo
  echo "Uptime:      $(uptime | sed 's/^ *//')"
  echo "Memory:      $(free -m | grep buffers/cache | awk '{ print "used: " $3 "M, free: " $4 "M"}')"
  echo "Processor:   $(grep ^processor /proc/cpuinfo | wc -l) CPU(s); $(grep '^model name' /proc/cpuinfo  | sort -u | sed 's/.*: //')"
  echo "Disk usage:"
  dfh
  echo
  echo "You:"
  if [ ! -z "$SSH_TTY" ] ; then
    last -i | grep $(echo $SSH_TTY|sed 's/^\/dev\///') | grep still.logged.in
  else
    who am i
  fi
  echo "IP:           $(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | sed 's/\s*//')"
  echo "External IP:  $(myip | tail -1 | sed 's/.*: //')"
  # echo "Netname:     $(whois -h whois.ripe.net $external_ip | grep ^netname: | awk '{print $2}')"
}

# Do a sum of a bunch of numbers. Numbers are expected to be on per line.
# For example
# 1
# 2
# 4
# Gives: 7
sumnum(){
  awk  '{sum+=$0} END {print sum}'
}

# Get a sum, total, and average from a bunch of numbers. One number per line
average(){
  sed 's/[^0-9.]//g' | awk 'BEGIN {min=99999999999999; max=-min} { total += $1; count++; if($1>max){max=$1}; if($1<min){min=$1} } END { printf "Line count: %d\nTotal: %d\nAverage: %f\nMin: %f\nMax: %f\n", count, total, total/count, min, max }'
}


# Expand a shortened URL, recursively
# Follows a chain of HTTP redirects, showing each hop, including the final destination
expandurl(){ curl -sIL $1 | grep ^Location; }
# An alternative, using wget:
#expandurl(){ wget -S $1 2>&1 | grep ^Location; }

slowrun(){
  # Poor man's scheduling... for when ionice (Linux) doesn't quite work,
  # or you just don't have access to scheduling for cpu/disk/network
  # Run, then pause, then run, etc,
  # to ensure that other processes get some time to run in between
  local run_time=2
  local pause_time=1

  # Kick off process in background
  local start_time=$(date)

  if echo $* | grep -E '^[0-9]+$' > /dev/null ; then
    local pid=$1
    local run_cmd="Existing PID"
    echo "Looks like you've specified a PID of an existing process: $pid"
  else
    local run_cmd=$*
    nice $run_cmd &
    # Grab the PID of the process we've just kicked off in the background
    local pid=$!
  fi

  echo "$(date) Running $run_cmd with PID: $pid"
  echo "$(date) Running for $run_time seconds, then pausing for $pause_time seconds, etc"

  # The many "break" are there so that, if the process is no longer running, we exit the while loop as soon as possible
  while isrunning $pid ; do
    isrunning $pid || break
    sleep $run_time
    isrunning $pid || break
    echo "$(date) Still running, stopping it for a while"
    isrunning $pid && kill -STOP $pid
    isrunning $pid || break
    sleep $pause_time
    isrunning $pid || break
    echo "$(date) Continuing..."
    isrunning $pid && kill -CONT $pid
    #ps -p $pid
  done
  echo "$(date) Done running $run_cmd, started at $start_time"
}

# Print disk usage for all files/directories, human readable, sorted by size
duf(){
  local _status
  if [ "$DUF_SUDO" = "y" ]; then sudo=sudo ; else sudo="" ; fi
  # Never include the directory itself - just the directories beneath
  args="-mindepth 1"
  if [ "$1" = "-r" ] ; then
    shift
    echo "Processing directories recursively - this could take a while..."
  else
    args="$args -maxdepth 1"
  fi
  if [ -z "$1" ] ; then dirs=. ; else dirs=$* ; fi
  for dir in $dirs ; do
    echo "Working on: $dir"
    # The final sed is there to strip out the leading "./" from file names when
    # running on the current dir
    $sudo find $dir $args -exec du -sk {} \; | sort -n | perl -ne '($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}' | sed 's/\.\///'
    $sudo du -sh $dir
    let _status=$_status+$?
  done
  if [ $_status -gt 0 -a -z "$DUF_SUDO" ]; then
    echo
    echo "There seem to have been errors ($_status), maybe you don't have the right permissions? To run with sudo, try: suduf"
    echo "You can also set DUF_SUDO=y in your profile"
  fi
}

suduf(){
  DUF_SUDO=y duf $*
}


# Create a directory or path, and go to it
mkcd(){ mkdir -p $1 && cd $1; }


bookmarkletify(){
$perl -w - $* <<"ENDOFBOOKMARKLETIFYPERL"
#
# http://daringfireball.net/2007/03/javascript_bookmarklet_builder
# Licence: http://www.opensource.org/licenses/mit-license.php

use strict;
use warnings;
use URI::Escape qw(uri_escape_utf8);
use open  IO  => ":utf8",       # UTF8 by default
          ":std";               # Apply to STDIN/STDOUT/STDERR

my $src = do { local $/; <> };

# Zap the first line if there's already a bookmarklet comment:
$src =~ s{^// ?javascript:.+\n}{};
my $bookmarklet = $src;

for ($bookmarklet) {
    s{^\s*//.+\n}{}gm;  # Kill comments.
    s{\t}{ }gm;         # Tabs to spaces
    s{[ ]{2,}}{ }gm;    # Space runs to one space
    s{^\s+}{}gm;        # Kill line-leading whitespace
    s{\s+$}{}gm;        # Kill line-ending whitespace
    s{\n}{}gm;          # Kill newlines
}

# Escape single- and double-quotes, spaces, control chars, unicode:
$bookmarklet = "javascript:" .
    uri_escape_utf8($bookmarklet, qq('" \x00-\x1f\x7f-\xff));

print "// $bookmarklet\n" . $src;
ENDOFBOOKMARKLETIFYPERL
}


# Shred a file (similar to to "shred", which is common in Linux)
shredfile(){
$perl -w - $* <<"ENDOFSHREDPERL"
  use strict;
  use Getopt::Std;
  my %opts;
  getopts('n:u', \%opts);

  sub print_usage {
    print "shredfile: Overwrites file first with random bytes, then with 0, 1, 0\n";
    print "Usage: shredfile [-n N] [-u] <filename>\n";
    print "    -n N    overwrite file N times (default 99)\n";
    print "    -u      delete (unlink) file when done\n";
    exit(1);
  }

  my $filename=shift(@ARGV) || print_usage;
  my $bytes = -s $filename;
  open (FH, "+<$filename") || die "Couldn't open file ($filename): $!\n";

  my $times = $opts{n} || 99; # overwrite 99 times by default

  print "Will overwrite $filename ($bytes bytes) $times times\n";

  sub swipe {
    my $n = shift();
    my $c = sprintf("%c", $n);
    sysseek(FH, 0, 0) || die "Can't rewind file: $!\n";
    syswrite (FH, $c x $bytes) || die "Can't write to file handle: $!\n";
#    printf ("%c", 15); print "DEBUG: $n, c: $c\n";
  }

  # First overwrite with random bytes
  for (my $i=0;$i<$times;$i++) {
    swipe ( int ( rand(255) ) );
  }

  # then write 0, 1, 0, 1
  swipe (0);
  swipe (1);
  swipe (0);

  if ( defined ($opts{u}) ) {
    print "Deleting $filename\n";
    unlink ($filename);
  }
  else {
    print "Not deleting file\n";
  }

  print "Done\n";
ENDOFSHREDPERL
}
# End of shredfile

# Strip out XML tags from text read on stdin
# Used by xmldiff, but can also be used to read a Word XML file in a terminal
xmlstrip(){
   # Replace XML tags with newlines (so that output isn't all on one line)
   # Use grep to exclude blank lines, and lines with only digits and dots
   perl -p -e 's/<[^>]*>/\n/g' | grep -v '^$' | grep -v '^[0-9.]*$'
}

# Do a diff of only the text portions of an XML file
# Used for diffing XML based word docs, for example
# It won't necessarily work well for all XML/HTML files,
# especially if tags span several lines
# this might help:
# sed -e :a -e 's/<[^>]*>//g;/</N;//ba'
xmldiff(){
  if [ $# -ne 2 -o "$1" == "-h" ] ; then
    echo "Usage: $FUNCNAME file1 file2"
    return 1
  fi
    file1=$1
    file2=$2
    tmpfile1=${TMPDIR:-/tmp}/$FUNCNAME.$$.file1.tmp
    tmpfile2=${TMPDIR:-/tmp}/$FUNCNAME.$$.file2.tmp

    xmlstrip < $file1 > $tmpfile1
    xmlstrip < $file2 > $tmpfile2

    diff -a -w $tmpfile1 $tmpfile2
    rm $tmpfile1 $tmpfile2
}

# mailshot - send the same email to a number of recipients
# Poor man's mailing list ;-)
# Takes one argument, which is a file name containing email addresses,
# one per line
# Reads an RFC822 formatted message from stdin,
# expanding the string "__RECIPIENT__"
mailshot(){
  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME messagefile"
    echo "Where messagefile is a plain text file containing the message headers and body"
    echo "The string __RECIPIENT__ in the message file gets replaced with the address of the"
    echo "current recipient"
    echo
    echo "Example: $FUNCNAME message.txt < addresses.txt"
    return 1
  fi

  messagefile=$1

  if [ ! -f  $messagefile ] ; then
    echo "Not a file: $messagefile"
    return 1
  fi

  while read addr ; do
    if echo $addr | grep "^#" > /dev/null ; then
      echo "Skipping line: $addr"
    else
      echo "Sending to: $addr"
      sed "s/__RECIPIENT__/$addr/g" $messagefile | sendmail -t
    fi
  done
}

# Do Shell - couldn't come up with a better name ;-)
# Run the command(s) given as argument on every line read on stdin
# Handy when needing to execute the same command on several files
# eg: dosh rm -rf
#  then paste/type in path to remove
dosh(){
  local cmd=$*
  echo "Will run '$cmd' for every line entered"
  echo "Exit with EOF (normally CTRL-D) or CTRL-C"
  while read -p '> ' input ; do
    # As long as $input isn't an empty string
    [ "$input" == "" ] && continue
    echo "<<$cmd $input>>"
    $cmd "$input"
  done
  echo
}


# Renames files to include a date/time stamp
# If the first argument looks like a date format (begins with +), then use that format, otherwise use default
datefile(){
  $perl -w -e'
  use strict;
  use POSIX qw(strftime);
  # By default, using same date format as Android KitKat, because it matches the files from my phone, so sorting by file name looks sensible
  my $datefmt = "%Y-%m-%d %H.%M.%S";

  if ( $ARGV[0] =~ /^\+/ ) {
    $datefmt = shift(@ARGV);
    #$datefmt =~ s/^\+//;
  }

  if ($#ARGV < 0 ) {
    print "Usage: datefile [format] <files>\n";
    print "Format follows stftime\n";
    exit 1;
  }

  print "Using date format: $datefmt\n";

  foreach my $file (@ARGV) {
    if ( -f $file ) {
      # get last modified time of $file
      my $mtime = (stat($file))[9];
      my $datestr = strftime "$datefmt", localtime( $mtime );
      my $newname = "$datestr $file";
      print "mtime ($file): $mtime, datestr: $datestr, new name: $newname\n";
      if ( -f "$newname" ) { warn "File exists: $newname\n" ; next; }
      rename ("$file", "$newname");
    }
  }
  ' $* # end of Perl code
}


# Looks at time stamps of files in the current directory, creating one
# directory per day, and moves the files into the daily directory
# This function is written entirely in Perl
# If the first argument is a date format, beginning with "+",
# use that format, otherwise use default
datedir(){
  $perl -w -e'
  use strict;
  use POSIX qw(strftime);
  my $datefmt = "%Y-%m-%d";

  if ( $ARGV[0] =~ /^\+/ ) {
    $datefmt = shift(@ARGV);
    $datefmt =~ s/^\+//;
  }

  if ($#ARGV < 0 ) {
    print "Usage: datedir [+datefmt] <files>\n";
    exit 1;
  }

  print "Using date format: $datefmt\n";

  foreach my $file (@ARGV) {
    if ( -f $file ) {
      # get last modified time of $file
      my $mtime = (stat($file))[9];
      my $datedir = strftime "$datefmt", localtime( $mtime );
      print "mtime ($file): $mtime, datestamp: $datedir\n";
      # Create date stamped directory if it does not already exist
      if ( ! -d "./$datedir" ) { mkdir ("./$datedir"); }
      # Move file into date based directory
      rename ("$file", "$datedir/$file");
    }
  }
  ' $* # end of Perl code
}


# Generates and prints a random PIN number
# I use this to generate PIN codes for various things
randpin(){
  $perl -w - "$@" <<"ENDRANDPINPERL"
  use strict;
  my $pin_length = 4;
  my $quantity = 1;
  my $pin;
  my $_rand;
  my @usedpins;

  # Can give the number of pins as an argument
  if ( $ARGV[0] ) { $quantity = $ARGV[0]; }
  if ( $ARGV[1] ) { $pin_length = $ARGV[1]; }

  my @chars = split(" ", "0 1 2 3 4 5 6 7 8 9");

  print "Generating $quantity PINs with length $pin_length\n";

  my $max_pins = 9 * (10**($pin_length-1));

  if ($quantity > $max_pins){
    die "You can't generate $quantity unique PINs, starting with 1-9 with $pin_length digits (max: $max_pins)\n";
  }

  # Seed the random number generator
  srand;

  while (scalar @usedpins < $quantity) {
    $pin = "";
    for (my $j=0; $j < $pin_length ; $j++) {
      $_rand = int(rand ($#chars + 1) );
      $pin .= $chars[$_rand];
     }
    # PIN must not have any repeated digits, start with a 0, or be repeated
    unless ( $pin =~ /(.).*\1/ || $pin =~ /^0/ || grep(/$pin/, @usedpins) ) {
        print "$pin\n";
        push(@usedpins, $pin);
    }
    # else { print "Discarding: $pin, generated: " . scalar @usedpins . ", qty: $quantity\n"; }
  }
ENDRANDPINPERL
}

# Generates and prints a random password
# I use this to generate passwords for new users
randpass(){
  perl -w -e'
  use strict;
  my $password_length = 24;
  my $quantity = 1;
  my $password;
  my $_rand;
  my %used_passwords;

  # Can give the number of passwords as an argument
  if ( $ARGV[0] ) { $quantity = $ARGV[0]; }
  if ( $ARGV[1] ) { $password_length = $ARGV[1]; }

  die "Password has to be at least 8 characters long\n" unless $password_length >= 8;


  # Do not include characters that can easily be mistaken (e.g. l/1, 0/O)
  # make lowercase letters more likely by including more of them ;-)
  my @chars = split(" ",
  "a b c d e f g h i j k m n o p q r s t u v w x y z
  a b c d e f g h i j k m n o p q r s t u v w x y z
  A B C D E F G H J K L M N P Q R S T U V W X Y Z
  2 3 4 5 6 7 8 9
  ! £ $ % ^ & * ( ) - _ + = [ ] { } ; : @ # ~ ,
  < . > / ? |
  ");

  # Seed the random number generator
  srand;

  while(keys(%used_passwords) < $quantity ) {
    $password = "";
    for (my $j=0; $j < $password_length ; $j++) {
      $_rand = int(rand ($#chars + 1) );
      $password .= $chars[$_rand];
     }
    # Password must include 2 of each uppercase, lowercase, digit, non-alpha otherwise skip
    # Also must not contain repeated characters (same twice in a row), or more than X non-alpha
    if ( $password =~ /[a-z].*[a-z]/ && $password =~ /[A-Z].*[A-Z]/ && $password =~ /\d.*\d/ && $password =~ /\W.*\W/ && $password !~ /(.).*\1/ && ! $used_passwords{$password} == 1) {
        print "$password\n";
        $used_passwords{$password}=1;
    }
    #else { print "REJECTING: $password\n"; }
  }
  ' $*
}

# rootat - SSH to root @ whatever
rootat(){
  local host=$1
  sssh root@$host
}

# sssh - function that uses screen_ssh, but is more suited to use interactively
sssh(){
  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME [username@]hostname [ ssh flags ]"
    return 1
  fi
  local hostname=$1 ; shift
  local title=$hostname
  # If the title doesn't look like an IP address, then shorten it, by removing everything after the first '.'
  echo $hostname | grep -q -E '[[:digit:]]\.[[:digit:]]' || title=$(echo $hostname | sed 's/\..*//')
  title=$(echo $title | sed 's/..*@//')

  # Run screen_ssh on the hostname, with the name shortened for the screen title
  # pass on any ssh flags as $*
  screen_ssh $hostname $title $*
}


# screen ssh, used by ssh host aliases
# eg: alias foo="screen_ssh foo"
# alias foo="screen_ssh foo.example.com foo"
# If running under screen, the ssh comand will be launched in a new window
# if not, it will just run in the current shell
# if title is set, it will be used as the window title. otherwise,
# the hostname will be used as the title
screen_ssh(){
  if [ -z "$1" ] ; then
    echo "Usage: screen_ssh dest [title [ssh flags]]"
    echo "Optional setting, to enable connection check (in case of changed host key)"
    echo "screen_ssh_test_connection=yes"
    return 1
  fi
  local dest=$1 ; shift
  local host=$(echo $dest | sed 's/.*@//')
  if [ ! -z "$1" ] ; then title=$1 ; shift ; else title=$dest ; fi
  # Any arguments after hostname and title are passed on to ssh
  sshflags="-C -o ServerAliveInterval=30 $*"
  # STY is set by screen if it's running
  if [ -z "$STY" ] ; then
    ssh $sshflags $dest
  else
  # When running SSH in a screen session, you don't get to see the error if the command fails, because the screen will close too fast.
  # So, we do a little bit of error checking/handling
  # To enable this test, set $screen_ssh_test_connection=yes
  # This is useful for VMs that get frequently recreated, meaning that the host key for the same IP address keeps changing
  if [ "$screen_ssh_test_connection" = "yes" ] && ! ssh $dest true ; then
    echo
    echo "Looks like there's a connection problem, maybe a host key issue?"
    echo "WARNING: If you're not expecting this issue, check what's happened before just accepting a new host key"
    echo -n "Would you like to remove the key for $host? (y/N): "
    read _ans
    if [ "$_ans" = "y" ] ; then
  	ssh-keygen -R $host
    else
  	echo "Aborting: ssh $dest"
  	return 1
    fi
  fi
  screen -t $title ssh $sshflags $dest
  fi
}

# Bad name, but rymes with wclock... helper function for wclock
# which can also be used on its own, eg tclock Europe/London
tclock(){
  TZ="$1" date
}

# World clock - prints date for some time zones that I tend to care about
wclock(){
  echo -n "California: " ; tclock America/Los_Angeles
  echo -n "New York:   " ; tclock America/New_York
  echo -n "UTC:        " ; tclock UTC
  echo -n "London:     " ; tclock Europe/London
  echo -n "Stockholm:  " ; tclock Europe/Stockholm
  # echo -n "Calcutta:   " ; tclock Asia/Calcutta
  # echo -n "Tokyo:      " ; tclock Asia/Tokyo
  echo -n "Melbourne   " ; tclock Australia/Melbourne
  echo -n "Auckland:   " ; tclock Pacific/Auckland
}

# Nano clock - prints the time, including nano seconds, at set interval
nanoclock(){
  interval=100000 # Defaults to 10th of a second
  [ ! -z "$1" ] && interval=$1
  while usleep $interval ; do printf "\r%s %s" $(date '+%H:%M:%S %N') ; done
}

# Calculate something by echo'ing it to bc -l
# using decimals, so 7/2 = 2.33... rather than 7/2 = 2
# See man page for bc for more info
calc(){
  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME expression"
    echo "Where expression is anything that bc will understand"
    return 1
  fi
  echo "$*" | bc -l
}

# Check spelling of a word (or bunch of words) passed as argument
# quicker than "echo word | spell" for checking one word
sp(){
  echo $* | spell
}

# Look things up in Lexin
# To translate from English to Swedish - use "lexin :word"
# http://lexin.nada.kth.se/faq.shtml
lexin(){
  if [ -z "$1" ] ; then
    echo "Usage example: $FUNCNAME [:]word"
    echo "Prepending word with a colon looks up an English word"
    return 1
  fi
  wwwdump "https://lexikon.nada.kth.se/cgi-bin/sve-eng?${*}" | $PAGER
}

# Look up word in wikipedia
wp(){
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME word" ; return 1 ; fi
  wwwdump "https://en.wikipedia.org/wiki/${*}" | $PAGER
}
# Look up word in wictionary
wn(){
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME word" ; return 1 ; fi
  wwwdump "https://en.wiktionary.org/wiki/${*}" | $PAGER
}

# Replace CR with LF
replacecr(){
  if [ -z "$1" ] ; then echo "Usage: replacecr <file>" ; return 1 ; fi
  local file=$1
  # backup
  mv -i $file $file.old || return 1
  tr -s '\015' '\012' < $file.old > $file
  echo "Done. Backed up to $file.old"
}

# Strip out Carriage Return (CR) from a file
stripcr(){
  if [ -z "$1" ] ; then echo "Usage: stripcr <file>" ; return 1 ; fi
  local file=$1
  # backup
  mv -i $file $file.old || return 1
  tr -d '\015' < $file.old > $file
  echo "Done. Backed up to $file.old"
}

# Grep, using Perl regular expressions.
# TODO: Use this more often ;-)
pgrep(){
  if [ $# -lt 1 -o "$1" == "-h" ] ; then
    echo "Usage: pgrep [-v] /regex/ <files>"
    echo "  -v  Print all lines except those that contain the pattern."
    echo
    echo "Example: pgrep /foo/ /tmp/bar"
    echo
    return 1
   fi

  # What to test for, using either "print if" or "print unless" in Perl
  # pgrep -v (equivalent to grep -v) uses "unless"
  local test=if
  if [ "$1" == "-v" ] ; then
    test=unless
    shift
  fi

  local expr=$1
  shift
  perl -n -e "print $test $expr ; " $*
}

# Handy functions for setting owner, group and mode
chmog(){
    if [ $# -ne 4 ] ; then
        echo "Usage: chmog mode owner group file"
        return 1
    else
        chmod $1 $4
        chown $2 $4
        chgrp $3 $4
    fi
}

chog (){
    if [ $# -ne 3 ]; then
        echo "Usage: chog owner group file"
        return 1
    else
        chown $1 $3
        chgrp $2 $3
    fi
}

cpdir(){
  # use tar to copy a directory
  # TODO: usage
  local fromdir=$1
  local todir=$2
  (cd $fromdir ; tar cf - . ) | ( cd $todir ; tar xpf - )
}

cddb(){
  # TODO: Usage, name
  mp3cddb *.mp3
  echo "Hit enter to update, ctrl-c to cancel"
  read foo
  mp3cddbtag cddbinfo.txt
  rm cddbinfo.txt
}

# mkisofs's a directory and cdrecord's it
# this was written for an OpenBSD desktop machine, should just need to change cdrdev to work on any machine with mkisofs and cdrecord
mkcdrom(){
  # TODO: Usage
  local cdrdev=/dev/rcd1c
  local cdrspeed=16
  local defisofile=/space/cdtemp/cdrtemp.iso
  local defvolid=`date "+%Y%m%d_%H%M%S"`

  local volid="$defvolid"
  local isofile="$defisofile"
  local dir=$1
  local cmd

  [ ! -z "$2" ] && volid="$2"

  if [ -z $dir ] ; then
    echo "Usage: mkcd directory [Volume ID]"
    return 1
  fi

  echo "dir: $dir, volid: $volid"

  cmd="mkisofs -l -L -V \"$volid\" -m $isofile -o $isofile $dir"
  echo "cmd: $cmd"
  $cmd

  cmd="cdrecord dev=$cdrdev speed=$cdrspeed $isofile"
  echo "cmd: $cmd"
  $cmd

}

nullroute(){
  sed "s/\(.*\)/ip route \1 255.255.255.255 Null0/"
}

dlget(){
  curl $dlbase/$1
}

sndvol(){
# sets the sound volume using mixerctl under OpenBSD
  local currentvol
  local delta
  case "$1" in
  mute)
    mixerctl -nw outputs.master.mute=on
    echo "Muting sound"
    return 0
  ;;
  *h*)
    echo "Usage: sndvol N | +N | -N | mute"
    return 1
  ;;
  +*|-*)
    local delta=$1
    #echo "Volume change: $delta"
    currentvol=`mixerctl -n outputs.master | cut -f1 -d ","`
    let newvol=${currentvol}+${delta}
    # echo "Delta is $delta, $currentvol -> $newvol"
  ;;
  ?*)
    #echo "New volume: $newvol"
    newvol=$1
  ;;
  *)
    echo "Current volume: `mixerctl -n outputs.master`"
    return 0
  ;;
  esac

  echo "New volume: $newvol"
  mixerctl -w outputs.master=$newvol
  mixerctl -nw outputs.master.mute=off

}

# Rename files using a Perl regular expression
# this used to be done entirely in Perl, but make it work
# on several files, using wildcards, etc, it was easier
# to do part of it as a shell script due to issues with spaces in filenames
perlmv(){
  local file
  local dry

  if [ "$1" = "-d" ] ; then dry=yes ; echo "Dry run" ; shift ; fi

  # need at least two arguments - RE and 1 file name
  if [ $# -lt 2 ] ; then
    echo "Usage: perlmv [-d] perlexpr files"
    echo "       -d for a dry run\n"
    return 1
  fi

  # The regular expression to be applied to the file name
  local re=$1
  shift

  # iterate for each file specified
  while [ $# -gt 0 ] ; do
    file=$1
    shift
    perl -e '
      use strict;
      my $regex = shift(@ARGV);
      $_        = shift(@ARGV);
      my $dry   = shift(@ARGV);
      my $was=$_;

      # print "Using regex: ($regex)\n";
      # print "Filename: $_\n";
      eval $regex;
      # print "Filename after eval: $_\n";
      die $@ if $@;
      unless ( $was eq $_ ) {
        print "Renaming: <<<$was<<< to >>>$_>>>\n";
        rename ("$was", "$_") unless ( $dry eq "yes" );
      }
    ' "$re" "$file" "$dry"
  done
} # end perlmv

termsize(){
  echo "COLUMNS:	$COLUMNS"
  echo "LINES:		$LINES"
}

sectime(){
  # Print the given number of seconds in minutes, hours and days
  local secs
  local mins
  local hours
  local days
  secs=$1
  let mins=$secs/60
  let hours=$secs/3600
  let days=$secs/86400
  let weeks=$days/7
  let years=$days/365
  echo "$secs secs"
  echo "$mins mins"
  echo "$hours hours"
  echo "$days days"
  echo "$weeks weeks"
  echo "$years years"
}

# "s// in file", sinfile, do a replace of text in one or several files
sinfile(){
  if [ $# -lt 2 ] ; then echo "Usage: sinfile perlcode files" ; return 1 ; fi
  perlcmd=$1 ; shift
  perl -i.old -p -e "$perlcmd" $*
}

# search the OpenBSD ports, locally
psearch(){
  local oldpwd=`pwd`
  if ! cd /usr/ports ; then echo "You haven't got /usr/ports" ; return 1 ; fi
  make search key=$@
  cd $oldpwd
}

# Process stuff
fullps(){
  if [ $DCMF_OS = "linux" ]; then
    ps -e -o 'uid user pid ppid pcpu pmem vsz rssize tty stat start time command'
  else
    ps auxwww
  fi
}
# An old version, as an alias
pa(){
  fullps
}

# Grep for processes, include headers
psgrep(){
  if [ $# -lt 1 ] ; then
    echo "Usage: psgrep pattern" ; return 1
  fi
  local psoutput="$(fullps)"
  # First, produce a header line
  echo "$psoutput" | head -1
  # Then produce the output
  echo "$psoutput" | grep $1 | grep -v grep
}

killall(){
  if [ $# -lt 1 ] ; then
    echo "Usage: killall -SIG procname" ; return 1
  fi

  local pid
  local sig
  local pname

  if [ $# -eq 1 ] ; then
    sig="-TERM" ; pname="$1"
  else
    sig=$1 ; pname="$2"
  fi

  for pid in `ps ax | grep $pname | grep -v grep | awk '{print $1}'` ; do
    echo "Sending $sig to $pid"
    kill $sig $pid
  done
}

keepalive(){
  # Used as a lame keepalive on ssh connections
  # might sometimes leave an annoying "." on the screen
  echo "Trying to keep connection alive"
  local sleeptime=60
  if [ ! -z $1 ] ; then sleeptime=$1 ; fi
  while sleep $sleeptime ; do printf "." ; printf "\\b" ; done
}

# The classic symmetric key encryption example ;-)
# Example: echo "Gur ohgyre qvq vg" | rot13
rot13(){
  if [ $# = 0 ] ; then
    # If there's no argument, read from stdin
    tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
  else
    # Assume that the first argument was a file, and apply to that
    tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
  fi
}

lcmv(){
  # move filenames to lowercase
  local filename
  local nf
  local newname
  for file ; do
    filename=${file##*/}
    case "$filename" in
    */*) dirname==${file%/*} ;;
    *) dirname=.;;
    esac
    nf=$(echo $filename | tr A-Z a-z)
    newname="${dirname}/${nf}"
    if [ "$nf" != "$filename" ]; then
      mv "$file" "$newname"
      echo "lowercase: $file --> $newname"
    else
      echo "lowercase: $file not changed."
    fi
  done
}

swapfiles(){
  # swap 2 filenames around
  local TMPFILE=tmp.$$
  mv -i $1 $TMPFILE
  mv -i $2 $1
  mv -i $TMPFILE $2
}


# Find a file with a pattern in name:
ff(){ find . -name '*'$*'*' -ls ; }
# Same, case insensitive
ffi(){ find . -iname '*'$*'*' -ls ; }
# Find a file with pattern $1 in name and Execute $2 on it:
fe(){ find . -name '*'$1'*' -exec $2 {} \; ; }
# Same, case insensitive
fei(){ find . -iname '*'$1'*' -exec $2 {} \; ; }
fstr(){
   # find pattern in a set of files and highlight them:
  if [ "$#" -gt 2 ]; then
    echo "Usage: fstr \"pattern\" [files] "
    return;
  fi
  SMSO=$(tput smso)
  RMSO=$(tput rmso)
  find . -type f -name "${2:-*}" -print | xargs grep -sin "$1" | \
    sed "s/$1/$SMSO$1$RMSO/gI"
}

repeatcmd(){
  # repeat n times command
  if [ $# -lt 2 ] ; then echo "Usage: repeat N command" ; return 1 ; fi
  local i max
  max=$1; shift;
  i=1
  while ([ $i -le $max ]); do
   eval "$@";
   let i=$i+1
  done
}

printn(){
  # print text n times, including the number n
  if [ $# -lt 2 ] ; then
     echo "Usage: printn x y[text1] [text2]" ; return 1
  fi
  local x=$1
  local y=$2
  local text1=$3
  local text2=$4
  perl -e "for (\$i=$x;\$i<=$y;\$i++) { print \"${text1}\${i}${text2}\n\" }"
}



# check an address against dbl.dotcomfy.net, or other zone
dblcheck(){
  local address=$1
  local domain=$2
  if [ -z $dom ] ; then domain=dbl.dotcomfy.net ; fi
  revlookup $address $domain
}

revlookup(){
  if [ $# -lt 1 ]; then
    echo "Usage: revlookup address [domain]"
    echo "Reverses address and looks for PTR, A and TXT record in domain"
    echo "Example: revlookup 127.0.0.1 blocklist.example.org"
    echo "         revlookup host.example.com in-addr.arpa"
    echo "If domain isn't given, it defaults to in-addr.arpa"
  fi

  local address=$1
  local domain=$2
  if [ -z $domain ] ; then domain="in-addr.arpa" ; fi
  if echo $address | egrep "[a-zA-Z]" > /dev/null ; then
    echo -n "$address looks like a DNS hostname, resolving: "
    address=`host $address | awk '{ print $4 }'`
    echo "$address"
  fi

  local reversed=`echo $address | awk -F'.' '{ print $4 "." $3 "." $2 "." $1 }'`
  local lookup="${reversed}.$domain"
  echo "Will look up: $lookup"
  printf "A:   " ; host -t A $lookup
  echo
  printf "TXT: " ; host -t TXT $lookup
  echo
  printf "PTR: " ; host -t PTR $lookup
  echo
}


# Find which external IP I'm using (or at least for WWW)
myip(){
  local url="$toolsbase/myip"
  if [ $# -gt 0 ] ; then url="${url}$*" ; fi
  curl -s $url
}
# nmap myself from toolsbase
scanme(){
  echo "NOT SUPPORTED" ; return 1
  local url="$toolsbase/scan"
  if [ $# -gt 0 ] ; then url="${url}$*" ; fi
  curl -s $url
}

# ping myself from toolsbase
pingme(){
  local url="$toolsbase/ping"
  curl -s $url
}

# trace myself from toolsbase
traceme(){
  local url="$toolsbase/trace"
  curl -s $url
}

# connect to specified routeserver / looking glass
# mostly to keep a list of such handy...
alias lookingglass=routeserver
routeserver(){
  local server
  case $1 in
    list)
      echo "Figure it out for yourself:"
      type routeserver | grep -v grep | grep -B1 "server=" | grep -v "\-\-"
      return
    ;;
    att)
      server=route-server.ip.att.net
    ;;
    cerf)
      server=route-server.cerf.net
    ;;
    exodus)
      server=route-server.exodus.net
    ;;
    exodusap)
      server=route-server-ap.exodus.net
    ;;
    exoduseu)
      server=route-server-eu.exodus.net
    ;;
    colt)
      server=route-server.colt.net
    ;;
    *)
      echo "Usage: routeserver servername | list"
      echo "       list gives a list of route-servers"
      return
    ;;
  esac

  xtitle "routeserver: $USER@$server"
  echo "Server set to $server"
  command telnet $server
  xbacktitle
}



# Builds an HTML image index page
# Takes a list of files as arguments
mkimgindex(){
  local img
  local body
  if [ -z "$1" ] ; then
    echo "Usage: mkimgindex [-b] [-i] files"
    echo "Builds an HTML image index page"
    echo "	-b	Create an HTML body around the images"
    echo "	-i	Include <img> tag for each image"
    echo "Example: mkimgindex -i *.jpg"
    return 1
  fi
  img=0
  body=0
  if [ $1 = "-b" ] ; then
    body=1
    shift
  fi
  if [ $1 = "-i" ] ; then
    img=1
    shift
  fi

  if [ $body -eq 1 ] ; then
  cat <<EOF
<html>
<head>
<title>Image index</title>
</head>

<body>
<h1>Image index</h1>

EOF
  fi

  for file in $* ; do
    if [ $img -eq 1 ] ; then
      echo "<img src=\"$file\" alt=\"$file\"> <br/>"
    fi
    echo "<a href=\"$file\">$file</a> <br/>"
    echo
  done
  if [ $body -eq 1 ] ; then
    echo
    echo "</body>"
    echo "</html>"
  fi
} # end mkimgindex

# used by aestar()
getpass(){
    local _PROMPT="$1"
    local _PASS

    stty -echo
    trap 'stty echo; return 1' INT TERM
    printf "%s" "$_PROMPT" > /dev/tty
    read _PASS
    trap '' INT TERM
    stty echo
    echo > /dev/tty
    echo "$_PASS"
}

# tar and encrypt on the fly
# from aestar.sh, taken from somewhere
aestar(){

    local TARFLAGS
    local FILE
    local PASS
    local PASS2

    if [ $# -lt 2 ]; then
        echo "Usage: `basename $0` tarflags file ..." >&2 && return 1
    fi

    TARFLAGS=$1
    shift

    case $TARFLAGS in
        *c*)
    	FILE=$1
    	shift
    	PROMPT="Password for $(basename $FILE)"
    	PASS=`getpass "$PROMPT:"`
    	PASS2=`getpass "$PROMPT (again):"`
    	if [ "$PASS" != "$PASS2" ]; then
    	    echo "Passwords mismatched" >&2 && return 1
    	fi
    	PASSFILE=`mktemp`
    	echo "$PASS" > $PASSFILE
    	trap 'rm -f $PASSFILE; return 1' INT TERM
    	tar $TARFLAGS - $* | openssl aes-256-cbc -e -kfile $PASSFILE -out $FILE
    	rm $PASSFILE
    	;;
        *t*|*x*)
    	FILE=$1
    	shift
    	if [ -r $FILE ]; then
    	getpass "Password for `basename $FILE`:" | \
    	    openssl aes-256-cbc -d -pass stdin -in $FILE | tar $TARFLAGS - $*
        else
    	echo "Can't open $1" >&2 && return 1
        fi
    	;;
        *)
    	echo "Unrecognized tar flags '$TARFLAGS'" >&2 && return 1
    	;;
    esac

    return 0
} # aestar

aescat(){
  # Similar to aeastar, but simply used to en/decrypt a single file
  # Requires openssl to be installed
  if [ $# -ne 1 ] ; then
    echo "Usage: aescat <file>"
    echo "Will either en- or decrypt file, and print the results to STDOUT"
    return 1
  fi

  # variables used only in this function
  local output
  local aesinfile=$1
  # Check that file exists
  if [ ! -f $aesinfile ] ; then echo "File doesn't exist: $aesinfile" ; return 1 ; fi

  # The first 6 characters an encrypted file are the word "Salted"
  # either encrypt or decrypt, based on this
  if dd bs=1 count=6 if=$aesinfile 2>/dev/null | grep "Salted" > /dev/null ; then
    # It's an encrypted file - let's decrypt it
    # openssl will give garbage output if the password is incorrect
    # Check for success, and only give output if it's successfull
    if output=`openssl aes-256-cbc -d -in $aesinfile` ; then
      echo "$output"
      # clear the output variable
      output=""
    else
      echo "Incorrect password"
    fi
  else
    openssl aes-256-cbc -e -in $aesinfile
  fi

}

makerun(){
    local outfile
    outfile=`echo $1 | sed 's/\.c$//'`
    CFLAGS=-Wall make $outfile
    ./$outfile
}

# Lists Sun disk names on the two different forms:
# cXtXdX - sdX
# useful when looking at output from iostat -x
sdlist(){
    local tmp1=${TMPDIR:-/tmp}/sdlist_1.$$
    local tmp2=${TMPDIR:-/tmp}/sdlist_2.$$
    local oldcwd=`pwd`
    cd /dev/rdsk
    /usr/bin/ls -l *s0 \
     | tee $tmp1 \
     | awk '{print "/usr/bin/ls -l "$11}' \
     | sh \
     | awk '{print "sd" substr($0,38,4)/8}' > $tmp2
    awk '{print substr($9,1,6)}' $tmp1 \
     | paste - $tmp2
    rm $tmp1 $tmp2
    cd $oldpwd
}

### Functions that use xtitle() to set the title of xterm or ssh client
### before running the specific command
###
screen(){
  xtitle "$HOSTNAME: $USER (screen)"
  command screen $@
  xbacktitle
}

pine(){
  xtitle "PINE - ($USER@$HOSTNAME)"
  if [ "$(type -t alpine)" = "file" ] ; then
    pine=alpine
  else
    pine=pine
  fi
  command $pine -i $*
  xbacktitle
}


# Change into the directory of the last file we did something to
cdlast(){
  local lastfile=$_
  local lastdir=$(dirname $lastfile)
  echo "Changing to dir of $lastfile: $lastdir"
  cd $lastdir
}

cdup(){
  popd && xtitle $USER@$HOSTNAME:$PWD
}
# Short form, just use a single dash as command
alias -- -=cdup
alias -- --="-&&-"
alias -- ---="-&&-&&-"

su(){
  xtitle "root@$HOSTNAME (su from $USER)"
  command su "$@"
  xbacktitle
}

# In case there's an alias, get rid of it
unalias vi >/dev/null 2>&1
vi(){
  local vicmd=vi
  if [ -f ~/.vim/vimrc ] && type -P vim>/dev/null ; then
    vicmd="vim -u ~/.vim/vimrc"
  fi

  if [ -n "$1" ]; then
    fname=$(basename "${@: -1}")
    set_screen_title "vi:${fname::12}"
  else
    set_screen_title "vi"
  fi


  xtitle "vi $@ - ($USER@$HOSTNAME)";
  command $vicmd "$@";
  # This is now moot, since we set titles in PROMPT_COMMANDS, but leaving it here for reference in case I change my mind
  # xbacktitle
  # set_screen_title "$SCREEN_TITLE"
  # Reset background colour, since in some terminals, the terminal will otherwise stay shaded after vi exits
  tput sgr0
}

reset_term_titles(){
  xbacktitle
  set_screen_title "$(dirs | awk '{ print $1 }')"
}

make(){
  xtitle "$USER@$HOSTNAME: make $@ in $PWD"
  command make $@
  xbacktitle
}

rfc(){
  xtitle "$USER@$HOSTNAME: reading RFC $@"
  curl -s http://${1}.rfc.dotcomfy.net | $PAGER
  xbacktitle
}

man(){
  xtitle "$USER@$HOSTNAME: reading the manual for $@"
  command man $@
  xbacktitle
}

top(){
  xtitle "Processes on $HOSTNAME"
  command $top $@
  xbacktitle
}


### A bunch of old shell scripts that used to be in /root/bin
### on a couple of OpenBSD boxes. Turned into functions.

# m4mc - used to update sendmail.cf
m4mc(){
    local cfdir=/etc/mail
    local mcfile=$cfdir/$(hostname -s).mc
    local cffile=$cfdir/sendmail.cf
    if [ -f $mcfile ] ; then
        echo "Creating new cf file ($cffile) from $mcfile"
        sudo sh -c "cd $cfdir ; m4 $mcfile > $cffile"
        ls -l $cffile
    else
        echo "mc file doesn't exist: $mcfile"
        return 1
    fi
} # end of m4mc()

viregex(){
  local _configfile=/etc/mail/milter-regex.conf
  sudoeditor $_configfile || return
  if sudo milter-regex -d -t -c $_configfile ; then
    echo "Config seems to be OK, restarting daemon"
    sudo service milter-regex restart
  else
    echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    echo "Problem with milter-regex config file? Please check it over"
    echo "$_configfile"
    echo "Also see /var/log/messages for details"
    echo ""
    echo "Worth noting, for example, that you can't escape slashes. Instead, use a different regex delimiter"
    echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  fi
}

vigreylist(){
  sudoeditor /etc/mail/greylist.conf && sudo service milter-greylist restart && echo && echo "Tailing log file"  && sudo tail -f /var/log/maillog | grep greylist
}

viaccess(){
  local mapfile=/etc/mail/access
  sudoeditor $mapfile && sudo makemap -v hash $mapfile <$mapfile > /dev/null
  ls -l $mapfile*
}

vivirt(){
  local mapfile=/etc/mail/virtusertable
  sudoeditor $mapfile && echo "Updating map" && sudo makemap -v hash $mapfile < $mapfile > /dev/null
}

vialiases(){
  sudoeditor /etc/mail/aliases && echo "Updating map" && sudo newaliases
}

# End of root/sudo specific functions



### Functions related to the editing, fetching, updating
### etc of .bashrc
### Some of these are also used as general supporting functions

# Print general version/age info
shrcinfo(){
  echo "Age:             `shrc_check_age` days"
  echo "Update after:    $shrc_max_age days"
  echo "Sections:"
  grep "^##### " $shrc_home | sed 's/^##### / - /'
}

# Updates the base .bashrc (or whatever it's stored as locally)
shrcupd(){
  local remote_version="$(curl --max-time 5 -S -s "$shrc_url&c=version")"
  if [ $? -gt 0 -o "$remote_version" = "" ] ; then warn "Update check failed" ; return ; fi
  if [ "$DCMF_BASHRC_VERSION" = "$remote_version" -a ! "$1" = "force" ]; then
    echo "This is the latest version: $DCMF_BASHRC_VERSION"
    # Updating age file, to delay next check
    date '+%s' > $shrc_age_file
  else
    echo "New version detected or update forced: $remote_version"
    updatefile $shrc_home $shrc_url
    echo "Updated to: $DCMF_BASHRC_VERSION"
  fi
}

# Updates a file from the web repository
# Two arguments:
#  - the local path to the file to update
#  - the URI of the file to get
updatefile(){
  local file_home=$1
  [ -f $file_home ] || touch $file_home
  local file_www=$2
  if [ ! -w $file_home ] ; then
    echo "$file_home is not writeable, you probably don't want to do that"
    echo "I'll just . it for you"
    . $file_home
    return 1
  fi
  curl  -sL -o $updatefile_tmp $file_www
  if [ $? -ne 0 ] ; then
    echo "cURL failed retrieving file, will try wget"
    wget  -q -O $updatefile_tmp $file_www
    if [ $? -ne 0 ] ; then
      echo "Failed retrieving file, will try lynx"
      lynx -dump -source $file_www > $updatefile_tmp
      if [ $? -ne 0 ] ; then
        echo "Doh, I couldn't get the new bashrc, giving up"
        rm -f $updatefile_tmp
        return 1
      fi
    fi
  fi
  if diff $file_home $updatefile_tmp ; then
    echo "You already have the most recent version in $file_home"
    rm -f $updatefile_tmp
  else
    if askyesno "Update $file_home to newest version, according to diff?" ; then
      mv $updatefile_tmp $file_home
      echo "Updated to most recent version."
    else
      echo "OK, will update later"
      rm -f $updatefile_tmp
    fi
  fi
  # If it's the bashrc we've updated, then register it
  if [ "$file_home" = "$shrc_home" ] ; then
    date '+%s' > $shrc_age_file
  fi
  # Source the newly updated file, unless configured not to
  [ -z "$no_source_after_update" ] && . $file_home
  return 0
}

# Check a file out from RCS, edit, show diff, check back in
# Was used by more things way back on the day, but mostly got dropped
editfile(){
  if [ "$1" == "" ] ; then
    echo "Usage: editfile <file>"
    return 1
  fi
  file=$1
  if ! co -l $file ; then echo "Can't co $file" ; return 1 ; fi
  vi $file
  rcsdiff $file | $PAGER
  if ! ci -u $file ; then echo "Can't ci $file" ; return 1 ; fi
}

testmail(){
  if [ -z "$testmailcount" ] ; then testmailcount=0; fi
  let testmailcount=$testmailcount+1
  (hostname;date;echo "Shell PID: $$") | mail -s "Test $$/$testmailcount from $(hostname) on $(date)" $1
  echo "Sent test $$/$testmailcount"
}

### Quite large Perl snipplets, wrapped as shell functions
### These are best off stuffed away at the bottom of the .bashrc
###

smtpclient(){
$perl - "$@" <<"ENDOFSMTPCLIENTPERL"
#!/usr/bin/perl -w
# Id: smtpclient.pl,v 1.10 2009/05/26 11:27:50 linus Exp
# An SMTP client in Perl
my $version = 'Revision: 1.10';
my $me = 'smtpclient.pl';

# Perl modules used.
use IO::Socket;                    # For the socket routines
use Getopt::Std;                   # For retrieving command line options
use strict;

# Predeclaration
my $sock;                          # Socket file handle
my $response;                      # Response from remote SMTP server
my @mailbody;                      # Array of lines for body (in DATA)
my $heloname;                      # Name I use in HELO
my %opts;                          # Command line options

# Get command-line options.
getopts('bhH:p:P:s:U:', \%opts);

my $port = $opts{'p'} || 25;                     # Default SMTP port

# Need at least 3 arguments, server, from, to
if ( $#ARGV <2 ) { &usage; }

my $server = shift();
my $from = shift();
my $to = shift();

print "Running $me, server: $server, from: $from, to: $to\n";

# Addresses used for MAIL and RCPT commands
my $mailfrom = "$from";
my $rcptto   = "$to";
# If the addresses passed in as arguments contain a full name, then use just the address (within angle brackets)
if ( $mailfrom =~ /<(.+)>/ ) { $mailfrom = $1 };
if ( $rcptto   =~ /<(.+)>/ ) { $rcptto   = $1 };
# Wrap from and to for headers, if they are just bare addresses
unless ( $from =~ /<(.+)>/ ) { $from = "<$from>" };
unless ( $to   =~ /<(.+)>/ ) { $to   = "<$to>"   };

# Constants:
my $CRLF       = "\015\012";

my $date = localtime();

my %headers = (
    'From'         => "$from",
    'To'           => "$to",
    'X-Mailer'     => "$me ($version)",
    'Date'         => "$date GMT",
    'Message-ID'   => "<$me." . time() . ".$from>",
    'Content-Type' => "text/plain; charset=us-ascii",
);

# Do we need help or version info?
if ($opts{h}){&usage}

my $maildesc = "Test from [$from] to [$to] via $server on $date";
$headers{'Subject'} = $opts{s} || $maildesc;
chomp ( $heloname = $opts{H} || `hostname` || "foo" );

if ( $opts{b} ) {
    # Why is this? Not sure, but I also haven't needed this for a million years, so never mind.
    warn "\n\nREADING FROM STDIN DOESN'T WORK IN THE BASHRC VERSION OF SMTPCLIENT\n\n";
    # print "Enter mail, end with EOF (CTRL-D)\n";
    # @mailbody = <STDIN>;
    # print "\nOk, full mail recieved, will now try to send it\n\n";
}
else {
    $mailbody[0] = $maildesc;
}

STDOUT->autoflush(1);
print "Connecting to $server:$port...\n";
unless ($sock = IO::Socket::INET->new(
    Proto=>"tcp",
    PeerAddr=>"$server",
    PeerPort=>"$port",
    Reuse=>"1",
    Timeout=>"10")){
    die ("Couldn't connect to $server:$port ($!)\n")
}

$sock->autoflush(1);
$response = &get_resp($sock);
print_sock ($sock, "HELO $heloname$CRLF");
$response = &get_resp($sock);
if ( $opts{U} ) {
  use MIME::Base64;
  print_sock ($sock, "AUTH LOGIN$CRLF");
  $response = &get_resp($sock);
  print "--- User: $opts{U} " . encode_base64($opts{U});
  print_sock ($sock, encode_base64($opts{U}));
  $response = &get_resp($sock);
  print "--- Pass: $opts{P} " . encode_base64($opts{P});
  print_sock ($sock, encode_base64($opts{P}));
  $response = &get_resp($sock);
}
print_sock ($sock, "MAIL FROM: <$mailfrom>$CRLF");
$response = &get_resp($sock);
print_sock ($sock, "RCPT TO: <$rcptto>$CRLF");
$response = &get_resp($sock);
print_sock ($sock, "DATA$CRLF");
$response = &get_resp($sock);
unless ( $response =~ /354/ ) {
    print STDERR "$server doesn't want to talk to us. Giving up\n";
    exit 1;
}
while ((my $key,my $value) = each %headers) {
    print_sock ($sock, "$key: $value$CRLF");
}
print_sock ($sock, "$CRLF");
while ( my $line = shift (@mailbody) ) {
    chomp ($line);
    print_sock ($sock, "${line}${CRLF}");
}
print_sock ($sock, "$CRLF.$CRLF");
$response = &get_resp($sock);

exit(0);

### Sub routines

# Get response, print it on stdout
sub get_resp {
    my $sock = shift();
    $response = "";
    my $tmpresponse;
    # Handling multi-line responses
    while ( $tmpresponse = <$sock> ) {
      print "<<< $tmpresponse";
      $response .= $tmpresponse;
      # If response is a set of digits followed by a dash, it means that there are more lines
      last unless $tmpresponse =~ /^\d+-/;
    }
    return "$response";
}

# Print on socket and locally
sub print_sock {
    my $fh = shift();
    my $string = shift();
    print $fh "$string";
    # Remove CRLF at end of string
    $string =~ s/$CRLF$//;
    # Split string into two lines if it still contains a CRLF
    $string =~ s/$CRLF/\n>>> /;
    # Print string, with leading ">>>"
    print ">>> $string\n";
}

# Print usage information and exit.
sub usage {
    print <<ENDUSAGE;
Usage: $0 [options] <server> <from> <to>

Sends an email to the list of recipients, from the command line.
If -s is not used, subject will be "Test on [date]"
Options:
-b           Lets you specify a mail body (read from STDIN)
-h           Prints this help screen
-H <name>    Sets the name used in HELO
-p <port>    Sets a different SMTP port
-P <passwd>  Password for SMTP AUTH LOGIN
-s <subject> Specifies the subject line.
-U <user>    Username for SMTP AUTH LOGIN

ENDUSAGE
    exit(0);
}# usage
ENDOFSMTPCLIENTPERL
} # end of smtpclient() shell function

# Disk usage related stuff
alias sdu="du -sk * | sort -n"

# I got fed up with all of the nonsense file systems showing up in modern Linux systems (or at least Ubuntu)
dfh(){
  df -T -h | grep -v ^tmpfs | grep -v '^/dev/loop.*/snap/' | grep -v ^udev.*/dev
}

# dfk.pl - Some Perl script that I found years ago, that formats output in a similar way to df -k
# Was this something that I used on Suns, because they couldn't format things properly for modern (large) drives?
# Original by Brian Peasland
dfk(){
$perl - "$@" <<"ENDOFDFKPERL"
@vol_list = ();               # Array to hold list of volumes
@head_list = qw(Mountpoint Kbytes Used Avail %); # Array to hold header information

#Set up lengths of columns and format mask for output
#If the column needs more room (for instance, you just added a 1TB volume), then
#just increase the variable below and all formatting will hold.
$vol_len = 24;
$byte_len = 16;
$cap_len = 4;
$fs_len = 0;
#All output uses this format mask. This makes life nice and formatted for
#better readability.
$format_mask = "%-".$vol_len."s %".$byte_len."s  %".$byte_len."s  %".$byte_len."s %"
                .$cap_len."s %-".$fs_len."s\n";

#
# Get output from "df -k" command
#

$loop_ctr = 0;
foreach $_ (`df -k | grep -v /dev/loop.*/snap/ | grep -v ^tmpfs | grep -v ^udev.*/dev`) {
   $loop_ctr = $loop_ctr+1;
   #Skip the first line of header information
   if ($loop_ctr > 1) {
      #parse out fields from input stream
      ($filesystem,$kbytes,$used,$avail,$capacity,$volume) = split (/ +/,$_);
      chomp $volume;
      #add volume to list of volumes
      @vol_list = (@vol_list, $volume);
      #add information to appropriate hashes
      #$fs_hash{$volume} = $filesystem;
      $kb_hash{$volume} = comma_int($kbytes);   #Change output to numbers with commas
      $used_hash{$volume} = comma_int($used);   #Change output to numbers with commas
      $avail_hash{$volume} = comma_int($avail); #Change output to numbers with commas
      $cap_hash{$volume} = $capacity;
      } #if
   } #foreach

#
# Sort the list of volumes
#
@vol_list = sort(@vol_list);

#
# Print output
#
printf "$format_mask",@head_list;
printf "$format_mask","-" x $vol_len,"-" x $byte_len,"-" x $byte_len,
                      "-" x $byte_len,"-" x $cap_len;
foreach $volume (@vol_list) {
   printf "$format_mask",$volume,$kb_hash{$volume},$used_hash{$volume},
                             $avail_hash{$volume},$cap_hash{$volume};
   } #foreach

#
# Subroutines
#
sub comma_int  {
   #
   # Subroutine: comma_int
   #    Purpose: To change a number values into a string
   #             with commas seperating groups of three
   #             numbers. For instance, if the input is
   #             '123456789' then the output will be
   #             '123,456,789'.
   #

   $in_string = $_[0];    #get number passed to subroutine
   $loop_count = 0;       #loop counter
   $out_string = "";      #output string will be built and returned to caller

   while( $in_string ne "" ) {    #repeat until no more chars to process
      $loop_count++;
      #Insert comma every third character
      if ( $loop_count%3 eq 1 && $loop_count ne 1 ) {
         $out_string = "," . $out_string;
         } #if
      #add last char to output and remove from input
      $out_string = chop($in_string) . $out_string;
   } #while
   return $out_string;
} #comma_int
ENDOFDFKPERL
} # END OF dfk() FUNCTION

ipcalc(){
$perl - "$@" <<"ENDOFIPCALCPERL"
# Originally from NetBSD ports tree back in 2021
# Stripped out all HTML rubbish -- Linus
use strict;

my $version = '0.34 6/19/2001';
my $private = "(Private Internet RFC 1918)";

my @privmin = qw (10.0.0.0        172.16.0.0      192.168.0.0);
my @privmax = qw (10.255.255.255  172.31.255.255  192.168.255.255);
my @class   = qw (0 8 16 24 4 5 5);

my $allhosts;
my $mark_newbits = 0;
my $print_bits = 1;
my $print_only_class = 0;

my $qcolor = "\033[34m"; # dotted quads, blue
my $ncolor = "\033[m";   # normal, black
my $bcolor = "\033[33m"; # binary, yellow
my $mcolor = "\033[31m"; # netmask, red
my $ccolor = "\033[35m"; # classbits, magenta
my $dcolor = "\033[32m"; # newbits, green
my $break  ="\n";

my $h;                   # Host address

foreach (@privmin) {
    $_ = &bintoint(&dqtobin("$_"));
}

foreach (@privmax) {
    $_ = &bintoint(&dqtobin("$_"));
}


if (! defined ($ARGV[0])) {
    &usage;
    exit();
}

if (defined ($ARGV[0]) && $ARGV[0] eq "-b") {
    $ARGV[0] = "-n";
    $print_bits = 0;
}

if (defined ($ARGV[0]) && $ARGV[0] eq "-v") {
    print "$version\n";
    exit 0;
}

if (defined ($ARGV[0]) && $ARGV[0] eq "-n") {
    shift @ARGV;
    $qcolor = '';
    $ncolor = '';
    $bcolor = '';
    $mcolor = '';
    $ccolor = '';
    $dcolor = '';
}

if (defined ($ARGV[0]) && $ARGV[0] eq "-c") {
    shift @ARGV;
    $print_only_class = 1;
}

my $host  = "192.168.0.1";
my $mask  = '';
my $mask2 = '';
my @arg;

if ((defined $ARGV[0]) &&($ARGV[0] =~ /^(.+?)\/(.+)$/)) {
  $arg[0] = $1;
  $arg[1] = $2;
  if (defined($ARGV[1])) {
   $arg[2] = $ARGV[1];
  }
} else {
  @arg = @ARGV;
}

if (defined $arg[0]) {
    $host = $arg[0];
}
if (! ($host = &is_valid_dq($host)) ) {
    print "$mcolor Illegal value for ADDRESS ($arg[0])$ncolor\n";
}



if (defined $arg[1]) {
    $mask = $arg[1];
    if (! ($mask = is_valid_netmask($mask)) ) {
	print "$mcolor Illegal value for NETMASK ($arg[1])$ncolor\n";
    }
}
else
{
# if mask is not defined - take the default mask of the network class
   $mask = $class[getclass(dqtobin($host))];
}

if ($print_only_class) {
   print $class[getclass(dqtobin($host))];
   exit 0;
}

if (defined ($arg[2])) {
    $mask2 = $arg[2];
    if (! ($mask2 = is_valid_netmask($mask2)) ) {
	print "$mcolor Illegal value for second NETMASK ($arg[2])$ncolor\n";
    }
} else {
    $mask2 = $mask;
}

print "\n";

printline ("Address",   $host                      , (&dqtobin($host),$mask,$bcolor,0) );
my $m  = cidrtobin($mask);
#pack( "B*",("1" x $mask) . ("0" x (32 - $mask)) );

print_netmask($m,$mask);
print "=>\n";

$h = dqtobin($host);

my $n = $h & $m;



&printnet($n,$mask);


if ( $mask2 == $mask ) {
    &end;
}
if ($mask2 > $mask) {
    print "Subnets\n\n";
    $mark_newbits = 1;
    &subnets;
} else {
    print "Supernet\n\n";
    &supernet;
}

&end;

sub end {
 exit;
}

sub supernet {
    $m  = cidrtobin($mask2);
    ##pack( "B*",("1" x $mask2) . ("0" x (32 - $mask2)) );
    $n = $h & $m;
    print_netmask($m,$mask2);
    print "\n";
    printnet($n,$mask2);
}

sub subnets {
    my $subnets = 0;
    my @oldnet;
    my $oldnet;
    my $k;
    my @nr;
    my $nextnet;
    my $l;


    $m  = cidrtobin($mask2);
    ##pack( "B*",("1" x $mask2) . ("0" x (32 - $mask2)) );
    print_netmask($m,$mask2);
    print "\n"; #*** ??

    @oldnet = split //,unpack("B*",$n);
    for ($k = 0 ; $k < $mask ; $k++) {
	$oldnet .= $oldnet[$k];
    }
    for ($k = 0 ; $k < ( 2 ** ($mask2 - $mask)) ; $k++) {
	@nr = split //,unpack("b*",pack("L",$k));
	$nextnet = $oldnet;
	for ($l = 0; $l < ($mask2 - $mask) ; $l++) {
	    $nextnet .= $nr[$mask2 - $mask - $l - 1] ;
	}
	$n = pack "B32",$nextnet;
	&printnet($n,$mask2);
	++$subnets;
	if ($subnets >= 1000) {
	    print "... stopped at 1000 subnets ...$break";
	    last;
	}
    }

    if ( ($subnets < 1000) && ($mask2 > $mask) ){
	print "\nSubnets:   $qcolor$subnets $ncolor$break";
	print "Hosts:     $qcolor" . ($allhosts * $subnets) . "$ncolor$break";
    }
}

sub print_netmask {
   my ($m,$mask2) = @_;
   printline ("Netmask",        &bintodq($m) . " == $mask2", ($m,$mask2,$mcolor,0) );
   printline ("Wildcard",       &bintodq(~$m)              , (~$m,$mask2,$bcolor,0) );
}

sub getclass {
   my $n = $_[0];
   my $class = 1;
   while (unpack("B$class",$n) !~ /0/) {
      $class++;
      if ($class > 5) {
	 last;
      }
   }
   return $class;
}

sub printnet {
    my ($n,$mask) = @_;
    my $nm;
    my $type;
    my $hmin;
    my $hmax;
    my $hostn;
    my $p;
    my $i;


    $nm = ~cidrtobin($mask);

    $b = $n | $nm;

    $type = getclass($n);
    if ($type > 5 ) {
       $type = "Undefined Class";
    } else {
       $type = "Class " . chr($type+64);
    }

    $hmin  = pack("B*",("0"x31) . "1") | $n;
    $hmax  = pack("B*",("0"x $mask) . ("1" x (31 - $mask)) . "0" ) | $n;
    $hostn = (2 ** (32 - $mask)) -2  ;

    $hostn = 1 if $hostn == -1;


    $p = 0;
    for ($i=0; $i<3; $i++) {
	if ( (&bintoint($hmax) <= $privmax[$i])  &&
             (&bintoint($hmin) >= $privmin[$i]) ) {
	    $p = $i +1;
	    last;
	}
    }

    if ($p) {
	$p = $private;
    } else {
	$p = '';
    }


    printline ("Network",   &bintodq($n) . "/$mask", ($n,$mask,$bcolor,1),  " ($ccolor" . $type. "$ncolor)" );
    printline ("Broadcast", &bintodq($b)           , ($b,$mask,$bcolor,0) );
    printline ("HostMin",   &bintodq($hmin)        , ($hmin,$mask,$bcolor,0) );
    printline ("HostMax",   &bintodq($hmax)        , ($hmax,$mask,$bcolor,0) );
    printf "Hosts/Net: $qcolor%-22s$ncolor",$hostn;

    if ($p) {
       print "$p";
    }

    print "$break$break\n";

    $allhosts = $hostn;
}

sub printline {
   my ($label,$dq,$mask,$mask2,$color,$mark_classbit,$class) = @_;
   $class = "" unless $class;
   printf "%-11s$qcolor","$label:";
   printf "%-22s$ncolor", "$dq";
   if ($print_bits)
   {
      print  formatbin($mask,$mask2,$color,$mark_classbit);
      if ($class) {
         print $class;
      }
   }
   print $break;
}

sub formatbin {
    my ($bin,$actual_mask,$color,$mark_classbits) = @_;
    my @dq;
    my $dq;
    my @dq2;
    my $is_classbit = 1;
    my $bit;
    my $i;
    my $j;
    my $oldmask;
    my $newmask;

    if ($mask2 > $mask) {
	$oldmask = $mask;
	$newmask = $mask2;

    } else {
	$oldmask = $mask2;
	$newmask = $mask;
    }



    @dq = split //,unpack("B*",$bin);
    if ($mark_classbits) {
	$dq = $ccolor;
    }	else {
	$dq = $color;
    }
    for ($j = 0; $j < 4 ; $j++) {
	for ($i = 0; $i < 8; $i++) {
	    if (! defined ($bit = $dq[$i+($j*8)]) ) {
		$bit = '0';
	    }

	    if ( $mark_newbits &&((($j*8) + $i + 1) == ($oldmask + 1)) ) {
		$dq .= "$dcolor";
	    }


	    $dq .= $bit;
	    if ( ($mark_classbits &&
		  $is_classbit && $bit == 0)) {
		$dq .= $color;
		$is_classbit = 0;
	    }

	    if ( (($j*8) + $i + 1) == $actual_mask ) {
		$dq .= " ";
	    }

	    if ( $mark_newbits &&((($j*8) + $i + 1) == $newmask) ) {
		$dq .= "$color";
	    }

	}
	push @dq2, $dq;
	$dq = '';
    }
    return (join ".",@dq2) . $ncolor;
    ;
}

sub dqtobin {
        my @dq;
	my $q;
	my $i;
	my $bin;

	foreach $q (split /\./,$_[0]) {
		push @dq,$q;
	}
	for ($i = 0; $i < 4 ; $i++) {
		if (! defined $dq[$i]) {
			push @dq,0;
		}
	}
	$bin    = pack("CCCC",@dq);      # 4 unsigned chars
	return $bin;
}

sub bintodq {
	my $dq = join ".",unpack("CCCC",$_[0]);
print
	return $dq;
}

sub bintoint {
	return unpack("N",$_[0]);
}


sub is_valid_dq {
	my $value = $_[0];
	my $test = $value;
 	my $i;
	my $corrected;
	$test =~ s/\.//g;
	if ($test !~ /^\d+$/) {
		return 0;
	}
	my @value = split /\./, $value, 4;
	for ($i = 0; $i<4; $i++) {
		if (! defined ($value[$i]) ) {
			$value[$i] = 0;
		}
		if ( ($value[$i] !~ /^\d+$/) ||
		     ($value[$i] < 0) ||
                     ($value[$i] > 255) )
                {
			return 0;
		}
	}
	$corrected = join ".", @value;
	return $corrected;
}

sub is_valid_netmask {
	my $mask = $_[0];
	if ($mask =~ /^\d+$/) {
		if ( ($mask > 32) || ($mask < 1) ) {
			return 0;
		}
	} else {
		if (! ($mask = &is_valid_dq($mask)) ) {
			return 0;
		}
		$mask = dqtocidr($mask);
	}
	return $mask;

}


sub cidrtobin {
   my $cidr = $_[0];
   pack( "B*",(1 x $cidr) . (0 x (32 - $cidr)) );
}

sub dqtocidr {
	my $dq = $_[0];
	$b = &dqtobin($dq);
	my $cidr = 1;
	my $firstbit = unpack("B1",$b) ^ 1;
	while (unpack("B$cidr",$b) !~ /$firstbit/) {
		$cidr++;
		last if ($cidr == 33);
	}
	$cidr--;
	my $m = cidrtobin($cidr);
	if (bintodq($m) ne $dq && bintodq(~$m) ne $dq) {
 	   print "$mcolor Corrected illegal netmask: $dq" . "$ncolor\n";
	}
	return $cidr;

}

sub usage {
    print << "EOF";
Usage: ipcalc [-n|-h|-v] <ADDRESS>[[/]<NETMASK>] [NETMASK]

ipcalc takes an IP address and netmask and calculates the resulting broadcast,
network, Cisco wildcard mask, and host range. By giving a second netmask, you
can design sub- and supernetworks. It is also intended to be a teaching tool
and presents the results as easy-to-understand binary values.


 -n    Don't display ANSI color codes
 -b    Suppress the bitwise output
 -c    Just print bit-count-mask of given address
 -h    Display results as HTML
 -v    Print Version

Examples:

ipcalc 192.168.0.1/24
ipcalc 192.168.0.1/255.255.128.0
ipcalc 192.168.0.1 255.255.128.0 255.255.192.0
ipcalc 192.168.0.1 0.0.63.255

EOF
}
ENDOFIPCALCPERL
}

wwwget(){
# wwwget - fetch a url and print on stdout, including request and headers.
# The actual script is being kept in CVS (scripts/wwwget.pl)
#
# The only changes that need to be made to the wwwget code after copying
# is removing the $'s from the RCS Id tag, and Revision from $version
#
# Everything after the "-" is passed on to the script, so  any arguments
# passed to the function wwwget are passed on to the Perl script

$perl - "$@" <<"ENDOFWWWGETPERL"
#!/usr/bin/perl -w
# Id: wwwget.pl,v 1.28 2010/03/21 20:47:46 linus Exp $
my $version = 'Revision: 1.28 $';
require 5;
#
# wwwget - a simple http request tool.
# Copyright (C) Linus
# This script comes with NO WARRANTY WHATSOEVER, read the code before using it.
#
#
# Revision history
# 1.0  - Working, sort of. Using netcat for tcp communication. Very crude.
# 1.10 - Don't remember ;-)
# 1.20 - Uses sockets
# 1.30 - Ability to repeat request (-i). Quite stable.
# 1.31 - Minor cleanups
# 1.35 - Regexp for decoding URL rewritten. Some cleanup.
# 1.40 - Ability to cycle between several different URLs
#        Primarily used for requesting the URL of an image,
#        And then "clicking" the link of that same image.
# 1.41 - Line termination in request changed from "\n" to "\015\012",
#        per HTTP specifications.
# 1.42 - Added -H option to change the Host header
# Starting again at 1.0 - with RCS
# See RCS log for further revision history

# Perl modules used.
use strict;                        # Let's do things properly
use IO::Socket;                    # For the socket routines
use Getopt::Std;                   # For retrieving command line options

# Defaults and predeclaration of variables, in no logical order.
my %opts;                          # used for storing command line arguments
my %spawned;                       # keeping track of child processes
my $debug;                         # Debug flag. Set by option -d
my $CRLF             = "\015\012"; # Used for terminating lines
my $def_path         = "/";        # Default path
my $def_port         = 80;         # Default remote port
my $def_port_ssl     = 443;        # Default remote port (SSL)
my $http_host;                     # Host used in HTTP header
my $protocol_version;              # Version of the HTTP protocol
my $request_method;                # HTTP request method
my $user_agent;                    # Default User-Agent header
my $max_spawned;                   # max number of child processes
my $iterations;                    # Number of times to repeat the same request
my $sleep;                         # Number of seconds to sleep between requests
my $slowdown;                      # Flag to say that we need to stop forking
my $quiet;                         # -q causes the output to be less verbose
my $server_response;               # Placeholder for response from server
my $socket;                        # file handle for socket
my $header_finished;               # Used to see if header is finished
my $postdata;                      # body for a POST request
my $content_length;                # Content-Length header for POST
my $url_hash = [];                 # List of URLs, in a an annonymous array of hashes
# Available user agents
my %agents = (
    mozilla_xp => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.12) Gecko/20050915 Firefox/1.0.7",
    ie4_nt4 => "Mozilla/4.0 (compatible; MSIE 4.01; Windows NT)",
    ie5_nt4 => "Mozilla/4.0 (compatible; MSIE 5.0; Windows NT; DigExt)",
    ie6_xp  => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)",
);
# A sensible default
my $default_agent = "$agents{mozilla_xp}";


# Start of the actual script...

# Install signal handler for SIGCHLD (lets us know when a child process exits)
$SIG{CHLD} = \&reaper;
debug ("Starting, PID: $$\n");

# Get command-line options.
getopts('c:df:H:hi:m:qr:s:u:V:v', \%opts);

# Do we need help or version info?
if ( $opts{h} ) { &print_usage; }
if ( $opts{v} ) { &print_version; }

# No ARGV[0] would mean that we where called without a URL to fetch.
unless ( $ARGV[0] ){ &missing_arg("No URL specified!"); }

# Asign settings based on command line options.
$debug			= $opts{d} || 0;
$max_spawned		= $opts{f} || 0;
$iterations		= $opts{i} || 1;
$request_method		= $opts{m} || "GET";
$protocol_version	= $opts{V} || "1.0";
$quiet			= $opts{q};
$user_agent		= &find_agent($opts{u});
$sleep			= $opts{s} || 0;

# Now we need to extract hostname, port, and path from the
# URL's specified on the command line.
my $counter=0;
while ( my $url = shift (@ARGV) ) {
  $url_hash->[$counter] = &decode_url($url);
  $counter++;
}

ITERATION: for (my $i=1; $i<=$iterations; $i++) {
    # If we are doing a loop, then print a message for each iteration.
    # Print the output on STDERR (visible when STDOUT is redirected elsewhere)
    if ($iterations > 1) { print STDERR "Request: $i of $iterations ", scalar ( localtime() ), "\n" }

    URL_IN_LIST: foreach my $url (@$url_hash) {
        debug("Fetching: $url->{full_url}\n");

        # See if we need to slow down fork()ing.
        # If $max_spawned is positive, and we've spawned more than $max_spawned already
        if ( keys (%spawned) < $max_spawned || $max_spawned < 0 ) { $slowdown = 0; }
        else { $slowdown = 1; }

        # if $max_spawned is unlimited (negative value)
        if ( $slowdown == 0 ) {
            if ( ! spawn ( \&fetchurl, $url ) ) {
                # spawn (fork) failed, need to slow down
                $slowdown = 1;
            }
        }
        # Check if $slowdown has been set (either by hitting max $max_spawned or a failed fork())
        if ( $slowdown == 1 ) {
            if ( $max_spawned != 0 ) {
                print STDERR "Out of process space, slowing down (max: $max_spawned, curr:  " . keys (%spawned) . ")\n";
            }
            # Fetch without forking
            &fetchurl($url);
        }
    } # looping over URLs (URL_IN_LIST)
    if ( $sleep ) { sleep ($sleep); }
} # for $i (ITERATION)

# Now wait for all child processes to finish
while ( keys (%spawned) ) {
    debug ("Remaining (" . keys (%spawned) . "): ");
    foreach my $pid ( keys %spawned ) { debug2 ("$pid, "); }
    debug2 ("\n");
    # Reap anything that's available for reaping
    &reaper;
}

exit(0);


###                            Sub routines                            ###
sub fetchurl {
    my $url=shift();
#    debug ("Processing URL: $url->{remote_host}\n");
    debug ("In fetchurl(), PID: $$\n");
    if ( $url->{do_ssl} ) {

        # Attempt to load SSL module. Bitch a bit if SSL is unavailable
        eval {
            no warnings;
            local $SIG{'__DIE__'};
            require IO::Socket::SSL;
        };
        if ( $@ ) {
            print "$url->{remote_host}:$url->{remote_port} is SSL, but we haven't got IO::Socket::SSL\n";
            return 0;
        }

        unless ( $socket = IO::Socket::SSL->new(PeerAddr => "$url->{remote_host}",
                                            PeerPort => "$url->{remote_port}",
                                            Proto    => 'tcp',
                                            SSL_use_cert => 0,
                                            SSL_verify_mode => 0x00,
                                            ) ) {
            warn "Couldn't open socket ($url->{remote_host}): $!\n", &IO::Socket::SSL::errstr, "\n";
            return;
        }
    } # if do_ssl
    else {
        unless ($socket = IO::Socket::INET->new(PeerAddr => "$url->{remote_host}",
                                            PeerPort => "$url->{remote_port}",
                                            Proto    => 'tcp')){
            warn "Couldn't open socket ($url->{remote_host}): $!\n";
            return;
        }
    } # else not ssl

    # Use the actual name of the host in the Host header, if none is specified
    $http_host = $opts{H} || $url->{remote_host};

    # Only print headers and stuff in normal (non-quiet) mode
    unless ($quiet) { print "Connected: $url->{remote_host}:$url->{remote_port}; SSL: $url->{do_ssl}\nRequest:\n\n"; }

    # Print the HTTP request, on STDOUT and on the socket.
    print_socket("$request_method $url->{path} HTTP/$protocol_version$CRLF");
    print_socket("User-Agent: $user_agent$CRLF");
    print_socket("Host: $http_host$CRLF");
    if ($opts{c}) { print_socket("Cookie: $opts{c}$CRLF"); }
    if ($opts{r}) { print_socket("Referer: $opts{r}$CRLF"); }
    print_socket("Accept: */*$CRLF");
    # Try to handle POST correctly
    if ( $request_method eq "POST" ) {
        chomp ( $postdata = <STDIN> );
        $content_length=length($postdata);
        print_socket("Content-Type: application/x-www-form-urlencoded$CRLF");
        print_socket("Content-Length: $content_length$CRLF");
        print_socket("$CRLF");
        print_socket("$postdata")
    }
    print_socket("$CRLF$CRLF");

    unless ( $quiet ){ print "Response:\n\n"; }
    while ($server_response = <$socket>) {
        # if -q option is used, make sure not to print the header...
        if ( $header_finished || ! $quiet ) { print "$server_response"; }
        # An empty line divides headers from body of the response. More reliable than
        # looking for combinations of CR and LF
        if ( $server_response =~ /^\s*$/ ) { $header_finished = 1; }
    } # while
    if ( $url->{do_ssl} ) {
        $socket->close(SSL_no_shutdown => 1);
    }
    else {
        close $socket;
    }
    return 1;
} # sub fetchurl

sub debug {
    # Debug function. Prints debug info if debugging is enabled
    my $debugtext = shift();
    $debugtext =  "DEBUG: $debugtext";
    debug2 ($debugtext);
    return 1;
}

sub debug2 {
    # Debug function #2, used by debug() itself
    # can be called directly to debug without "DEBUG: " prefix
    my $debugtext = shift();
    if ( $debug ) { print STDERR "$debugtext" };
}

sub decode_url {
    my $url = shift();
    my $url_hash = {};

    # The defaults
    $url_hash->{remote_port} = "$def_port";
    $url_hash->{path} = "$def_path";
    $url_hash->{do_ssl} = 0;

    # The full URL - can be used in debug output
    $url_hash->{full_url} = "$url";

    # First remove http://, but only if it is in the beginning of URL.
    # We would only want to remove the first http:// in something like:
    # http://foo/script.cgi?redirect=http://bar
    $url =~ s/^http:\/\///;
    if ( $url =~ s/^https:\/\/// ) {
    	$url_hash->{do_ssl} = 1;
    	$url_hash->{remote_port} = "$def_port_ssl";
    }

    # This just asigns host, port, path to $1, $2, $3
    $url =~ /([\w\.\-\_]*):?(\d*)(\/*.*)/;
    $1 ne "" and $url_hash->{remote_host} = "$1";
    $2 ne "" and $url_hash->{remote_port} = "$2";
    $3 ne "" and $url_hash->{path}        = "$3";
    if ( $url_hash->{remote_host} eq "" ){ &missing_arg("No host specified in URL!"); }
    return ($url_hash);
} # decode_url

# Decide what web browser wwwget should impersonate.
# More values could be added if needed.
sub find_agent {
    my $wanted_agent;	# what got passed in

    # use the default if nothing's specified
    $wanted_agent = shift || return "$default_agent";

    if ( $agents{"$wanted_agent"} ) {
        return $agents{$wanted_agent};
    }
    else {
        return "$wanted_agent";
    }
} # find_agent


# Warn and exit when an argument is missing
sub missing_arg {
    warn "       Error: Nothing to do. ($_[0])\n";
    warn "              Try wwwget -h for usage information\n";
    exit(1);
}

sub print_socket {
    # Prints a text string on standard output and $socket.
    my $string = shift;
    unless ($quiet) { print "$string"; }
    print $socket  "$string";
}

sub spawn {
# Routine: spawn
# Usage:   spawn(*SubRoutine, "argument1", "argument2")
# Spawns a new child process, running the specified sub routine.
    my $spawn_sub = shift;
    my @args = @_;
    my $pid;

    # debug("args passed to spawn(): ( $spawn_sub, @args )\n");

    if (!defined($pid = fork)) {
        debug ("Cannot fork: $! (will try spoon ;-) )\n");
        return 0;
    } elsif ($pid) { # I'm the parent, return.
        $spawned{$pid} = 1;
        debug ("Parent: ($$) forked PID: $pid\n");
        debug ("Child processes: " . keys ( %spawned ) . "\n");
        return 1;
    }
    # I'm the child, run specified sub routine
    &$spawn_sub(@args);
    exit;
} # spawn


sub reaper {
# Routine: reaper
# Description: Used by spawn() to wait for deceased children
    my $pid = wait;
    $SIG{CHLD} = \&reaper;  # reinstall signal handler
    if ( $pid == -1 ) {
        debug ("No more child processes left (wait() returns -1)\n");
    }
    else {
        debug("Reaped PID: $pid ($?)\n");
        delete $spawned{$pid};
    }
}


# Print version information and exit.
sub print_version {
    print "wwwget.pl $version\n";
    print "Copyright (C) 1999 onwards Linus\n";
    print "This script comes with NO WARRANTY WHATSOEVER, read the code before using it.\n\n";
    print "The script may be redistributed under a BSD license, contact me if you'd\n";
    print "like to do anything else\n\n";
    exit(0);
}

# Print usage information and exit.
sub print_usage {
print <<EOT1;
Usage: $0 [options] URL

wwwget.pl $version
Copyright (C) 1999 onwards Linus, please read the script for disclaimer.

Makes HTTP request for specified URL on the remote server.
The URL should be in the format [http[s]://]Server[:Port][/Path]
Prints the servers response to standard output.
Be sure to quote any spaces or characters such as "&", which
might be interpreted by the shell.

Options:
-c <cookie>   Includes the specified HTTP cookie in the request.
-d            Enables debugging (printed on STDERR, prefixed with "DEBUG: ")
-f <num>      Fork for each request, maximum of <num> child processes
              If num is negative, the count is unlimited
-H <hostname> Sets the HTTP host header.
-h            Prints this help screen
-i N          Repeats the request with N iterations.
-m <method>   Make a <method> request instead of the default GET.
-q            Removes request and response headers from output
-r <URL>      Referrer URL
-s <seconds>  Sleep n seconds between each request
-u <agent>    Sets the User-Agent header. Pick one of the following:
EOT1
    foreach my $key (keys %agents) {
       print "              $key: $agents{$key}\n";
    }
print <<EOT2;
              You can also use any string value.
-V <version>  Specifies the HTTP version. Default is 1.0.
-v            Prints copyright and version information.

For POST requests, the data is read from STDIN (one line only)
Format:
Field=foo&Field2=bar&Textarea=Some+more+text%0D%0AWith+a+line+break&Submit=Send

For undocumented features (if any) please RTFS.

EOT2
exit(0);
}
ENDOFWWWGETPERL
} # end of SHELL function wwwget

### Settings and commands to be run
### Some of these depend on aliases and functions elsewhere, so belong last
### in .bashrc


# Figure out what we want in our $PATH
# Directories that we'll want in $PATH, if they exist, in order of preference
# Some of these are specific to a certain environment, such as Iris
pathdirs="/sbin /usr/sbin /bin /usr/bin /usr/local/sbin /usr/local/bin \
 /usr/X11R6/bin /usr/games /usr/contrib/bin $HOME/bin /usr/java/bin \
 /usr/pkg/bin /usr/ccs/bin /usr/ucb /usr/local/ssh/bin $HOME/.rvm/bin"

# Add all these dirs
pathadd -q $pathdirs

#  A few OS-specific aliases, etc
# Desktop directory used by gnome, etc
[ -d ~/Desktop ] && alias dt="cd ~/Desktop"

# Ruby Version Manager
if [ -f ~/.rvm/scripts/rvm -a "$(type -t rvm)" != "function" ] ; then
  echo "Loading rvm..."
  source ~/.rvm/scripts/rvm
fi

# This is just so that the Darwin-specific top options work with the top() function later on...
top="top"

### OpenBSD
if echo $OSTYPE | grep "openbsd" > /dev/null ; then
  DCMF_OS=obsd
  # OpenBSD used to be my main OS, but I rarely use it these days, so no special cases :(
fi
### Android
if [ "$OSTYPE" = "linux-android" ] ; then
  DCMF_OS=android
fi
### GNU/Linux
if [ "$OSTYPE" = "linux-gnu" ] ; then
  DCMF_OS=linux
  alias grep="grep --color=auto"
fi
### OSX / Darwin
if echo $OSTYPE | grep "darwin" > /dev/null ; then
  DCMF_OS=osx
  top="top -o cpu"
  alias hibernateon="sudo pmset -a hibernatemode 25 ; echo 'Will now hibernate when closing lid'"
  alias hibernateoff="sudo pmset -a hibernatemode 3 ; echo 'Will just sleep when closing lid'"
fi
### Cygwin
if [ "$MACHTYPE" == "i686-pc-cygwin" ] ; then
  dtdir='"/cygdrive/c/Documents and Settings/$USER/Desktop"'
  pathadd -q /cygdrive/c/bin /cygdrive/c/WINDOWS /cygdrive/c/WINDOWS/system32
  alias dt="cd $dtdir"
  alias gvim="/cygdrive/c/Program\ Files/Vim/vim63/gvim"
  alias traceroute="tracert"
  # I tend to have this alias in cmd prompts in Windows, so get into
  # the same bad habit in Cygwin...
  alias x="exit"
fi


# Some stupid os's (read commercial SysV stuff, oh, and RedHat)
# don't set a proper umask by default
umask 022

# Try to be clever for machines that have Perl4 in /usr/bin/perl
perl=perl
[ -x /usr/local/bin/perl5 ] && perl=/usr/local/bin/perl5
[ -x /usr/bin/perl5 ] && perl=/usr/bin/perl5

# Some telnet client that I used to be using on my Palm, I think...
if [ "$TERM" = "tgtelnet" ]; then
  stty rows 19
#  /usr/local/bin/screen -r || exec /usr/local/bin/screen $SHELL
#  exit
fi

####
##### GIT STUFF
####

# git commit & push
alias gpr="git pull --rebase"
alias gst="git status"
alias gd="git diff"
alias gcp="gpr; git cherry-pick"
alias gcpp="git commit -a ; git pull --rebase ; git push"
alias gbr="git branch"
alias gl='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
alias ga="git add ."
alias gh='git log --pretty=format:"%h %ad [%an] |  %s%d" --graph --date=short'
alias gc="git commit"
alias gb="git branch"
alias gco='git checkout'
# These are intentionally spelled out a bit longer, since they're dangerous and you don't want to do it by accident
alias git_abort_commit="echo 'Abort commits? ENTER/CTRL-C' && read && git reset --hard HEAD~1"
alias git_reset_hard_head="echo 'Reset to HEAD? ENTER/CTRL-C' && read && git reset --hard HEAD"
alias git_reset_hard_origin="echo 'Reset from origin/master? ENTER/CTRL-C' && read && git reset --hard origin/master"

# Set a prompt for when inside a git repo
git_prompt(){
  # We use a timeout, to avoid hanging if CWD is unavailable
  if ref=$(timeout 1 git symbolic-ref HEAD 2>/dev/null); then
    gitstatus="$(timeout 1 git status)"
    if echo "$gitstatus" | grep -E 'Changes|Changed|Untracked' >/dev/null; then
      COLOUR="$RED"
    elif echo "$gitstatus" | grep -E 'Your branch is ahead' >/dev/null; then
      ahead_by=":$(echo "$gitstatus" | grep 'Your branch is ahead' | sed 's/.*by \(.*\) commit.*/\1/')"
      COLOUR="$YELLOW"
    elif echo "$gitstatus" | grep -E 'Unmerged paths' >/dev/null; then
      COLOUR="$PURPLE"
    elif echo "$gitstatus" | grep -E 'working (directory|tree) clean' >/dev/null; then
      COLOUR="$GREEN"
    else
      # Unknown status
      COLOUR="$LIGHT_BLUE"
    fi
    echo -ne "[$COLOUR${ref#refs/heads/}${ahead_by}$ENDCOLOUR]"
  else
    return 1
  fi
}

# Create a branch on Github
git_create_remote_branch(){
  # Replace spaces with underscores
  local new_branch=$(echo $* | sed -r 's/[^a-zA-Z0-9-]/_/g')
  local from_branch
  local default_from='master'

  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME <new branch name>"
    return 1
  fi

  echo "New branch: $new_branch"
  echo "Which branch do you want to cut from?"
  echo "Enter \"c\" for current branch, leave empty to use default ($default_from) or enter branch name"
  echo -n "From branch: "
  read from_branch
  if [ -z "$from_branch" ] ; then
    from_branch=$default_from
  elif [ "$from_branch" = "c" ] ; then
    from_branch=$(get_current_git_branch)
  fi

  echo "Cutting new branch $new_branch from $from_branch"

  if ! git checkout $from_branch ; then
    echo "Branch not found: $from_branch, aborting"
    return 1
  fi

  if ! git pull --rebase ; then
    echo
    echo
    echo "Something went wrong when trying to pull"
    echo "Press ENTER to continue and put these changes into the new branch, or CTRL-C to abort, and sort out any conflicts"
    read foo
  fi

  echo "Creating and pushing: $new_branch"
  git checkout -b $new_branch
  git push -u origin $new_branch
  echo "Done"
}



git_diff_origin(){
  git diff origin/$(get_current_git_branch)..HEAD
}

# Found and modified from: http://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommited-changes
git_require_clean_work_tree () {
  # First off, we abort if this doesn't look like a git repo, otherwise, all of the git commands will generate errors
  if ! [ -d ./.git ]; then
    echo "Not a git repo (no .git directory): $(pwd)" >&2
    return 1
  fi

  # Update the index
  git update-index -q --ignore-submodules --refresh
  err=0

  # Disallow unstaged changes in the working tree
  if ! git diff-files --quiet --ignore-submodules -- ; then
      echo >&2 "Aborting: you have unstaged changes."
      git diff-files --name-status -r --ignore-submodules -- >&2
      err=1
  fi

  # Disallow uncommitted changes in the index
  if ! git diff-index --cached --quiet HEAD --ignore-submodules -- ; then
      echo >&2 "Aborting: your index contains uncommitted changes."
      git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
      err=1
  fi

  if ! [ $err -eq 0 ] ; then
      echo >&2 "Please commit or stash them."
      return 1
  fi

  # If no arguments were specified, then we just return 0 to indicate success, otherwise we run the specified git command
  if [ -z "$1" ]; then
    return 0
  else
    git $*
  fi
}


mergemaster(){
  echo "This will merge master into UAT and QA branches. It assumes that branches master, uat and qa are all clean in your local tree."
  echo "Press CTRL-C to abort, or ENTER to continue."
  read foo
  local branch
  ctrails
  local previous_branch=$(get_current_git_branch)
  git_require_clean_work_tree || return 1
  git checkout master
  git_require_clean_work_tree || return 1
  git pull --rebase
  for branch in qa uat ; do
    git checkout $branch
    git_require_clean_work_tree || return 1
    git pull --rebase
    git_require_clean_work_tree || return 1
    git merge master
    git push
  done

  # Also ensuring that the QA branch is up to date, since that often gets skipped
  git checkout qa
  git merge uat
  git_require_clean_work_tree || return 1
  git push

  git checkout $previous_branch
}


git_clean_branches(){
  echo "Cleaning out LOCAL copies of branches. This will not delete anything from remote repo"
  for branch in $(git branch  | grep -v '^*' | grep -v -E ' master$' | grep -v " uat$" | grep -v " qa$"); do
    echo
    echo -n "Remove $branch? (y/N): "
    read ans
    if [ "$ans" = "y" ] ; then
      echo "Removing $branch..."
      git branch -d $branch
    else
      echo "Skipping $branch..."
    fi
  done
}

# Git change branch
gcb(){
  local lastbranchfile=~/.lastgitbranch$(git rev-parse --show-toplevel | sed 's/\W/_/g')
  local new_branch

  if [ "$1" = "-" ] ; then
    local branches="$(git_get_branches)"
    new_branch=$(cat $lastbranchfile)
  elif [ ! -z "$1" ] ; then
    # A branch name was specified
    local branches="$(git_get_branches)"
    new_branch=$1
  else
    local branches="$(git_get_branches)"
    local PS3='Branch (or CTRL-D to quit)#: '
    echo "Checking if there are remote branches to fetch"
    if git fetch --dry-run 2>&1 | grep 'new branch' ; then
      local PS3="$(echo 'NOTE: You need to run git fetch to include newly added branches'; echo $PS3) "
    fi
    select new_branch in $branches ; do
      break
    done
  fi

  if [ -z "$new_branch" ] ; then
    echo "No branch selected, aborting"
  else
    get_current_git_branch > $lastbranchfile
    chmod go-rwx $lastbranchfile
    if echo "$branches" | grep "^$new_branch$" > /dev/null ;then
      echo "Exact match, checking out: $new_branch"
      git checkout $new_branch
    else
      # There wasn't an exact match, so we try partial match.
      echo "Trying to find branch that matches $new_branch"
      found_branch=$(echo "$branches" | grep $new_branch | head -1)
      if [ -z "$found_branch" ]; then
        echo "No branch found matching $new_branch (try -a to include remote branches)"
      else
        echo "Found: $found_branch"
        git checkout $found_branch
      fi
    fi
  fi
}

git_get_branches(){
  # Get branches, including remote (-a)
  # NOTE: This does fetch anything from remote, just remote branches that we already know about. You need to run git fetch to find new remote branches.
  git branch -a -v | sed -r 's/^\*//' | awk '{print $1}' | sed 's#.*/##'
}

get_current_git_branch(){
  git symbolic-ref HEAD 2>/dev/null | sed 's#refs/heads/##'
}

###
###
##### SPOTIFY CONTROL
### Basic control of Spotify, through dbus, on systems that support it
###
spotifyctl(){
  dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.$1
}

pause(){
  spotifyctl Pause
}

play(){
  spotifyctl Play
}

prev(){
  spotifyctl Previous
}

next(){
  spotifyctl Next
}


#####
##### PROMPT SETTINGS
#####

gnome_get_kbd_layout(){
  # This only seems to work in X, not Wayland
  # xset -q | grep 'LED mask:' | sed 's/.*LED mask:  //'
  # This seems to get the same result
  # dconf read /org/gnome/desktop/input-sources/mru-sources
  gsettings get org.gnome.desktop.input-sources mru-sources | sed -r "s/\S*\s'([^']+).*/\1/"
}

# This is intended for desktop use, to remind me that I'm using a non-UK (probably Swedish) layout
gnome_kbd_layout_prompt(){
  [ -z "$GNOME_SETUP_DISPLAY" ] && return
  currlayout=$(gnome_get_kbd_layout)
  if [ "$currlayout" != "$default_kbd_layout" ] ; then
    # Anything else gets highlighted
    printf "${RED}[$currlayout]${ENDCOLOUR}"
  fi
}

# TODO: Also add "trunc" (t*) as an option, which doesn't show username, and only up to X characters of $PWD?
# Set prompt(PS1) to s(hort), supershort, truncated or regular.
# Sometimes, when working in a narrow terminal, the prompt can get a bit long, so it's nice to be able to shorten it
# Any argument starting with s is interpreted as short
# Any other orgument is interpreted as regular

set_primary_prompt(){
  # Last character of the prompt, can be overridden by setting $custom_psch
  if [ -n "$custom_psch" ] ; then
    psch="$custom_psch"
  elif [ "$(id -u 2>&1)" = "0" ] ; then
    psch='#'
  else
    psch='$'
  fi

  # Defaults
  # TODO: Figure out how we can fix wrapping and line editing with the coloured prompts
  # https://tldp.org/HOWTO/Bash-Prompt-HOWTO/nonprintingchars.html
  # This, for example, works:
  # ara_env_colour=$CYAN
  # PS1="\[${ara_env_colour}\][$ara_env]\[${ENDCOLOUR}\][\u@\h \W]\[${ara_psch_colour}\]\\$\[${ENDCOLOUR}\] "
  # Should the various prompt extras methods just set prompt_extras_colour and promt_extras_content?
  promptbase="\u@\h:\w\$(prompt_extras)"
  PS1="${promptbase}${psch} "
  unset PROMPT_DIRTRIM

  # If a format was specified
  case "$1" in
    ss)
      # Super Short
      echo "Super Short"
      PS1='\h:($(basename "$PWD" | cut -c 1-16))\$ '
    ;;
    s|sh*)
      # Short
      echo "Short"
      PS1="\u@\h:(\W)\$ "
    ;;
    # Trim directories, only show 2 path components, or as specified in a second argument
    dt)
      PROMPT_DIRTRIM=${2:-2}
      echo "Dir Trim: $PROMPT_DIRTRIM"
    ;;
    # Fold, dual line
    fo*|dl)
      echo "Fold / Dual Line"
      PS1="\n$promptbase\n$psch "
    ;;
    h*)
      echo "Usage: $FUNCNAME s(hort)|ss(supershort)|dt(dirtrim)|fold/dl(dual-line)"
    ;;
  esac

  # Indicate that the shell is running under sudo, if applicable
  if ! [ -z "$SUDO_USER" ] ; then PS1="(sudo)${PS1}" ;fi
  export PROMPT_DIRTRIM
}

prompt_extras(){
  # gnome_kbd_layout_prompt
  # TODO: If one of these returns a value, then abort the rest?
  git_prompt
  cvs_prompt
  rcs_prompt
}

rcs_prompt(){
  timeout 1 [ -d ./RCS ] || return
  if diffall > /dev/null 2>&1; then
    rcscolour=$GREEN
  else
    rcscolour=$RED
  fi
  printf "${rcscolour}(rcs)${ENDCOLOUR}"
}

# For CVS, you need to connect to the server to find out if there are modifications
# So, we just indicate that we're in a CVS repo, so we don't have to wait for potentially slow or disconnected networks
cvs_prompt(){
  timeout 1 [ -d ./CVS ] || return
  printf "$TEAL(cvs)$ENDCOLOUR"
}

###
##### OCD / ocd()
### A set of functions for using a local directory cache and changing directory to matches in different ways
### The main function is ocd()
### Intended to be combined with "alias cd=ocd" to augment the functionality of builtin cd command

ocd_build_cache(){
  local _dir
  local excludeflags

  touch $dcmf_ocd_cache
  chmod 600 $dcmf_ocd_cache

  for _dir in $dcmf_ocd_directories ; do
    if [ -f $_dir/.dcmf-ocd-exclude ] ; then
      warn "Using exclude file: $_dir/.dcmf-ocd-exclude"
      # Example exclude file: -path /space/netbackup -prune -o -path /space/lost+found -prune
      excludeflags="$(cat $_dir/.dcmf-ocd-exclude)"
    else
      warn "No exclude file found for $_dir, processing whole directory"
      excludeflags=""
    fi
    warn "Processing $_dir with exclude flags: $excludeflags"
    # Using sh -c to get the quoting/globbing right :)
    sh -c "find $_dir -type d -print $excludeflags"
  done | perl -e 'print sort { length($a) <=> length($b) } <>' > $dcmf_ocd_cache
  # We use perl to sort the file on length, so that short directory matches will be displayed first
}

ocd_setup(){
  if [ ! -f "$dcmf_ocd_cache" ] ; then
    warn "$ocd_current_args doesn't seem to exist."
    warn "The ocd() function is now building a directory cache ($dcmf_ocd_cache) and will use that for searching."
    warn 'To disable this feature, you can add "unalias cd" to your ~/.local_shellrc'
    warn 'Search directories (can be overridden by setting $dcmf_ocd_directories):'
    warn "$dcmf_ocd_directories"
    warn "You can also add an exclude file, .dcmf-ocd-exclude, listing files/directories to be excluded"
    ocd_build_cache
  elif [ `stat --format=%Y "$dcmf_ocd_cache"` -le $(( `date +%s` - $dcmf_ocd_cache_ttl )) ]; then
    warn "Updating ocd() cache (TTL: $dcmf_ocd_cache_ttl)"
    # ls -l $dcmf_ocd_cache
    ocd_build_cache
  fi
}

pcd(){
  OCD_PARTIAL_MATCH=true ocd $*
}

icd(){
  dcmf_ocd_grep_flags="-i" ocd $*
}


#
# TODO:
# focd() could pick the first decent looking match (OCD_FIRST_MATCH)
# Maybe better to use getopt, so options can be combined?
ocd(){
  ocd_current_args="$@"
  if [ $# -eq 0 ]; then
    # If there are no arguments, then act as the standard cd command, and cd home
    builtin pushd ~ >/dev/null
  elif [ "$@" = "-" ] ; then
    # cd - goes to previous directory
    command cd -
  elif builtin pushd "$@" >/dev/null 2>&1; then
    # If the argument is a directory that we can change into, then do nothing more...
    true
  elif [ -e "$@" -a ! -d "$@" ] && pushd "$(dirname "$@")" > /dev/null ; then
    # If the argument is a non-directory, but we can cd into its parent directory, then we're happy
    # Useful for example if you've been editing a file, and wants to cd into its directory
    # Instead of "cd $(dirname !$)" you can now just do "cd !$"
    echo "Changed to dirname of $@: $(pwd)"
  else
    ocd_change_to "$(OCD_PARTIAL_MATCH=$OCD_PARTIAL_MATCH ocd_get_matches)"
  fi
  # Finally, set title according to current working directory
  xtitle $USER@$HOSTNAME:$PWD
}

ocd_get_matches(){
  ocd_setup
  local exact_matches
  exact_matches="$(ocd_exact_matches)"
  if [ -z "$OCD_PARTIAL_MATCH" -a -n "$exact_matches" ] ;then
    # We we got an exact match, no further action needed
    echo "$exact_matches"
  else
    echo "$(ocd_partial_matches)"
  fi
}

ocd_partial_matches(){
  # There should be no slashes after the end of the directory name, otherwise we would include sub directories of the relevant results
  echo "$(grep $dcmf_ocd_grep_flags -E -- "$ocd_current_args[^/]*\$" $dcmf_ocd_cache)"
}

ocd_exact_matches(){
  # The directory name should end with end-of-line
  grep $dcmf_ocd_grep_flags -E -- "/$ocd_current_args\$" $dcmf_ocd_cache
}

ocd_change_to(){
  d="$(ocd_pick_from_matches "$*")"
  pushd "$d" >/dev/null
}

ocd_pick_from_matches(){
  if [ -z "$*" ]; then
    warn "$ocd_current_args: No such file or directory and nothing found in ocd() cache"
  elif [ "$(echo "$*" | wc -l)" -eq 1 ]; then
    warn "Unique match: $*"
    echo "$*"
  else
    # echo "More than one option"
    local IFS=$'\n'
    select _dir in $* ; do break ; done
    warn "Changing to: $_dir"
    echo $_dir
  fi
}

# Brutally replace the builtin cd command
# If you don't like this, then use your .local_shellrc to unalias it, or use your own alias
alias cd=ocd

# On the same theme as the nonsense above
# Find a directory under current directory, with the given name, then cd into it
# Should this use wildcards when finding?
fcd(){
  local basedir=.
  if [ $# -gt 1 ] ; then basedir=$1 ; shift ; fi
  target="$(find -L $basedir -type d -name "$@" -print -quit)"
  pushd "$target"
}


##### / ocd() end

##### And finally...
##### Actually apply some settings

# Set primary prompt (PS1)
set_primary_prompt

# Special cases for different shells
# This list used to be longer...
case "$SHELL" in
  */bash|*/ksh)
    set -o notify
    set -o emacs
    ;;
  */sh)
    ;;
esac

# Set the terminal/ssh client title to the default
xbacktitle

# Check the age of the file, and suggest updating if it's too old
shrc_age=`shrc_check_age`
# $noupdateshrc can be set in .local_shellrc to disable auto updating
if [ $shrc_age -gt $shrc_max_age -a -z "$noupdateshrc" ] ; then
  echo "Checking for update to $shrc_home ($shrc_age days since last check)"
  shrcupd
fi

# Display user's own motd, if one exists
# But only do this for the first shell, not sub shells
[ -f ~/.motd -a -z "$motd_done" ] && cat ~/.motd
motd_done=1 ; export motd_done

first_load_of_dotcomfy_bashrc_completed=true

# Source .local_shellrc if existent, last in file, to override globals
[ -f ~/.local_shellrc ] && . ~/.local_shellrc


