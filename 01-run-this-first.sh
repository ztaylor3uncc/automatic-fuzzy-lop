#!/bin/bash

ERROR='\033[0;31m'
INFO='\033[1;34m'
NC='\033[0m'

clear

echo -e "${INFO}Welcome to the dependency script for FOCS!${NC}"
echo -e "${INFO}Some quick notes beore you get started...${NC}"
echo -e "${INFO}Text in blue is helpful information you should probably read!${NC}"
echo -e "${ERROR}Text in red indicates that something did not go as planned...${NC}"
echo -e "${NC}White text is typically just output from a currently running command.${NC}"
echo -e "${INFO}The very first thing you will be asked to do after confirming you want to continue${NC}"
echo -e "${INFO}is you will be asked for your sudo password. If you are not a sudoer, this is probably${NC}"
echo -e "${INFO}not something you should be tinkering with.${NC}"
echo -e "${INFO}${NC}"
echo -e "${INFO}Also, this script has currently only been tested on limited Linux distros.${NC}"
echo -e "${INFO}The script will check what distro you're running and if it is supported.${NC}"
echo -e "${INFO}If it is not supported, I will direct you to file in the docs directory 'how_to_do_manually_what_FOCS_is_doing_for_you.txt'${NC}"
echo -e "${INFO}Press 'q' to quit or enter any other key to continue...${NC}"

read x

if [ $x == 'q' ]; then
	echo -e "${INFO}Probably a good decision...${NC}" && exit 1
fi

