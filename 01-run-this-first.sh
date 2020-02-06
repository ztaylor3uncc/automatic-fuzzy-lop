#!/bin/bash

ERROR='\033[0;31m'
INFO='\033[1;34m'
NC='\033[0m'
ACT='\033[40m\033[32m'

dependency () {
	clear

	echo -e "${INFO}${NC}"
	echo -e "${INFO}Some quick notes beore you get started...${NC}"
	echo -e "${INFO}Text in blue is helpful information you should probably read!${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${ERROR}Text in red indicates that something did not go as planned...${NC}"
	echo -e "${NC}White text is typically just output from a currently running command.${NC}"
	echo -e "${ACT}Green text on black background means you have to do something!${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${INFO}The very first thing you will be asked to do after confirming you want to continue${NC}"
	echo -e "${INFO}is you will be asked for your sudo password. If you are not a sudoer, this is probably${NC}"
	echo -e "${INFO}not something you should be tinkering with.${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${INFO}Also, this script has currently only been tested on limited Linux distros.${NC}"
	echo -e "${INFO}The script will check what distro you're running and if it is supported.${NC}"
	echo -e "${INFO}If it is not supported, I will direct you to file in the docs directory 'how_to_do_manually_what_FOCS_is_doing_for_you.txt'${NC}"
	echo -e "${ACT}Press 'q' to quit or enter any other key to continue...${NC}"

	read x

	if [ $x == 'q' ]; then
		clear
		echo -e "${INFO}Probably a good decision...${NC}" && exit 1
		echo -e "${INFO}${NC}"
		echo -e "${INFO}${NC}"
		echo -e "${INFO}${NC}"
	fi

	DESK=$(sudo cat /etc/*elease | grep -i pretty_name= | cut -d '=' -f 2 | sed "s/\"//g")

	which afl-fuzz

	VAL01=$(echo $?)
	VAL02=$(if [ -d /usr/share/focs/ ] && [ -d /usr/share/focs/afl/ ] && [ -d /usr/share/focs/firmware-library/ ]; then echo 0; else echo 1; fi)
	VAL03=$(( $VAL01 + $VAL02 ))

	if [ $VAL03 -eq 0 ]; then
		echo -e "${INFO}You have both afl-fuzz installed and an existing and recognizable '/usr/share/focs/' directory,${NC}"
		echo -e "${INFO}so we are skipping the preliminary install phase assuming it has been done previously${NC}" || sleep 2
	fi

	if [ ! $VAL03 -eq 0 ]; then
<<<<<<< HEAD
		
		if [ -d /usr/share/focs/ ]; then
			clear
			echo -e "${INFO}The file /usr/share/focs/ exists.${NC}"
			echo -e "${INFO}If it exists for a reason that isn't this, quit by pressing 'q'.${NC}"
			echo -e "${ACT}Otherwise, enter any key to continue.${NC}"
			
			read x

			if [ $x == 'q' ]; then
				clear
				echo -e "${INFO}Wise choice...${NC}" && exit 1
			fi
		else
			sudo mkdir /usr/share/focs/
		fi

		sudo mkdir /usr/share/focs/firmware-library/
		
=======
		
		if [ -d /usr/share/focs/ ]; then
			clear
			echo -e "${INFO}The file /usr/share/focs/ exists.${NC}"
			echo -e "${INFO}If it exists for a reason that isn't this, quit by pressing 'q'.${NC}"
			echo -e "${ACT}Otherwise, enter any key to continue.${NC}"
			
			read x

			if [ $x == 'q' ]; then
				clear
				echo -e "${INFO}Wise choice...${NC}" && exit 1
			fi
		else
			sudo mkdir /usr/share/focs/
		fi

		sudo mkdir /usr/share/focs/firmware-library/
		
>>>>>>> 951a9a64ee174425f75d5ae7458e33f07c60e71c
		clear

		case $DESK in
			"Slackware 14.2")
				echo -e "${INFO}It looks like you are running this script on $DESK${NC}"
				echo -e "${INFO}This version of the script requires certain dependencies.${NC}"
				echo -e "${INFO}Unfortunately, Slackware doesn't have a great way to easily install dependencies without additions,${NC}"
				echo -e "${INFO}but here is a list of the dependencies that have been identified so far (please, let me know if you find others):${NC}"
				# if you are running slackpkg, make sure you have the dependencies (almost all can be foun in slackpkg+ repos)
				echo -e "${INFO}qemu python3 bison automake git wget binwalk${NC}"
				# (additional note: binwalk requires python3, which is the only reason why we are installing this)
				echo -e "${INFO}${NC}"	
				echo -e "${INFO}Most of these can be installed from the slackpkg+ repositories.${NC}"
				echo -e "${INFO}${NC}"
				echo -e "${ACT}Press 'q' to quit and check the script or any other key to continue...${NC}"
				read x;
				;;
			"Debian GNU/Linux 10 (buster)")
				echo -e "${INFO}It looks like you are running this script on $DESK${NC}"
				echo -e "${INFO}If you don't want to install the dependencies for some reason, press 'q', otherwise,${NC}"
				echo -e "${INFO}press any other key to continue with the installation.${NC}"
				read x;

				if [ $x == 'q' ]; then
					clear
					echo -e "${INFO}Well, it was worth a shot...${NC}" && exit 1
				else 
					{ sudo apt install -y git wget python coreutils binwalk qemu-user libtool wget python autoconf libtool-bin automake bison libglib2.0-dev && echo -e "${INFO}Installing dependencies...${NC}"; } || { echo -e "${ERROR}Uh oh... issue installing dependencies....${NC}" && exit 1; }
				fi
				;;
			*)
				echo -e "${INFO}You are running this script on an untested distribution.${NC}"		
				echo -e "${INFO}Most of my scripts are POSIX complient, so this shouldn't be an issue;${NC}"	
				echo -e "${INFO}however, AFL itself is finnicky, so you may have an issue with the 'make' or some dependencies.${NC}"	
				echo -e "${INFO}command. To quit now, hit 'q', otheriwse, enter any other key to continue.${NC}"	
				read x
				;;
		esac


		if [ $x == 'q' ]; then
			clear
			echo -e "${INFO}Probably a good decision...${NC}" && exit 1
		fi

		# Dependencies specifically for sasquatch
		#sudo apt-get install -y build-essential liblzma-dev liblzo2-dev zlib1g-dev

		THISDIR="$(echo $PWD)"

		# Grab latest version of AFL
		# Commenting this out to host my own version of afl and qemu
		# or, rather, an unchanging version
		#{ wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz && echo -e "${INFO}Grabbing the latest version of AFL from Michal... Thanks, Mr. Zalewski!${NC}"; } || { echo -e "${ERROR}Whoops... Problem grabbing the latest AFL! Google lcamtuf to find out why!${NC}" && exit 1; }


		# Unpack it
		#{ tar -xvf afl-latest.tgz && echo -e "${INFO}Unpacking the tarball of AFL${NC}"; } || { echo -e "${RED}Issue unpacking the tarball... Could be an issue with the script?${NC}" && exit 1; }

		# This is to future proof the script (in case the latest version changes)
		#rm afl-latest.tgz
		#mv afl* afl/
		cd afl/ #clever, huh?

		echo -e "${INFO}If you see this, everything is going fine so far....${NC}" || { echo -e "${ERROR}Yikes... If you see this there was a very terrible system error...${NC}" && exit 1; }
<<<<<<< HEAD

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

=======

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

>>>>>>> 951a9a64ee174425f75d5ae7458e33f07c60e71c
		echo -e "${INFO}[*] Applying patches..."

		patch -p1 <../patches/elfload.diff || exit 1
		patch -p1 <../patches/cpu-exec.diff || exit 1
		patch -p1 <../patches/syscall.diff || exit 1

		echo -e "${INFO}Patching done.${NC}"

		cd $THISDIR
	fi

	echo -e "${INFO}${NC}"
	echo -e "${INFO}################################################${NC}"
	echo -e "${INFO}     All done with Dependencies and AFL make.   ${NC}"
	echo -e "${INFO}################################################${NC}"
}

extract () {
	clear

	echo -e "${INFO}Running the extract script for FOCS${NC}"
	echo -e "${INFO}This script attempts to extract the firmware from the firmware image${NC}"
	echo -e "${INFO}and identify its architecture. It also attempts to compile AFL to work${NC}"
	echo -e "${INFO}with the identified architecture.${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${INFO}This can throw some issues, and this is certainly the part that has the${NC}"
	echo -e "${INFO}most trouble across Linix distros. If you are moving ahead with an unsupported${NC}"
	echo -e "${INFO}distribution, be very wary of error messages from the system, as my error messages${NC}"
	echo -e "${INFO}are typically only catching issues with this script itself and not things like the${NC}"
	echo -e "${INFO}'make' command.${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${ACT}If you would like to quit to do some testing, enter 'q', otherwise, enter any other key to continue...${NC}"

	read x

	if [ $x == 'q' ];then
		echo -e "${INFO}For the best...${NC}" && exit 1
	fi

	sudo mv $1 /usr/share/focs/ || { echo -e "${ERROR}Couldn't move the file to the /usr/share/focs directory... check that it exists already.${NC}" && exit 1; };
<<<<<<< HEAD

	cd /usr/share/focs/ || { echo -e "${ERROR}Issue jumping into the /usr/share/focs directory. Check that it exists.${NC}" && exit 1; };
	sudo binwalk -e /usr/share/focs/$1 || { echo -e "${ERROR}Unfortunately, binwalk threw an issue... This can't be fixed by me, I'm afraid...${NC}" && exit 1; }; 

	find _*/ -name 'bin'

=======

	cd /usr/share/focs/ || { echo -e "${ERROR}Issue jumping into the /usr/share/focs directory. Check that it exists.${NC}" && exit 1; };
	sudo binwalk -e /usr/share/focs/$1 || { echo -e "${ERROR}Unfortunately, binwalk threw an issue... This can't be fixed by me, I'm afraid...${NC}" && exit 1; }; 

	find _*/ -name 'bin'

>>>>>>> 951a9a64ee174425f75d5ae7458e33f07c60e71c
	ISSUE=$(echo "$?")

	if [ "$ISSUE" -eq 0 ]
	then
		echo -e "${INFO}Awesome! binwalk extracted the image perfectly!${NC}"
	else
		echo -e "${ERROR}Darn... binwalk didn't extract the image perfectly...${NC}" && exit 1
	fi;
<<<<<<< HEAD

	THEDIR="$(find _*/ -name 'bin' | sort | head -1)"
	THISDIR="$(echo $PWD)"
	THEARCH="$(file -b -e elf $THEDIR/* | grep -o ','.*',' | tr -d ' ' | tr -d ',' | uniq | tr '[:upper:]' '[:lower:]')"
	NEWDIR="$(echo '/usr/share/focs/firmware-library/'$THEARCH$(echo _*/))"

	sudo mkdir $NEWDIR || { echo -e "${ERROR}The NEWDIR variable is wrong... Check the script${NC}" && exit 1; }

	in="in/"
	out="out/"

	sudo mkdir $NEWDIR$in
	sudo mkdir $NEWDIR$out

	{ sudo cp $(find /usr/share/focs/afl/testcases/ -type f) $NEWDIR$in; } || { echo -e "${ERROR}Issue copying the test cases over to the new directory. This is probably an issue with the script. Email ztaylor3@uncc.edu to resolve.${NC}" && exit 1; }

	scrpt="auto-fuzz.sh"
	dr="auto-fuzz"

	sudo ln -s $PWD$scrpt $NEWDIR$dr

	sudo mv $1 $NEWDIR || { echo -e "${ERROR}Issue moving the img file to the new directory${NC}" && exit 1; }

	sudo cp -r _*/* $NEWDIR/ || { echo -e "${ERROR}Issue copying everything into the newly created directory.${NC}" && exit 1; }

=======

	THEDIR="$(find _*/ -name 'bin' | sort | head -1)"
	THISDIR="$(echo $PWD)"
	THEARCH="$(file -b -e elf $THEDIR/* | grep -o ','.*',' | tr -d ' ' | tr -d ',' | uniq | tr '[:upper:]' '[:lower:]')"
	NEWDIR="$(echo '/usr/share/focs/firmware-library/'$THEARCH$(echo _*/))"

	sudo mkdir $NEWDIR || { echo -e "${ERROR}The NEWDIR variable is wrong... Check the script${NC}" && exit 1; }

	in="in/"
	out="out/"

	sudo mkdir $NEWDIR$in
	sudo mkdir $NEWDIR$out

	{ sudo cp $(find /usr/share/focs/afl/testcases/ -type f) $NEWDIR$in; } || { echo -e "${ERROR}Issue copying the test cases over to the new directory. This is probably an issue with the script. Email ztaylor3@uncc.edu to resolve.${NC}" && exit 1; }

	scrpt="auto-fuzz.sh"
	dr="auto-fuzz"

	sudo ln -s $PWD$scrpt $NEWDIR$dr

	sudo mv $1 $NEWDIR || { echo -e "${ERROR}Issue moving the img file to the new directory${NC}" && exit 1; }

	sudo cp -r _*/* $NEWDIR/ || { echo -e "${ERROR}Issue copying everything into the newly created directory.${NC}" && exit 1; }

>>>>>>> 951a9a64ee174425f75d5ae7458e33f07c60e71c
	sudo rm -rf _*/ || { echo -e "${ERROR}Error removing the firmware folder... Check script for where folder was created/supposed to be.${NC}" && exit 1; }

	export CPU_TARGET="$(echo $THEARCH)"

	cd afl/qemu_mode/

	ORIG_CPU_TARGET="$CPU_TARGET"

	test "$CPU_TARGET" = "" && CPU_TARGET="`uname -m`"
	test "$CPU_TARGET" = "i686" && CPU_TARGET="i386"

	cd qemu-*/ || { echo -e "${ERROR}The qemu directory isn't where it's supposed to be. Or your PWD is screwy.${NC}" && exit 1; }

	CFLAGS="-O3 -ggdb" 

	sudo ./configure --disable-system --enable-linux-user --disable-gtk --disable-sdl --disable-vnc --target-list="${CPU_TARGET}-linux-user" --enable-pie --enable-kvm || { echo -e "${ERROR}Failure configuring the QEMU files. Check the /usr/share/focs/afl/qemu_mode/ directory.${NC}" && exit 1; }

	echo "${INFO}Configuration complete.${NC}"

	echo "${INFO}Attempting to build QEMU (fingers crossed!)...${NC}"

	sudo make || { echo -e "${ERROR}Error with the make command for QEMU mode. Check the /usr/share/focs/afl/qemu_mode directory or the script or, idk...${NC}" && exit 1; }

	echo "${INFO}Build process successful!${NC}"

	echo "${INFO}Copying binary...${NC}"

	sudo cp -f "${CPU_TARGET}-linux-user/qemu-${CPU_TARGET}" "../../afl-qemu-trace" || exit 1

	cd ..
	ls -l ../afl-qemu-trace || exit 1

	echo "${INFO}Successfully created '../afl-qemu-trace'.${NC}"

	if [ "$ORIG_CPU_TARGET" = "" ]; then

	  echo "${INFO}Testing the build...${NC}"

	  cd ..

	  make >/dev/null || exit 1

	  gcc test-instr.c -o test-instr || exit 1

	  unset AFL_INST_RATIO

	  echo 0 | ./afl-showmap -m none -Q -q -o .test-instr0 ./test-instr || exit 1
	  echo 1 | ./afl-showmap -m none -Q -q -o .test-instr1 ./test-instr || exit 1

	  rm -f test-instr

	  cmp -s .test-instr0 .test-instr1
	  DR="$?"

	  rm -f .test-instr0 .test-instr1

	  if [ "$DR" = "0" ]; then

	    echo "${ERROR}[-] Error: afl-qemu-trace instrumentation doesn't seem to work!${NC}"
	    exit 1

	  fi

	  echo "${INFO}[+] Instrumentation tests passed.${NC}"
	  echo "${INFO}[+] All set, you can now use the -Q mode in afl-fuzz!${NC}"
<<<<<<< HEAD

	else

	  echo "${INFO}[!] Note: can't test instrumentation when CPU_TARGET set."

	fi

	cd ..

	{ sudo make install && echo -e "${INFO}Running make install... likeliness to fail is higher here...${NC}"; } || { echo -e "${ERROR}Uh oh... there was a problem with make install... Scroll up for error details${NC}" && exit 1; }

	cd $THISDIR

	echo -e "${INFO}#################################################${NC}"
	echo -e "${INFO}      You only need to run this file again       ${NC}"
	echo -e "${INFO} if you change the architecture you are fuzzing. ${NC}"
	echo -e "${INFO}#################################################${NC}"
}

