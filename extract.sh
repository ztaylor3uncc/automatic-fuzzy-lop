#!/bin/bash
ERROR='\033[0;31m'
INFO='\033[1;34m'
NC='\033[0m'

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
echo -e "${INFO}make command.${NC}"
echo -e "${INFO}${NC}"
echo -e "${INFO}If you would like to quit to do some testing, enter 'q', otherwise, enter any other key to continue...${NC}"

read x

if [ $x == 'q' ];then
	echo -e "${INFO}For the best...${NC}" && exit 1
fi

cp $1 backup.bak

binwalk -e $1 || { echo -e "${ERROR}Unfortunately, binwalk threw an issue... This can't be fixed by me, I'm afraid...${NC}" && exit 1; } 

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
THEARCH="$(file -b -e elf $THEDIR/* | grep -o ','.*',' | tr -d ' ' | tr -d ',' | uniq | tr '[:upper:]' '[:lower:]')"
NEWDIR="$(echo 'firmware-library/'$THEARCH$(echo _*/))"

mkdir $NEWDIR || { echo -e "${ERROR}The NEWDIR variable is wrong... Check the script${NC}" && exit 1; }
mkdir $NEWDIR/in/
mkdir $NEWDIR/out/

{ cp $(find afl/testcases/ -type f) $NEWDIR/in/; } || { echo -e "${ERROR}Issue copying the test cases over to the new directory. This is probably an issue with the script. Email ztaylor3@uncc.edu to resolve.${NC}" && exit 1; }

ln -s $PWD/auto-fuzz.sh $NEWDIR/auto-fuzz

mv $1 $NEWDIR/ || { echo -e "${ERROR}Issue moving the img file to the new directory${NC}" && exit 1; }

cp -r _*/* $NEWDIR/ || { echo -e "${ERROR}Issue copying everything into the newly created directory.${NC}" && exit 1; }

rm -rf _*/ || { echo -e "${ERROR}Error removing the firmware folder... Check script for where folder was created/supposed to be.${NC}" && exit 1; }

export CPU_TARGET="$(echo $THEARCH)"

cd afl/qemu_mode/

ORIG_CPU_TARGET="$CPU_TARGET"

test "$CPU_TARGET" = "" && CPU_TARGET="`uname -m`"
test "$CPU_TARGET" = "i686" && CPU_TARGET="i386"

cd qemu-*/ || { echo -e "${ERROR}The qemu directory isn't where it's supposed to be. Or your PWD is screwy.${NC}" && exit 1; }

CFLAGS="-O3 -ggdb" ./configure --disable-system \
  --enable-linux-user --disable-gtk --disable-sdl --disable-vnc \
  --target-list="${CPU_TARGET}-linux-user" --enable-pie --enable-kvm || exit 1

echo "${INFO}Configuration complete.${NC}"

echo "${INFO}Attempting to build QEMU (fingers crossed!)...${NC}"

make || exit 1

echo "${INFO}Build process successful!${NC}"

echo "${INFO}Copying binary...${NC}"

cp -f "${CPU_TARGET}-linux-user/qemu-${CPU_TARGET}" "../../afl-qemu-trace" || exit 1

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

else

  echo "${INFO}[!] Note: can't test instrumentation when CPU_TARGET set."
  echo "${INFO}[+] All set, you can now (hopefully) use the -Q mode in afl-fuzz!${NC}"

fi

cd ..

{ sudo make install && echo -e "${INFO}Running make install... likeliness to fail is higher here...${NC}"; } || { echo -e "${ERROR}Uh oh... there was a problem with make install... Scroll up for error details${NC}" && exit 1; }

cd $THISDIR

echo -e "${INFO}###################################################${NC}"
echo -e "${INFO}#      You only need to run this file again       #${NC}"
echo -e "${INFO}# if you change the architecture you are fuzzing. #${NC}"
echo -e "${INFO}###################################################${NC}"

exit 0
