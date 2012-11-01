# The .bashrc from Hell (tm)
# https://github.com/dotcomfy/dotcomfy-bashrc/
#
###############################################################################
#
# Copyright (c) 1999-2012 Linus / Dotcomfy
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
# Some features in this .bashrc, such as updating itself,
# require either lynx or wwwget (which requires Perl and IO::Socket)
# to be installed and in the path. wwwget is included in the script,
# so as long as you've got a working Perl5 with IO::Socket you should be fine
#
# Since I've tended to work on a wide range of OSes and versions,
# and often supporting old legacy systems, one of the goals of this .bashrc
# has always been to minimise dependance third party software.
# 
#
# DISCLAIMER: Please do not use this .bashrc without FULLY understanding
# what it does. For all you know, it could be doing some really evil stuff.
#
# TODO:
# - Documentation and usable list of functions and aliases
# - Clean up stuff that I never use. The world has moved on a bit since 2001
# - Figure out why it's recently gotten so slow... it now takes seconds to load
#   (yes, it used to be faster even with a squillion lines of Perl)
#
# From 1999 to Dec 2010, this file was just kept in RCS.
# As of Dec 2010, it is on github
# Last CVS version:
# $Header: /home/linus/RCS/.bashrc,v 1.338 2010/12/22 13:29:51 linus Exp $

# Not much point in doing any of this stuff unless we're on a tty, is it?
if ! tty >/dev/null ; then
  return
fi

###
##### Settings
### Specific for the usage of the .bashrc and its functions
###
toolsbase="http://dotcomfy.net/tools" # location of traceroute, ping, etc tools
dlbase="http://dl.dotcomfy.net" # where files are downloaded from
githubbase="https://github.com/dotcomfy/dotcomfy-bashrc/raw/master/"
shrc_url="$githubbase/bashrc" # download location of .bashrc
backup_url="http://www.dotcomfy.net/dotcomfy_bashrc" # For non-SSL clients
dotprofile_url="$dlbase/bash_profile" # download location of .bash_profile
shrc_age_file="$HOME/.shrc_age_file" # file where a time stamp is stored
shrc_max_age=30 # warn if .bashrc age is older than this (in days)
file_tmp="$HOME/updatefile_tmp.$$"
shrc_home="$HOME/.bashrc" # could be set to eg ~/.profile in local shellrc"
jargonfile="$HOME/stuff/jargon.txt"

###
##### Shell variables
### Stuff used by various commands/applications, or the shell itself
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
# Get less to display a useful prompt, and quit if there's only one screen
LESS="-M -F" export LESS
# Set USER and HOSTNAME if they aren't set
if [ -z "$USER" -a ! -z "$LOGNAME" ] ; then
  USER=$LOGNAME export USER
fi
if [ -z "$HOSTNAME" ] ; then
  HOSTNAME=$(hostname) export HOSTNAME
fi
CVS_RSH=/usr/bin/ssh ; export CVS_RSH

###
##### Colours
### used in prompts, etc
###
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
ENDCOLOUR="\e[m"




###
##### Helper functions
### Used by other functions throughout the .bashrc
### These need to be listed early, to make them accessible to others

# Check if a pid is running
isrunning(){
  kill -0 $1 > /dev/null 2>&1
}

# Dump a web page to stdout, in a reasonably usable format (HTML removed)
# Uses lynx - could be rewritten to use something else
wwwdump()
{
  local url
  # replace selected special chars...
  url=`echo $* | sed 's/ /%20/g' | sed 's/"/%22/g'`
  lynx -hiddenlinks=ignore -nolist -dump $url
}


# Make ssh aliases - takes a list of host names and creates ssh aliases for them
# Helper function to be used from .local_shellrc
# Example: mksshalias -s "foo bar.example.com baz"
mksshalias()
{
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
   alias $shortcut="screen_ssh $hostname $title"
   done
}

# sets the title in x terminals, used by cd() and others to update title bars
# the variables xtitle1 and xtitle2 can be set in local shellrc,
# to prepend or append a string to the title
xtitle() { 
  case $TERM in
   *term* | *color | rxvt | vt100 | vt220 | cygwin | screen* ) 
      echo -n -e "\033]0;${xtitle1}${*}${xtitle2}\007" ;;
   *)  ;;
     esac
}

# sets the title to "default"
xbacktitle() {
  xtitle "$USER@$HOSTNAME:$PWD"
}

# Seriously pointless. Used by ssh() function
welcomeback() {
  echo
  echo "Back on `hostname` on `date`"
  echo
}