library () {
	clear

	echo -e "${INFO}Type the name of the firmware image you would like to fuzz:${NC}"

	for f in $(ls /usr/share/focs/firmware-library); do
		f="${f%.*}"
		echo $f | cut -d _ -f 2  
	done

	read file

	echo -e "${INFO}${NC}"

=======

	else

	  echo "${INFO}[!] Note: can't test instrumentation when CPU_TARGET set."

	fi

	cd ..

	{ sudo make install && echo -e "${INFO}Running make install... likeliness to fail is higher here...${NC}"; } || { echo -e "${ERROR}Uh oh... there was a problem with make install... Scroll up for error details${NC}" && exit 1; }

	cd $THISDIR

	echo -e "${INFO}#################################################${NC}"
	echo -e "${INFO}      You only need to run this file again       ${NC}"
	echo -e "${INFO} if you change the architecture you are fuzzing. ${NC}"
	echo -e "${INFO}#################################################${NC}"
}

library () {
	clear

	echo -e "${INFO}Type the name of the firmware image you would like to fuzz:${NC}"

	for f in $(ls /usr/share/focs/firmware-library); do
		f="${f%.*}"
		echo $f | cut -d _ -f 2  
	done

	read file

	echo -e "${INFO}${NC}"

>>>>>>> 951a9a64ee174425f75d5ae7458e33f07c60e71c
	file $(find /usr/share/focs/firmware-library/*$file*/ -type f -executable) | grep -i 'executable' | awk -F: '{print $1}' | sed 's:.*/::' | sort

	read target

	DIR=$(find /usr/share/focs/firmware-library/arm_backup.bak.extracted/ -name $target)

	qemu-$THEARCH $DIR --help || qemu-$THEARCH $DIR -h

	read args

	auto-fuzz $DIR $args
}


