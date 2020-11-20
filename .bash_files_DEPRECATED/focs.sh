#!/bin/bash
INFO='\033[1;34m'

clean_firmware() {
  DIR="/usr/share/focs/"
  echo -e "Removing everything in $DIR, continue? (Y/n)"
  read choice
  case $choice in
    n|N) exit
    ;;
    *) echo -e "${INFO}Cleaning EVERYTHING...${NC}"
		# Added functionality to not remove afl dir 
		sudo rm -fr /usr/share/focs/firmware-library /usr/share/focs/results

  		user=$USER
		sudo chown $user:$user -R /usr/share/focs
    ;;
  esac
}

#practically all zalewski's code, but necessary for modularity
qemu_mode_setup() {
	clear

	echo -e "${INFO}Running the QEMU setup script${NC}"

	export CPU_TARGET="$1"

	ORIG_CPU_TARGET="$CPU_TARGET"

	test "$CPU_TARGET" = "" && CPU_TARGET="`uname -m`"
	test "$CPU_TARGET" = "i686" && CPU_TARGET="i386"
	
	cd /usr/share/focs/afl/qemu_mode/qemu-*/ || { echo -e "${ERROR}The qemu directory isn't where it's supposed to be.${NC}" && exit 1; }

	CFLAGS="-O3 -ggdb" 

	sudo ./configure --disable-system --enable-linux-user --disable-gtk --disable-sdl --disable-vnc --target-list="${CPU_TARGET}-linux-user" --enable-pie --enable-kvm || { echo -e "${ERROR}Failure configuring the QEMU files. Check the /usr/share/focs/afl/qemu_mode/ directory.${NC}" && exit 1; }

	echo -e "${INFO}Configuration complete.${NC}"

	echo -e "${INFO}Attempting to build QEMU (fingers crossed!)...${NC}"

	sudo make || { echo -e "${ERROR}Error with the make command for QEMU mode. Check the /usr/share/focs/afl/qemu_mode directory or the script or, idk...${NC}" && exit 1; }

	echo -e "${INFO}Build process successful!${NC}"

	echo -e "${INFO}Copying binary...${NC}"

	sudo cp -f "${CPU_TARGET}-linux-user/qemu-${CPU_TARGET}" "../../afl-qemu-trace" || exit 1

	cd ..
	ls -l ../afl-qemu-trace || exit 1

	echo -e "${INFO}Successfully created '../afl-qemu-trace'.${NC}"

	if [ "$ORIG_CPU_TARGET" = "" ]; then

	  echo -e "${INFO}Testing the build...${NC}"

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

	    echo -e "${ERROR}[-] Error: afl-qemu-trace instrumentation doesn't seem to work!${NC}"
	    exit 1

	  fi

	  echo -e "${INFO}[+] Instrumentation tests passed.${NC}"
	  echo -e "${INFO}[+] All set, you can now use the -Q mode in afl-fuzz!${NC}"

	else

	  echo -e "${INFO}[!] Note: can't test instrumentation when CPU_TARGET set."

	fi

	cd ..

	{ sudo make install && echo -e "${INFO}Running make install... likeliness to fail is higher here...${NC}"; } || { echo -e "${ERROR}Uh oh... there was a problem with make install... Scroll up for error details${NC}" && exit 1; }

}