# Ask for yes or no answer - return 1 unless answer contains n|N
askyesno() {
  echo -n "$@ [Y|n] " ; read yesno
  case "$yesno" in
    n*|N*) return 1 ;;
    *) return 0 ;;
  esac
}

# Check if a lock file exists
# used by virt(), ali(), spam()
checklockf() {
    local lockfile=$1
    if [ -f $lockfile ] ; then
        echo lockfile found: $lockfile
        echo someone else is probably editing $file
        echo if this is not the case, please rm $lockfile
        return 1
    fi
    touch $lockfile
    return 0
}


###
###
##### Command aliases
### General command aliases - includes a few default flags and stuff
###
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
alias pmlog="mailstat ~/.pm/procmail.log | $PAGER"
alias xvbg="xv -root -rmode 5 -maxpect -quit" # set X background with xv
alias dotrc=". $shrc_home"
alias linusping="ping -p 6c696e7573" # sends "linus" as byte padding in packet
alias gwping="ping \`cat /etc/mygate\`" # pings default gateway according to /etc/mygate
alias suidfind="find / -perm -4000 -or -perm -2000"
alias calentool="calentool -D 2 -e" # ISO date format and week starts on monday
alias prtdiag='/usr/platform/`uname -i`/sbin/prtdiag' # Diag command on Suns
alias s_client="openssl s_client -connect" # "ssl telnet"
# Screen alias - if we're not in screen
if [ -z "$STY" ] ; then
  alias s="screen -R -D"
else
  alias s="echo 'You ARE already in screen, you muppet!'"
fi
# Disk usage related stuff
alias sdu="du -sk * | sort -n"
# allows running functions and aliases with sudo (eg, "runsudo m4mc")
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

### 
### File fetching aliases
### (only one remaing, because I never used them)
# Get the standard .bash_profile
alias bpget="test -f ~/.bash_profile || wwwget -q \
   $dotprofile_url >> ~/.bash_profile ; cat  ~/.bash_profile"
# Get a skeleton .local_shellrc
alias lsget="test -f ~/.local_shellrc || wwwget -q \
   $dlbase/local_shellrc >> ~/.local_shellrc ; cat  ~/.local_shellrc"

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
### Aliases used by root (or not used so frequently, to be precise)
### Kept mostly for nostalgic reasons ;-) I haven't used ipf or ftp in yonks
alias ipfr="sudo ipf -Fa -v -f /etc/ipf.rules > /dev/null"
alias ftpstart="sudo /usr/libexec/ftpd -D -A -l -l -U -S -h"
alias ftpstop="sudo kill \`cat /var/run/ftpd.pid\`"

###
##### Programmable command completion
###

# Only do this if the complete command exists (BASH 2.04 and later, methinks)
if complete > /dev/null 2>&1 ; then
  # Used to have a bunch of these, but got annoyed with most of them
  # now only keeping directories for cd, which I guess is kind of handy
  complete -d cd
fi

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

###
###
##### Functions / utils
### Some of these are old shell scripts or small perl scripts
### that are quite handy to have available on any host I might log in to