auto-fuzz () {
<<<<<<< HEAD


}

main () {
	clear

	echo -e "${INFO}${NC}"

	echo -e "$INFO  ███████╗ ██████╗  ██████╗███████╗  ${NC}"
	echo -e "$INFO  ██╔════╝██╔═══██╗██╔════╝██╔════╝  ${NC}"
	echo -e "$INFO  █████╗  ██║   ██║██║     ███████╗  ${NC}"
	echo -e "$INFO  ██╔══╝  ██║   ██║██║     ╚════██║  ${NC}"
	echo -e "$INFO  ██║     ╚██████╔╝╚██████╗███████║  ${NC}"
	echo -e "$INFO  ╚═╝      ╚═════╝  ╚═════╝╚══════╝  ${NC}"
	
	if [ $1 -eq 0 ]; then
		library
	elif [ $1 -eq 1 ]; then 
		file=$(basename $2)
		if [ -d /usr/share/focs/firmware-library/*$file.extracted ]; then
			echo -e "${INFO}Firmware images exist in the library for the following architectures: ${NC}"
			for a in $(ls /usr/share/focs/firmware-library | grep $file.extracted); do
				ARCH=$(echo $a | cut -d _ -f 1 | tr 'a-z' 'A-Z')
				echo -e "${INFO}$ARCH${NC}"
			done;
			
			echo -e "${ACT}If you would like to continue with this exraction${NC}"
			echo -e "${ACT}${NC}"
		       	echo -e "${ACT}* (which only recommended if you know the architecture of the file${NC}"
			echo -e "${ACT}you are extracting and know it doesn't exist here already) *${NC}"
			echo -e "${ACT}${NC}"
		        echo -e "${ACT}press 'e' to start extractig. Otherwise, any other key will just take you to the library.${NC}"
			read x
		
			if [ "$x" != 'e' ]; then
				library
			fi
		fi
		
		if [ ! -d /usr/share/focs/firmware-library ]; then
			sudo mkdir /usr/share/focs/firmware-library
		fi

		extract $file

=======
	if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
		echo -e "${ERROR}usage ./auto-fuzz /path/to/binary <memory to allocate>${NC}"
		echo -e "${ERROR}There is an optional third argument -- @@ .\nThis can be used to indicate that a file from stdin shoudl be used as input.${NC}"
		echo -e "${ERROR}The path to binary is likely something like squashfs-root/bin/<binary>${NC}"
		exit 1
	fi;

	echo 'core' | sudo tee /proc/sys/kernel/core_pattern

	THISDIR="$(echo $PWD)"

	TARGETDIR="$(find ./ -name 'bin' | sort | head -1)/"

	cd $TARGETDIR || { echo -e "${ERROR}You might've entered a wrong directory...${NC}" && exit 1; }

	export COM=qemu-"$(file -b -e elf * | grep -o ','.*',' | tr -d ',' | tr -d ' ' | uniq | tr '[:upper:]' '[:lower:]')"

	cd ..

	export QEMU_LD_PREFIX="$(echo $PWD)"

	cd $THISDIR

	MEM=1024
	MSG=""

	ulimit -Sv $[$MEM << 10]
	nohup $COM $1
	sleep 1;
	MSG="$(tail -n 1 nohup.out | grep -oh 'Unable to reserve')"

	while [[ "$MSG" == "Unable to reserve" ]]; do
		if [ $MEM -gt 8191 ]; then
			echo -e "${ERROR}Whoa there! The binary wants more than 8GB of virtual memory... Do some testing with QEMU's user-emulation mode to see if this binary can be run!${NC}" && rm nohup.out && exit 1;
		fi;

		MEM=$(( $MEM * 2 ))

		ulimit -Sv $[$MEM << 10]
		nohup $COM $1
		sleep 1
		MSG="$(tail -n 1 nohup.out | grep -oh 'Unable to reserve')"
	done;

	rm nohup.out

	echo -e "${INFO}Now we are going to minimize the seed corpus.${NC}"
	echo -e "${INFO}Errors are likely to occur here, so if problems persist,${NC}"
	echo -e "${INFO}Comment out the command 'afl-cmin' in the auto-fuzz.sh file${NC}" && sleep 3

	{ afl-cmin -Q -m $MEM -i in/ -o in2/ $1 $2 && echo -e "${INFO}Corpus seemed to minimize successfully!${NC}"; } || { echo -e "${ERROR}An error occurred with 'afl-cmin'. Scroll up for more details!${NC}" && exit 1; }

	if [ -d "in.bak" ]; then
		mv in2/ in/
	else
		mv in/ in.bak/
		mv in2/ in/
		echo -e "${INFO}A backup of your original test cases are stored in the in.bak directory"
	fi

	afl-fuzz -Q -m $MEM -i in/ -o out/ $1 $2

}

main () {
	clear

	echo -e "${INFO}${NC}"

	echo -e "$INFO  ███████╗ ██████╗  ██████╗███████╗  ${NC}"
	echo -e "$INFO  ██╔════╝██╔═══██╗██╔════╝██╔════╝  ${NC}"
	echo -e "$INFO  █████╗  ██║   ██║██║     ███████╗  ${NC}"
	echo -e "$INFO  ██╔══╝  ██║   ██║██║     ╚════██║  ${NC}"
	echo -e "$INFO  ██║     ╚██████╔╝╚██████╗███████║  ${NC}"
	echo -e "$INFO  ╚═╝      ╚═════╝  ╚═════╝╚══════╝  ${NC}"
	
	if [ $1 -eq 0 ]; then
		library
	elif [ $1 -eq 1 ]; then 
		file=$(basename $2)
		if [ -d /usr/share/focs/firmware-library/*$file.extracted ]; then
			echo -e "${INFO}Firmware images exist in the library for the following architectures: ${NC}"
			for a in $(ls /usr/share/focs/firmware-library | grep $file.extracted); do
				ARCH=$(echo $a | cut -d _ -f 1 | tr 'a-z' 'A-Z')
				echo -e "${INFO}$ARCH${NC}"
			done;
			
			echo -e "${ACT}If you would like to continue with this exraction${NC}"
			echo -e "${ACT}${NC}"
		       	echo -e "${ACT}* (which only recommended if you know the architecture of the file${NC}"
			echo -e "${ACT}you are extracting and know it doesn't exist here already) *${NC}"
			echo -e "${ACT}${NC}"
		        echo -e "${ACT}press 'e' to start extractig. Otherwise, any other key will just take you to the library.${NC}"
			read x
		
			if [ "$x" != 'e' ]; then
				library
			fi
		fi
		
		if [ ! -d /usr/share/focs/firmware-library ]; then
			sudo mkdir /usr/share/focs/firmware-library
		fi

		extract $file

>>>>>>> 951a9a64ee174425f75d5ae7458e33f07c60e71c
	else
		echo -e "${ERROR}Usage:${NC}"
		echo -e "${ERROR}./focs <path/to/binary>${NC}"
		echo -e "${ERROR}or run the binary with no arguments to see and fuzz the library.${NC}" && exit 1;
	fi
}

#library 
main $# $1

exit 0;