focs_install() {
	clear

	echo -e "${INFO}${NC}"
	echo -e "${INFO}Some quick notes beore you get started...${NC}"
	echo -e "${INFO}Text in blue is helpful information you should probably read!${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${ERROR}Text in red indicates that something did not go as planned...${NC}"
	echo -e "${NC}White text is typically just output from a currently running command.${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${INFO}The very first thing you will be asked to do after confirming you want to continue${NC}"
	echo -e "${INFO}is you will be asked for your sudo password. If you are not a sudoer, this is probably${NC}"
	echo -e "${INFO}not something you should be tinkering with.${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${INFO}The script will check what distro you're running and if it is supported.${NC}"
	echo -e "${INFO}If it is not supported, carry on at your own risk.${NC}"
	echo -e "${ACT}Press 'q' to quit or enter any other key to continue...${NC}"

	read x

	if [[ $x == 'q' ]]; then
		clear
		echo -e "${INFO}Probably a good decision...${NC}" && exit 1
		echo -e "${INFO}${NC}"
		echo -e "${INFO}${NC}"
		echo -e "${INFO}${NC}"
	fi

	DESK=$(sudo cat /etc/*elease | grep -i pretty_name= | cut -d '=' -f 2 | sed "s/\"//g")

	which afl-fuzz

	VAL01=$(echo $?)
	VAL02=$(if [[ -d /usr/share/focs/ ]] && [[ -d /usr/share/focs/afl/ ]] && [[ -d /usr/share/focs/firmware-library/ ]]; then echo 0; else echo 1; fi)
	VAL03=$(( $VAL01 + $VAL02 ))

	if [[ $VAL03 -eq 0 ]]; then
		echo -e "${INFO}You have both afl-fuzz installed and an existing and recognizable '/usr/share/focs/' directory,${NC}"
		echo -e "${INFO}so we are skipping the preliminary install phase assuming it has been done previously${NC}" || sleep 2
	fi

	if [[ ! $VAL03 -eq 0 ]]; then
		
		if [[ -d /usr/share/focs/ ]]; then
			clear
			echo -e "${INFO}The file /usr/share/focs/ exists.${NC}"
			echo -e "${INFO}If it exists for a reason that isn't this, quit by pressing 'q'.${NC}"
			echo -e "${ACT}Otherwise, enter any key to continue.${NC}"
			
			read x

			if [[ $x == 'q' ]]; then
				clear
				echo -e "${INFO}Wise choice...${NC}" && exit 1
			fi
		else
			sudo mkdir /usr/share/focs/
		fi

		#cleanse the focs folder
		sudo rm -rf /usr/share/focs/*

		sudo mkdir /usr/share/focs/firmware-library/
		
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

				if [[ $x == 'q' ]]; then
					clear
					echo -e "${INFO}Well, it was worth a shot...${NC}" && exit 1
				else 
					{ sudo apt install -y git wget python flex coreutils binwalk qemu-user libtool wget python build-essential libtool-bin bison libglib2.0-dev libglib2.0 2>&- && echo -e "${INFO}Installing dependencies...${NC}"; } || { echo -e "${ERROR}Uh oh... issue installing dependencies....${NC}" && exit 1; }
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


		if [[ $x == 'q' ]]; then
			clear
			echo -e "${INFO}Probably a good decision...${NC}" && exit 1
		fi

		# Dependencies specifically for sasquatch
		#sudo apt-get install -y build-essential liblzma-dev liblzo2-dev zlib1g-dev

		THISDIR="$(echo $PWD)"

		# Grab latest version of AFL
		# Commenting this out to host my own version of afl and qemu
		# or, rather, an unchanging version
		{ wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz && echo -e "${INFO}Grabbing the latest version of AFL from Michal... Thanks, Mr. Zalewski!${NC}"; } || { echo -e "${ERROR}Whoops... Problem grabbing the latest AFL! Google lcamtuf to find out why!${NC}" && exit 1; }


		# Unpack it
		{ tar -xvf afl-latest.tgz && echo -e "${INFO}Unpacking the tarball of AFL${NC}"; } || { echo -e "${RED}Issue unpacking the tarball... Could be an issue with the script?${NC}" && exit 1; }

		# This is to future proof the script (in case the latest version changes)
		rm afl*.tgz
		sudo mv afl* /usr/share/focs/afl
		cd /usr/share/focs/afl/ 

		echo -e "${INFO}If you see this, everything is going fine so far....${NC}" || { echo -e "${ERROR}Yikes... If you see this there was a very terrible system error...${NC}" && exit 1; }

		# We have to make it before we do anything else 
		# (for reasons we can talk about, but are outside the scope
		# of these comments...).
		{ sudo make && echo -e "${INFO}Yeah! The make command ran great!${NC}"; } || { echo -e "${ERROR}Issue with the make command. Scroll up for details...${NC}" && exit 1; }

		{ cd qemu_mode && echo -e "${INFO}qemu_mode directory is where it's supposed to be...${NC}"; } || { echo -e "${ERROR}qemu_mode directory is not where it's supposed to be...${NC}" && exit 1; }

		# Decided to host my own version of QEMU # So I've commented out the lines to grab a new copy
		VERSION="2.10.0"
		QEMU_URL="http://download.qemu-project.org/qemu-${VERSION}.tar.xz"
		QEMU_SHA384="68216c935487bc8c0596ac309e1e3ee75c2c4ce898aab796faa321db5740609ced365fedda025678d072d09ac8928105"

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

		if [[ ! "$CKSUM" = "$QEMU_SHA384" ]]; then

		  echo -e "${RED}[*] Downloading QEMU ${VERSION} from the web...${NC}"
		  rm -f "$ARCHIVE"
		  wget -O "$ARCHIVE" -- "$QEMU_URL" || exit 1

		  CKSUM=`sha384sum -- "$ARCHIVE" 2>/dev/null | cut -d' ' -f1`

		fi

		if [[ "$CKSUM" = "$QEMU_SHA384" ]]; then

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
		# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=914218
		# TODO: This may be debian specific and we need to add a check
		cp $THISDIR/configs/memfd_create.diff ../patches/

		patch -p1 <../patches/elfload.diff || exit 1
		patch -p1 <../patches/cpu-exec.diff || exit 1
		patch -p1 <../patches/syscall.diff || exit 1
		patch -p1 <../patches/memfd_create.diff || exit 1

		echo -e "${INFO}Patching done.${NC}"

		cd $THISDIR
	fi

	echo -e "${INFO}${NC}"
	echo -e "${INFO}################################################${NC}"
	echo -e "${INFO}     All done with Dependencies and AFL make.   ${NC}"
	echo -e "${INFO}################################################${NC}"
}

focs_firmware-prep() {
	# Variables are in the scope of function
	DIR=1
	args=1
	target=1

	# Scripting mode if args passed
	if [[ -z $1 ]]; then
		echo -e "${INFO}Select the firmware image you would like to fuzz: ${NC}"

		# Options from directory
		f=$(ls /usr/share/focs/firmware-library)
		PS3="Select an option: "
		select file in "${f[@]}"; do
			[[ -n $file ]] || { echo -e "${WARN} Invalid choice. Try again..." >&2; continue; }
			break
		done
		# read -r file <<<$( echo "$f" | cut -d "_" -f 2)
		read -r file <<<"$f"
	fi

	if [[ -z $2 ]]; then
		echo -e "${INFO}${NC}"

		# All just to look nice :)
		tfile=$(tempfile)
		file $(find /usr/share/focs/firmware-library/*$file* -type f -executable) | grep -i 'stripped' | grep -v 'shared\|pie' | awk -F: '{print $1}' | sed 's:.*/::' | sort > $tfile
		column -x $tfile
		rm $tfile
		echo -e "\n${INFO}Type binary to fuzz${NC}"
		read target

		# TODO: Change dialog
		# TODO: Add suggestions for fuzzing
		# qemu-$THEARCH $DIR --help || qemu-$THEARCH $DIR -h
		# TODO This needs to be stream lined
		echo -e "${INFO}Specify the args you would like to use for the binary"
		read -a args
		if [[ -z $args ]]; then
			args="seed"
		fi

		echo -e "${INFO}Select an architecture: ${NC}"
		PS3="Select an option: "
		OPTS=$(ls /usr/share/focs/firmware-library | grep "$file" | cut -f1 -d "_" | uniq )
		select THEARCH in "${OPTS[@]}"; do 
			[[ -n $THEARCH ]] || { echo -e "${ERROR}Invalid choice. Select the number next to the architecture." >&2; continue; }
			break 
		done
		read -r THEARCH <<<"$THEARCH"
		DIR=$(find /usr/share/focs/ -iname $THEARCH_$target)
	fi

	echo "$args"

	# Appending architecture to scripted version
	if [[ ! -z $1 ]]; then
		file="${THEARCH}_${1}.extracted"
		# file="$${1}.extracted"
	fi

	# Binary to fuzz, qemu arguments, architecture, path of original firmware
	auto-fuzz $DIR $args $THEARCH $file
}


# TODO: Final frontier
auto-fuzz () {
	user=$USER
	sudo chown $user -R /usr/share/focs
	clear

	if [[ -z $1 ]] && [[ -z $2 ]]; then
		echo -e "${ERROR}usage ./auto-fuzz /path/to/binary <memory to allocate>${NC}"
		echo -e "${ERROR}There is an optional third argument -- @@ .\nThis can be used to indicate that a file from stdin shoudl be used as input.${NC}"
		echo -e "${ERROR}The path to binary is likely something like squashfs-root/bin/<binary>${NC}"
		exit 1
	fi;

	#TODO: figure out if 'performance' error is consistent.
	# if so, add that in here as well.
	echo 'core' | sudo tee /proc/sys/kernel/core_pattern

	qemu_mode_setup $3

	FOCS="/usr/share/focs/firmware-library"
	cd "$FOCS/$4/" || { echo -e "${ERROR}You might've entered a wrong directory...${NC}" && exit 1; }

	# get location of 'lib' directory for QEMU
	LIB="$(find $FOCS/$4 -name lib | sort | head -n 1)"

	export COM=qemu-$3 # "$(file -b -e elf * | grep -o ','.*',' | tr -d ',' | tr -d ' ' | uniq | tr '[:upper:]' '[:lower:]')"

	export QEMU_LD_PREFIX=$(dirname $LIB)
	
	MEM=1024
	MSG=""

	ulimit -Sv $[$MEM << 10]
	nohup $COM $1
	sleep 1;

	MSG="$(tail -n 1 nohup.out | grep -oh 'Unable to reserve')"

	while [[ "$MSG" == "Unable to reserve" ]]; do
		if [[ $MEM -gt 8191 ]]; then
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
	echo -e "${INFO}Comment out the command 'afl-cmin' in the auto-fuzz function${NC}" && sleep 3

	{ afl-cmin -Q -m $MEM -i in/ -o in2/ $1 $2 && echo -e "${INFO}Corpus seemed to minimize successfully!${NC}"; } || { echo -e "${ERROR}An error occurred with 'afl-cmin'. Scroll up for more details!${NC}" && exit 1; }


	# TODO: Finishing moving orginal test cases for genertated cases
	if [[ ! -d "in.bak" ]] ; then
		mv in in.bak
		echo -e "${INFO}A backup of your original test cases are stored in the in.bak directory"
	fi

	rm -fr in
	mv in2 in

	# TODO: No save and not continue
	# commenting this out for now
	# script threw error: 'ls: cannot access 'out/*': No such file or directory'
	# solve ASAP
	#if [[ -z $(ls out/*) ]] ; then
	#	echo -e "${INFO} Would you like to continue your previous job? (Y/n)"
	#	read OPT

	#	if [[ ${OPT,,} == 'n' ]]; then
	#        	rm -fr out/*
	#        	rm -fr in
 	#	else
	#		rm -rf in/*
        #   		mv out/{crashes/*,hangs/*} in/
	#   	fi
	#fi

	clear

	# CPU=$(nproc)
	# echo "You have $CPU available, how many would you like to use? (default 1)"
	# read CPU
	# if [[ $CPU -gt 1 ]] && [[ -z $CPU ]]; then
	# 	echo "${INFO} Naming master fuzzer FOCS0${IN}"
	# 	nohup afl-fuzz -Q -m $MEM -i in/ -o out/ -M FOCS0 $1 $2
	# 	# TODO: Figure out how to kill slaves
	# 	for core in {1..$CPU}; do
	# 		nohup afl-fuzz -Q -m $MEM -i in/ -o out/ -S "FOCS$core" $1 $2 &>/dev/null &
	# 	done
    # else
	#  	echo "${INFO} Naming master fuzzer FOCS0${IN}"
	# 	afl-fuzz -Q -m $MEM -i in/ -o out/ -M FOCS0 $1 $2
	# fi
	echo -e "${INFO}Naming master fuzzer FOCS0${NC}"
	afl-fuzz -Q -m $MEM -i in/ -o out/ -M FOCS0 $1 $2
}

extract () {
	clear

	echo -e "${INFO}Running the extraction function:${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${INFO}This can throw some issues, and this is certainly the part that has the${NC}"
	echo -e "${INFO}most trouble across Linix distros. If you are moving ahead with an unsupported${NC}"
	echo -e "${INFO}distribution, be very wary of error messages from the system, as my error messages${NC}"
	echo -e "${INFO}are typically only catching issues with this script itself and not things like the${NC}"
	echo -e "${INFO}'make' command.${NC}"
	echo -e "${INFO}${NC}"
	echo -e "${ACT}If you would like to quit to do some testing, enter 'q', otherwise, enter any other key to continue...${NC}"

	read x
	if [[ $x == 'q' ]];then
		echo -e "${INFO}For the best...${NC}" && exit 1
	fi

	if [[ -z $1 ]]; then
		echo -e "\n\n${ACT}What is the name of the file you would like to extract? (relative or fixed path accepted)${NC}"
		read file
		file=$(basename $file)

	else
		file=$(basename $1)
	fi

	# move file to focs directory for extraction and clean up
	# TODO: change the 'cp' to 'mv' once testing is done.
	sudo cp $file /usr/share/focs/ || { echo -e "${ERROR}Couldn't move the file to the /usr/share/focs directory... check that it exists already.${NC}" && exit 1; };

	cd /usr/share/focs/ || { echo -e "${ERROR}Issue jumping into the /usr/share/focs directory. Check that it exists.${NC}" && exit 1; };

	# extract to 
	sudo binwalk -e /usr/share/focs/$file || { echo -e "${ERROR}Unfortunately, binwalk threw an issue... This can't be fixed by me, I'm afraid...${NC}" && exit 1; }; 

	find _*/ -name 'bin'

	ISSUE=$(echo "$?")

	if [ "$ISSUE" -eq 0 ]
	then
		echo -e "${INFO}Awesome! binwalk extracted the image perfectly!${NC}"
	else
		echo -e "${ERROR}Darn... binwalk didn't extract the image perfectly...${NC}" && exit 1
	fi;

	THEDIR="$(find _*/ -name 'bin' | sort | head -1)"
	THISDIR="$(echo $PWD)"
	# get the architecture for naming
	THEARCH="$(file -b -e elf $THEDIR/* | grep -o ','.*',' | tr -d ' ' | tr -d ',' | uniq | tr '[:upper:]' '[:lower:]')"
	NEWDIR="$(echo '/usr/share/focs/firmware-library/'$THEARCH$(echo _*))"

	# move the extracted file and rename as new directory
	sudo mv _$file* $NEWDIR || { echo -e "${ERROR}The NEWDIR variable is wrong... Check the script${NC}" && exit 1; }

	in="$NEWDIR/in/"
	out="$NEWDIR/out/"

	sudo mkdir $in
	sudo mkdir $out

	# add test cases from AFL's example test bench. 
	{ sudo cp $(find /usr/share/focs/afl/testcases/ -type f) $in; } || { echo -e "${ERROR}Issue copying the test cases over to the new directory. This is probably an issue with the script. Email vstech@protonmail.ch to resolve.${NC}" && exit 1; }

	scrpt="$(pwd)/auto-fuzz.sh"
	dr="$NEWDIR/auto-fuzz"

	sudo ln -s $scrpt $dr

	# backup the firmware file to the new directory
	sudo mv $file $NEWDIR/ || { echo -e "${ERROR}Issue moving the img file to the new directory${NC}" && exit 1; }
	
	cd $THISDIR

	echo -e "${INFO}      Extraction complete!       ${NC}"
}

dialog() {
	echo "You could get help if this was finished... "
}

### display main menu ###
## TODO Add dialog for --help and man documents
echo -e "${INFO}
     ,                                     
     Et           :                        
     E#t         t#,          .,          .
     E##t       ;##W.        ,Wt         ;W
     E#W#t     :#L:WE       i#D.        f#E
     E#tfL.   .KG  ,#D     f#f        .E#f 
     E#t      EE    ;#f  .D#i        iWW;  
  ,ffW#Dffj. f#.     t#i:KW,        L##Lffi
   ;LW#ELLLf.:#G     GK t#f        tLLG##L 
     E#t      ;#L   LW.  ;#G         ,W#i  
     E#t       t#f f#:    :KE.      j#E.   
     E#t        f#D#;      .DW:   .D#j     
     E#t         G#t         L#, ,WK,      
     E#t          t           jt EG.       
     ;#t                         ,         
      :;                                   
${NC}"

if [[ -z $1 ]]; then
  # Interactive menu
  # TODO: add options to specify new run or old run (firmware loaded or not)
  echo -e "\n\n F O C S   M E N U \n"
  PS3='Select 1 (install), 2 (extract), 3 (run), 4 (clean), 5 (help), 6 (exit): '
  options=("install" "extract" "run" "clean" "help" "exit")
  select opt in "${options[@]}"
  do
    case $opt in
      "install")
        focs_install 
        ;;
      "extract")
		extract
		;;
      "run")
        focs_firmware-prep
        ;;
      # TODO Enable option to clean single firmware
      "clean")
        clean_firmware
        ;;
      "help")
		dialog
		;;
      "exit")
        break
        ;; 
      *)
        echo "Try again..."
    esac
  done
else
  # Scripting menu
  opt=$1
  case $opt in
    install)
      focs_install 
      ;;
    extract)
	  extract $2
	  ;;
    run)
      focs_firmware-prep $2 $3
      ;;
    # TODO Enable option to clean single firmware
    clean)
      clean_firmware
      ;;
    "help")
	  dialog
	  ;;
    exit)
      break
      ;; 
    *)
        dialog
        echo "Try again..."
  esac
fi 