# A function for concatenating audio files. Supports any input formats that Sox supports, such as wav and MP3
# Works by converting all input files into raw format, concatenating the raw files,
# and then converting to the desired format
audioconcat(){
  # Put all temp files in their own directory - easy to clean up, and no permission issues as long as we've got temp space
  local tmpdir=/tmp/audioconcat.$$.tmp
  
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
  echo "Hostname:     $(hostname)"
  echo "OS:           $(uname -a)"
  echo "IP:           $(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | sed 's/\s*//')"
  if [ $(uname -s) = "Linux" ] ; then
    echo
    echo "Release info:"
    cat /etc/*release
  fi
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

# Expand a shortened URL, recursively
# Follows a chain of HTTP redirects, showing each hop, including the final destination
expandurl() { curl -sIL $1 | grep ^Location; }
# An alternative, using wget:
#expandurl() { wget -S $1 2>&1 | grep ^Location; }

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
    find $dir $args -exec du -sk {} \; | sort -n | perl -ne '($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}' | sed 's/\.\///'
    du -sh $dir
  done
}


# Create a directory or path, and go to it
mkcd() { mkdir -p $1 && cd $1; }

# Shred a file (similar to to "shred", which is common in Linux)
shredfile () {
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
xmlstrip() {
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
xmldiff() {
  if [ $# -ne 2 -o "$1" == "-h" ] ; then
    echo "Usage: $FUNCNAME file1 file2"
    return 1
  fi
    file1=$1
    file2=$2
    tmpfile1=/tmp/$FUNCNAME.$$.file1.tmp
    tmpfile2=/tmp/$FUNCNAME.$$.file2.tmp

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
mailshot() {
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
dosh() {
  local cmd=$*
  echo "Will run '$cmd' for every line entered"
  echo "Exit with EOF (normally CTRL-D) or CTRL-C"
  printf '> '
  while read input ; do
    # as long as $input isn't an empty string
    [ "$input" = "" ] || $cmd "$input"
  printf '> '
  done
  echo
}

# Looks at time stamps of files in the current directory, creating one
# directory per day, and moves the files into the daily directory
# This function is written entirely in Perl
# If the first argument is a date format, beginning with "+",
# use that format, otherwise use default
datedir() {
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
randpin() {
  # TODO: Should check for and avoid duplicates
  perl -w -e'
  use strict;
  my $pin_length = 4;
  my $quantity = 1;
  my $pin;
  my $_rand;

  # Can give the number of pins as an argument
  if ( $ARGV[0] ) { $quantity = $ARGV[0]; }

  my @chars = split(" ", "0 1 2 3 4 5 6 7 8 9");

  # Seed the random number generator
  srand;

  for ( my $i=0; $i < $quantity; ) {
    $pin = "";
    for (my $j=0; $j < $pin_length ; $j++) {
      $_rand = int(rand ($#chars + 1) );
      $pin .= $chars[$_rand];
     }
    # PIN must not have any repeated digits, or start with a 0
    unless ( $pin =~ /(.).*\1/ || $pin =~ /^0/ ) {
        print "$pin\n";
        $i++; # only increase counter if the pin was used
    }
    #else { print "Discarding: $pin\n"; }
  }
  ' $*
}
# Generates and prints a random password
# I use this to generate passwords for new users
randpass() {
  perl -w -e'
  use strict;
  my $password_length = 8;
  my $quantity = 1;
  my $password;
  my $_rand;

  # Can give the number of passwords as an argument
  if ( $ARGV[0] ) { $quantity = $ARGV[0]; }


  # Do not include characters that can easily be mistaken (e.g. l/1, 0/O)
  # make lowercase letters more likely by including more of them ;-)
  my @chars = split(" ",
  "a b c d e f g h i j k m n o p q r s t u v w x y z
  a b c d e f g h i j k m n o p q r s t u v w x y z
  a b c d e f g h i j k m n o p q r s t u v w x y z
  A B C D E F G H J K L M N P Q R S T U V W X Y Z
  2 3 4 5 6 7 8 9");

  # Seed the random number generator
  srand;


  for ( my $i=0; $i < $quantity; ) {
    $password = "";
    for (my $j=0; $j < $password_length ; $j++) {
      $_rand = int(rand ($#chars + 1) );
      $password .= $chars[$_rand];
     }
    # Password must include uppercase, lowercase, digit, otherwise skip
    # Also must not contain repeated characters
    if ( $password =~ /[a-z]/ && $password =~ /[A-Z]/ && $password =~ /[0-9]/ && $password !~ /(.)\1/ ) {
        print "$password\n";
        $i++; # only increase counter if the password was used
    }
    #else { print "REJECTING: $password\n"; }
  }
  ' $*
}

# sssh - function that uses screen_ssh, but is more suited to use interactively
sssh()
{
  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME [username@]hostname [ ssh flags ]"
    return 1
  fi
  local hostname=$1 ; shift
  local title=`echo $hostname | sed 's/\..*//'`

  # Run screen_ssh on the hostname, with the name shortened for the screen title
  # pass on any ssh flags as $*
  screen_ssh $hostname $title $*
}


# screen ssh, used by ssh host aliases
# eg: alias foo="screen_ssh foo"
# alias foo="screen_ssh foo.example.com foo"
# If running under screen, the ssh comand will be launched in a new window
# if not, it'll just run in the current shell
# if title is set, it will be used as the window title. otherwise,
# the hostname will be used as the title
screen_ssh () {
  if [ -z "$1" ] ; then
    echo "Usage: screen_ssh host [title [ssh flags]]"
    return 1
  fi
  local host=$1 ; shift
  if [ ! -z "$1" ] ; then title=$1 ; shift ; else title=$host ; fi
  # Any arguments after hostname and title are passed on to ssh
  sshflags="-C -o ServerAliveInterval=30 $*"
  # STY is set by screen if it's running
  if [ -z "$STY" ] ; then
    ssh $sshflags $host
  else
    screen -t $title ssh $sshflags $host
  fi
}