#go ahead and get sudo
sudo cat /etc/*elease | grep -i pretty_name= | cut -d '=' -f 2 | sed "s/\"//g"

DESK=$(cat /etc/*elease | grep -i pretty_name= | cut -d '=' -f 2 | sed "s/\"//g")

case $DESK in
	"Slackware 14.2")
		echo -e "${INFO}It looks like you are running this script on $DESK${NC}"
		echo -e "${INFO}This version of the script requires certain dependencies.${NC}"
		echo -e "${INFO}Unfortunately, Slackware doesn't have a great way to easily install dependencies.${NC}"
		echo -e "${INFO}Check the 01 script for a commented line about how to install${NC}"
		echo -e "${INFO}Press 'q' to quit and edit the script or any other key to continue...${NC}"
		read x;
		;;
	"Debian GNU/Linux 10 (buster)")
		echo -e "${INFO}It looks like you are running this script on $DESK${NC}"
		echo -e "${INFO}If you haven't already uncommented the dependency line for $DESK in this script${NC}"		
		echo -e "${INFO}please do that now. If you haven't done this yet, press 'q', otherwise,${NC}"
		echo -e "${INFO}press any other key.${NC}"
		read x;
		;;
	*)
		echo -e "${INFO}You are running this script on an untested distribution.${NC}"		
		echo -e "${INFO}Most of my scripts are POSIX complient, so this shouldn't be an issue;${NC}"	
		echo -e "${INFO}however, AFL itself is finnicky, so you may have an issue with the make${NC}"	
		echo -e "${INFO}command. To quit now, hit 'q', otheriwse, enter any other key to continue.${NC}"	
		read x
		;;
esac


if [ $x == 'q' ]; then
	echo -e "${ERROR}Probably a good decision...${NC}" && exit 1
fi

# Dependency line for Debian GNU/Linux 10 (buster)
{ sudo apt install -y git wget python coreutils binwalk qemu-user libtool wget python autoconf libtool-bin automake bison libglib2.0-dev && echo -e "${INFO}Installing dependencies...${NC}"; } || { echo -e "${ERROR}Uh oh... issue installing dependencies....${NC}" && exit 1; }

# Dependencies specifically for sasquatch
#sudo apt-get install -y build-essential liblzma-dev liblzo2-dev zlib1g-dev

# if you are running slackpkg, make sur eyou have the dependencies (almost all can be foun in slackpkg+ repos)
# qemu python3 bison automake git wget binwalk
# (additional note: binwalk requires python3, which is the only reason why we are installing this)

THISDIR="$(echo $PWD)"

# Grab latest version of AFL
{ wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz && echo -e "${INFO}Grabbing the latest version of AFL from Michal... Thanks, Mr. Zalewski!${NC}"; } || { echo -e "${ERROR}Whoops... Problem grabbing the latest AFL! Google lcamtuf to find out why!${NC}" && exit 1; }

# Unpack it
{ tar -xvf afl-latest.tgz && echo -e "${INFO}Unpacking the tarball of AFL${NC}"; } || { echo -e "${RED}Issue unpacking the tarball... Could be an issue with the script?${NC}" && exit 1; }

# This is to future proof the script (in case the latest version changes)
rm afl-latest.tgz
mv afl* afl/
cd afl/ #clever, huh?

echo -e "${INFO}If you see this, everything is going fine so far....${NC}" || { echo -e "${ERROR}Yikes... If you see this there was a very terrible system error...${NC}" && exit 1; }

# We have to make it before we do anything else 
# (for reasons we can talk about, but are outside the scope
# of these comments...).
{ sudo make && echo -e "${INFO}Yeah! The make command ran great!${NC}"; } || { echo -e "${ERROR}Issue with the make command. Scroll up for details...${NC}" && exit 1; }

{ cd qemu_mode && echo -e "${INFO}qemu_mode directory is where it's supposed to be...${NC}"; } || { echo -e "${ERROR}qemu_mode directory is not where it's supposed to be...${NC}" && exit 1; }

# Decided to host my own version of QEMU
# So I've commented out the lines to grab a new copy
VERSION="2.10.0"
QEMU_URL="http://download.qemu-project.org/qemu-${VERSION}.tar.xz"
QEMU_SHA384="68216c935487bc8c0596ac309e1e3ee75c2c4ce898aab796faa321db5740609ced365fedda025678d072d09ac8928105"
cd qemu_mode
# Dealing with QEMU now
if [ ! "`uname -s`" = "Linux" ]; then
  echo -e "${ERROR}QEMU instrumentation is supported only on Linux.${NC}" && exit 1
fi

if [ ! -f "patches/afl-qemu-cpu-inl.h" -o ! -f "../config.h" ]; then
  echo -e "${ERROR}Key files not found - wrong working directory?${NC}" && exit 1
fi

if [ ! -f "../afl-showmap" ]; then
  echo -e "${ERROR}../afl-showmap not found - compile AFL first!${NC}" && exit 1
fi

ARCHIVE="`basename -- "$QEMU_URL"`"
CKSUM=`sha384sum -- "$ARCHIVE" 2>/dev/null | cut -d' ' -f1`

if [ ! "$CKSUM" = "$QEMU_SHA384" ]; then

  echo -e "${RED}[*] Downloading QEMU ${VERSION} from the web...${NC}"
  rm -f "$ARCHIVE"
  wget -O "$ARCHIVE" -- "$QEMU_URL" || exit 1

  CKSUM=`sha384sum -- "$ARCHIVE" 2>/dev/null | cut -d' ' -f1`

fi

if [ "$CKSUM" = "$QEMU_SHA384" ]; then

  echo -e "${INFO}[+] Cryptographic signature on $ARCHIVE checks out.${NC}"

else

  echo -e "${ERROR}[-] Error: signature mismatch on $ARCHIVE (perhaps download error?).${NC}"
  exit 1

fi

echo -e "${INFO}[*] Uncompressing archive (this will take a while)...${NC}"

rm -rf "qemu-${VERSION}" || exit 1
tar xf "$ARCHIVE" || exit 1

cd qemu-*/ || exit 1

echo -e "${INFO}[*] Applying patches..."

patch -p1 <../patches/elfload.diff || exit 1
patch -p1 <../patches/cpu-exec.diff || exit 1
patch -p1 <../patches/syscall.diff || exit 1

echo -e "${INFO}Patching done.${NC}"

cd $THISDIR

mkdir firmware-library/

echo -e "${INFO}################################################${NC}"
echo -e "${INFO}#   All done with Dependencies and AFL make.   #${NC}"
echo -e "${INFO}#         Find a target and auto-fuzz!         #${NC}"
echo -e "${INFO}################################################${NC}"