# Bad name, but rymes with wclock... helper function for wclock
# which can also be used on its own, eg tclock Europe/London
tclock () {
  TZ="$1" date
}

# World clock - prints date for some time zones that I tend to care about
wclock () {
  echo -n "California: " ; tclock America/Los_Angeles
  echo -n "New York:   " ; tclock America/New_York
  echo -n "UK:         " ; tclock Europe/London
  echo -n "Sweden:     " ; tclock Europe/Stockholm
  echo -n "Calcutta:   " ; tclock Asia/Calcutta
  echo -n "Tokyo:      " ; tclock Asia/Tokyo
  echo -n "Auckland:   " ; tclock Pacific/Auckland
}

# Calculate something by echo'ing it to bc -l
# using decimals, so 7/2 = 2.33... rather than 7/2 = 2
# See man page for bc for more info
calc () {
  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME expression"
    echo "Where expression is anything that bc will understand"
    return 1
  fi
  echo "$*" | bc -l
}

# Check spelling of a word (or bunch of words) passed as argument
# quicker than "echo word | spell" for checking one word 
sp () {
  echo $* | spell
}

# Search for something in Google, and dump the results
google () {
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME word" ; return 1 ; fi
  wwwdump "http://www.google.co.uk/search?hl=en&q=${*}" | $PAGER
}

# Look things up in Lexin
# To translate from English to Swedish - use "lexin :word"
# http://lexin.nada.kth.se/faq.shtml
lexin () {
  if [ -z "$1" ] ; then
    echo "Usage example: $FUNCNAME [:]word"
    echo "Prepending word with a colon looks up an English word"
    return 1
  fi
  wwwdump "http://lexikon.nada.kth.se/cgi-bin/sve-eng?${*}" | $PAGER
}

# Look up word in wikipedia
wp () {
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME word" ; return 1 ; fi
  wwwdump "http://en.wikipedia.org/wiki/${*}" | $PAGER
}
# Look up word in wictionary
wn () {
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME word" ; return 1 ; fi
  wwwdump "http://en.wiktionary.org/wiki/${*}" | $PAGER
}

# Use Google's define: search feature, to find definitions of a word
define () {
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME word" ; return 1 ; fi
  local word=$1
  wwwdump "http://www.google.co.uk/search?hl=en&q=define%3A${*}" | $PAGER
}

# gcalc() - Google Calculator
# FIXME: These bits were assuming a certain layout of the Google pages, and no longer works, since they've changed it.
# Currency and other conversion using Google
# gcalc 1 ft in cm, gcalc 140 mph in kph, etc
# Other examples:
# 54 miles per imperial gallon in litres per 10 kilometres
# 54 mpg in litres per 10 kilometres
# 1 uk gallon in litres
alias conv=gcalc
gcalc () {
  # Needs at least 1 argument - don't be too picky
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME 100 usd in gbp" ; return 1 ; fi
  local query=`echo "$*" | sed 's/ /+/g'`
  # echo query: $query
  wwwget "http://www.google.com/search?q=$query" | grep "/images/calc_img.gif" | sed 's#^.*<b>\(.*\)</b></h2>.*$#\1#' | sed 's/<[^>]*>//g'
}

# Conversion for some different currencies that I often use
# TODO: make a master function that splits currency pairs and figures
# out what to look up. Maybe these can then be made into aliases?
gbpsek() {
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME 100" ; return 1 ; fi
  gcalc $1 gbp in sek
}
sekgbp() {
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME 100" ; return 1 ; fi
  gcalc $1 sek in gbp
}
usdgbp() {
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME 100" ; return 1 ; fi
  gcalc $1 usd in gbp
}
gbpusd() {
  if [ -z "$1" ] ; then echo "Usage example: $FUNCNAME 100" ; return 1 ; fi
  gcalc $1 gbp in usd
}

# Strip out Carriage Return (CR) from a file
stripcr () {
  if [ -z "$1" ] ; then echo "Usage: stripcr <file>" ; return 1 ; fi
  local file=$1
  # backup
  mv -i $file $file.old || return 1
  tr -d '\015' < $file.old > $file
  echo "Done. Backed up to $file.old"
}

# Grep, using Perl regular expressions.
# TODO: Use this more often ;-)
pgrep () {
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
chmog() {
    if [ $# -ne 4 ] ; then
        echo "Usage: chmog mode owner group file"
        return 1
    else
        chmod $1 $4
        chown $2 $4
        chgrp $3 $4
    fi
}

chog () 
{ 
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
  
cddb() {
  # TODO: Usage, name
  mp3cddb *.mp3
  echo "Hit enter to update, ctrl-c to cancel"
  read foo
  mp3cddbtag cddbinfo.txt
  rm cddbinfo.txt
}

# mkisofs's a directory and cdrecord's it
# this was written for an OpenBSD desktop machine, should just need to change cdrdev to work on any machine with mkisofs and cdrecord
mkcdrom() {
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

dlget() {
  wwwget -q $dlbase/$1
}

sndvol() {
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
perlmv() {
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

termsize() {
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
sinfile() {
  if [ $# -lt 2 ] ; then echo "Usage: sinfile perlcode files" ; return 1 ; fi
  perl -i.old -p -e "$1" $2
}

# Set prompt(PS1) to s(hort) or long. Default is long
# TODO: integrate this with the case statement that sets PS1 according to $SHELL
# and make it work for shells that can't handle \u, etc
ps1() {
  case "$1" in 
    s*)
      PS1="\u@\h:(\W)\$ "
      export PS1
    ;;
    *)
      PS1="\u@\h:\w\$ "
      export PS1
    ;;
  esac
}

# search the OpenBSD ports, locally
psearch() {
  local oldpwd=`pwd`
  if ! cd /usr/ports ; then echo "You haven't got /usr/ports" ; return 1 ; fi
  make search key=$@
  cd $oldpwd
}

psgrep() {
  if [ $# -lt 1 ] ; then
    echo "Usage: psgrep pattern" ; return 1
  fi
  ps auxwww | grep $1 | grep -v grep # works on BSD'ish ps
} 

killall() {
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


jargon() {
  # Searches for a word in a local copy of the jargon file:
  # http://www.tuxedo.org/jargon/
  # The grep portion is a bit ugly, but gets the job done
  # TODO: Did I not know about shift and $* when I did this?
  searchsz=$1
  grepopts="$2 $3 $4 $5 $6 $7 $8 $9"
  grep="grep $grepopts"

  if ! [ -f $jargonfile ] ; then
    echo "Jargon File not found: $jargonfile"
    return 1
  fi

  if [ -z $searchsz ] ; then echo "Usage: jargon word" ; return 1 ; fi

  if ! $grep "^:${searchsz}:" $jargonfile ; then
   echo "$searchsz not found"
   return 1
  fi

  $grep -A 200 "^:${searchsz}:" $jargonfile | perl -e '\
  print "Searching the Jargon File for $ARGV[0]\n\n";
  my $word = "$ARGV[0]";
  #print "Perl looking for ($word)\n";
  while ( <STDIN> ) {
     if ( m/^:.*:/ ) { unless ( m/$word/ ) {exit;} }
      print;                                        
  } # while
  ' $searchsz | $PAGER # end perl
} # end jargon


pathadd() {
  # Function to save some typing when adding stuff to $PATH
  # This would have been cleaner if implemented in Perl,
  # but I don't want to require Perl for the bashrc to work

  # When used to initially set up path, we want it to be quiet
  local quiet=""
  if [ "$1" = "-q" ] ; then quiet=yes ; shift ; fi

  # Require at least one arg - the path to add
  if [ -z "$1" ] ; then
    echo "Usage: $FUNCNAME path"
    return 1
  fi

  # Go through the directories, and add them to $PATH if they exist
  while [ ! -z "$1" ] ; do
    local newdir=$1
    shift

    # Check that directory exists
    if [ -d $newdir ] ; then
      # Lame test to see if directory is already in path
      # Look for beginning-of-line or colon, followed by dir, followed by
      # colon or end-of-line. example: (^|:)/usr/local(:|$)
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

  # end with exporting PATH
  export PATH
}



keepalive() {
  # Used as a lame keepalive on ssh connections
  # might sometimes leave an annoying "." on the screen
  echo "Trying to keep connection alive"
  local sleeptime=60
  if [ ! -z $1 ] ; then sleeptime=$1 ; fi
  while sleep $sleeptime ; do printf "." ; printf "\\b" ; done
}

# The classic symmetric key encryption example ;-)
# Example: echo "Gur ohgyre qvq vg" | rot13
rot13() {
  if [ $# = 0 ] ; then
    # If there's no argument, read from stdin
    tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
  else
    # Assume that the first argument was a file, and apply to that
    tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
  fi
}

lowercase() {
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

swapfiles() {    
  # swap 2 filenames around
  local TMPFILE=tmp.$$
  mv -i $1 $TMPFILE
  mv -i $2 $1
  mv -i $TMPFILE $2
}


# Find a file with a pattern in name:
ff() { find . -name '*'$*'*' -ls ; }
# Same, case insensitive
ffi() { find . -iname '*'$*'*' -ls ; }
# Find a file with pattern $1 in name and Execute $2 on it:
fe() { find . -name '*'$1'*' -exec $2 {} \; ; }
# Same, case insensitive
fei() { find . -iname '*'$1'*' -exec $2 {} \; ; }
fstr() {
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
 
repeat() {
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

printn() {
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
dblcheck() {
  local address=$1
  local domain=$2
  if [ -z $dom ] ; then domain=dbl.dotcomfy.net ; fi
  revlookup $address $domain
}

revlookup() {
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
myip() {
  local url="$toolsbase/?action=myip"
  if [ $# -gt 0 ] ; then url="${url}$*" ; fi
  wwwget -q $url
}
# nmap myself from toolsbace
scanme() {
  local url="$toolsbase/?action=scan"
  if [ $# -gt 0 ] ; then url="${url}$*" ; fi
  wwwget -q $url
}

# ping myself from toolsbase
pingme() {
  local url="$toolsbase/?action=ping"
  wwwget -q $url
}

# trace myself from toolsbase
traceme() {
  local url="$toolsbase/?action=trace"
  wwwget -q $url
}

# connect to specified routeserver / looking glass
# mostly to keep a list of such handy...
alias lookingglass=routeserver
routeserver() {
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
mkimgindex() {
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
getpass() {
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
aestar() {

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

aescat() {
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

makerun() {
    local outfile
    outfile=`echo $1 | sed 's/\.c$//'`
    CFLAGS=-Wall make $outfile
    ./$outfile
}

# Lists Sun disk names on the two different forms:
# cXtXdX - sdX
# useful when looking at output from iostat -x
sdlist() {
    local tmp1=/tmp/sdlist_1.$$
    local tmp2=/tmp/sdlist_2.$$
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
screen() {
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

cd() {
  builtin cd "$@" && xtitle $USER@$HOSTNAME:$PWD
}

cdup() {
  popd && xtitle $USER@$HOSTNAME:$PWD
}

su(){
  xtitle "root@$HOSTNAME (su from $USER)"
  command su "$@"
  xbacktitle
}

vi () { 
  xtitle "vi $@ - ($USER@$HOSTNAME)";
  command vi $@;
  xbacktitle
}
 
make() {
  xtitle "$USER@$HOSTNAME: make $@ in $PWD"
  command make $@
  xbacktitle
}
 
rfc() {
  xtitle "$USER@$HOSTNAME: reading RFC $@"
  wwwget -q http://${1}.rfc.dotcomfy.net | $PAGER
  xbacktitle
}
 
man() {
  xtitle "$USER@$HOSTNAME: reading the manual for $@"
  command man $@
  xbacktitle
}
 
# These are a bit daft, and I tend to do everything in screen these days, so they're of little use
#telnet() {
#  xtitle "$USER@$HOSTNAME: telnet to $@"
#  command telnet $@
#  xbacktitle
#}
# 
#ssh() {
#  xtitle "SSH to $@"
#  command ssh $@
#  xbacktitle
#  welcomeback
#}
#
#ftp() {
#  xtitle "$USER@$HOSTNAME: ftp $@"
#  command ftp $@
#  xbacktitle
#}

top() {
  xtitle "Processes on $HOSTNAME"
  command $top $@
  xbacktitle
}


### A bunch of old shell scripts that used to be in /root/bin
### on a couple of OpenBSD boxes. Turned into functions.
### will rewrite these a bit better at some other time..

# Update quotes and stick in fortune
quoteget() {
  sudo sh -c "lynx -dump $dlbase/quotes.txt >/usr/share/games/fortune/linus"
  ( cd /usr/share/games/fortune ; sudo /usr/games/strfile linus )
}

# Rather than sending a hup
hupsendmail(){
  sudo sh -c 'kill `head -1 /var/run/sendmail.pid` ; sleep 1 ; /usr/libexec/sendmail/sendmail -L sm-mta -bd -q30m'
}

# m4mc - used to update sendmail.cf
m4mc() {
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

spam() {
    local name=spam
    local lockfile=/tmp/.$name.lock
    local file=/etc/mail/access
    if ! checklockf $lockfile ; then return 1 ; fi
    sudo vi $file
    rm $lockfile
    echo Press enter to rebuild database
    echo Or press ^C to exit
    read
    sudo makemap -v hash $file <$file > /dev/null
} # End of function spam()

virt(){
    local name=virt
    local lockfile=/tmp/.$name.lock
    local textfile=/etc/mail/virtusertable
    local dbfile=/etc/mail/virtusertable
    if ! checklockf $lockfile ; then return 1 ; fi
    sudo vi $textfile
    rm $lockfile
    echo Press enter to rebuild database
    echo Or press ^C to exit
    read
    sudo makemap -v hash $dbfile < $textfile > /dev/null
} # End of virt()

ali(){
    local name=ali
    local lockfile=/tmp/.$name.lock
    local file=/etc/mail/aliases
    if ! checklockf $lockfile ; then return 1 ; fi
    sudo vi $file
    rm $lockfile
    echo Press enter to rebuild database
    echo Or press ^C to exit
    read
    sudo newaliases
} # end of ali

# Written when apachectl on OpenBSD wouldn't support "restart" for SSL servers
huphttpd(){
    sudo apachectl stop
    sleep 1
    sudo apachectl startssl
}
# End of root/sudo specific functions



### Functions related to the editing, fetching, updating
### etc of .bashrc
### Some of these are also used as general supporting functions

# Check time since last successful update of this file
# Used by the update checker
shrc_check_age() {
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

# check version of .bashrc
shrc_check_ver() {
  grep "Id: \.bashrc" $shrc_home | sed "s/^# //"
}

# Print general version/age info
shrcinfo() {
  echo "Age:             `shrc_check_age` days"
  echo "Update after:    $shrc_max_age days"
  echo "Current version: `shrc_check_ver`"
  echo "Sections:"
  grep "^##### " $shrc_home | sed 's/^##### / - /'
}

# Updates the base .bashrc (or whatever it's stored as locally)
shrcupd() {
  updatefile $shrc_home $shrc_url || updatefile $shrc_home $backup_url
}

# Updates a file from the web repository
# Two arguments:
#  - the local path to the file to update
#  - the URI of the file to get
updatefile() {
  file_home=$1
  file_www=$2
  if [ ! -w $file_home ] ; then
    echo "$file_home is not writeable, you probably don't want to do that"
    echo "I'll just . it for you"
    . $file_home
    return 1
  fi
  #wwwget -q $file_www > $file_tmp
  # TODO: Write a retry loop with wget, lynx, wwwget, curl, etc
  # TODO: If SSL fails, then fall back on plaintext HTTP, grabbing the file from dotcomfy.net
  wget  -q -O $file_tmp --no-check-certificate $file_www
  if [ $? -ne 0 ] ; then
    echo "wget failed retrieving file, will try cURL"
    curl  -sL -o $file_tmp $file_www
    if [ $? -ne 0 ] ; then
      echo "cURL failed retrieving file, will try lynx"
      lynx -dump -source $file_www > $file_tmp
      if [ $? -ne 0 ] ; then
        echo "Doh, I couldn't get the new bashrc, giving up"
        return 1
      fi
    fi
  fi
  if diff $file_home $file_tmp ; then
    echo "You already have the most recent version."
    shrc_check_ver
    rm $file_tmp
  else
    echo "Current version: `shrc_check_ver`"
    if askyesno "Update to newest version, according to diff?" ; then
      mv $file_tmp $file_home
      echo "Updated to most recent version."
      shrc_check_ver
    else
      echo "OK, will update later."
      rm $file_tmp
    fi
  fi
  # Register that it's updated
  perl -e 'print time();' > $shrc_age_file
  # source the current .${SHELL}rc file
  . $file_home
  return 0
}

# Check a file out from RCS, edit, show diff, check back in
# Used by vishrc
editfile() {
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

### Quite large Perl snipplets, wrapped as shell functions
### These are best off stuffed away at the bottom of the .bashrc
###

smtpclient() {
$perl - $* <<"ENDOFSMTPCLIENTPERL" 
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
my $port = 25;                     # Default SMTP port

# Get command-line options.
getopts('bhH:p:s:', \%opts);

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

$headers{'Subject'} = $opts{s} || "Test from <$from> to <$to> via $server on $date";
chomp ( $heloname = $opts{H} || `hostname` || "foo" );

if ( $opts{b} ) {
    print "Enter mail, end with EOF (CTRL-D)\n";
    @mailbody = <STDIN>; 
    print "\nOk, full mail recieved, will now try to send it\n\n";
}
else {
    $mailbody[0] = "Test from <$from> to <$to> via $server on $date";
}

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
    $response = <$sock>;
    print "<<< $response";
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
-s <subject> Specifies the subject line.

ENDUSAGE
    exit(0);
}# usage
ENDOFSMTPCLIENTPERL
} # end of smtpclient() shell function


dfk() {
$perl - $* <<"ENDOFDFKPERL" 
# dfk.pl - proper formatting of df -k output
# Original by Brian Peasland


@vol_list = ();               # Array to hold list of volumes
@head_list = qw(Volume Kbytes Used Avail Capacity); # Array to hold header information

#Set up lengths of columns and format mask for output
#If the column needs more room (for instance, you just added a 1TB volume), then
#just increase the variable below and all formatting will hold. 
$vol_len = 20;
$byte_len = 11;
$cap_len = 8;
$fs_len = 0;
#All output uses this format mask. This makes life nice and formatted for 
#better readability.
$format_mask = "%-".$vol_len."s %".$byte_len."s  %".$byte_len."s  %".$byte_len."s %"
                .$cap_len."s %-".$fs_len."s\n";

#
# Get output from "df -k" command
#

$loop_ctr = 0;
foreach $_ (`df -lk`) {
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

wwwget() {
# wwwget - fetch a url and print on stdout, including request and headers.
# The actual script is being kept in CVS (scripts/wwwget.pl)
#
# The only changes that need to be made to the wwwget code after copying
# is removing the $'s from the RCS Id tag, and Revision from $version
# 
# Everything after the "-" is passed on to the script, so  any arguments
# passed to the function wwwget are passed on to the Perl script

$perl - $* <<"ENDOFWWWGETPERL" 
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
                                            SSL_passwd_cb => sub { return "opossum" }) ) {
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
    unless ($quiet) { print "Client request:\n\n"; }

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

    unless ( $quiet ){ print "Server response:\n\n"; }
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
if [ -f ~/.rvm/scripts/rvm ] ; then
  echo "Loading rvm..."
  source ~/.rvm/scripts/rvm
fi

# This is just so that the Darwin-specific top options work with the top() function later on...
top="top"
### OpenBSD
if echo $OSTYPE | grep "openbsd" > /dev/null ; then
  PKG_PATH=ftp://ftp.sunet.se/pub/OpenBSD/`uname -r`/packages/`uname -m`/
  export PKG_PATH
fi
### GNU/Linux
if [ "$OSTYPE" = "linux-gnu" ] ; then
  alias grep="grep --color=auto"
fi
### OSX / Darwin
if echo $OSTYPE | grep "darwin" > /dev/null ; then
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

#
## Git stuff
#
# I think I might start organising things more by subject, rather than functions and aliases separately

# git commit & push
alias gcp="git commit -a ; git push origin master"

# Set a prompt for when inside a git repo
git_prompt(){
  if ref=$(git symbolic-ref HEAD 2>/dev/null) ; then
    # Colour it red if there are changes to be committed, otherwise green
    if current_git_status=$(git status | grep 'added to commit' 2>/dev/null); then
      COLOUR=$RED
    else
      COLOUR=$GREEN
    fi
    printf "$COLOUR("${ref#refs/heads/}")$ENDCOLOUR"
  else
    return 1
  fi
}

# Special cases for different shells
case "$SHELL" in
    */bash) 
        set -o notify 
        set -o emacs
        PS1="\u@\h:\w\$(git_prompt)\$ "
        ;;
    */ksh)
        set -o notify 
        set -o emacs
        PS1="$USER@$(hostname):\$PWD\$ "
        ;;
    */sh)
        PS1="$USER@$(hostname):\$PWD\$ "
        ;;
esac

# indicate that the shell is running under sudo, if it is
if ! [  -z "$SUDO_USER" ] ; then PS1="(sudo)${PS1}" ;fi

# Set the terminal/ssh client title to the default
xbacktitle

# Check the age of the file, and suggest updating if it's too old
shrc_age=`shrc_check_age`
# $noupdateshrc can be set to 1 in .local_shellrc to disable auto updating
if [ $shrc_age -gt $shrc_max_age -a -z "$noupdateshrc" ] ; then
    if askyesno "Your .bashrc is $shrc_age days old, do you want to update?" ; then
      shrcupd
    else
      echo "OK, will update later."
    fi
    
fi

# Display user's own motd, if one exists
# But only do this for the first shell, not sub shells
[ -f ~/.motd -a -z "$motd_done" ] && cat ~/.motd
motd_done=1 ; export motd_done

# source .local_shellrc if existent, last in file, to override globals 
[ -f ~/.local_shellrc ] && . ~/.local_shellrc

# This version of the file was downloaded from github
# EOF
