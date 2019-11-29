#!/bin/bash
ERROR='\033[0;31m'
INFO='\033[0;34m'
NC='\033[0m'

(binwalk -e $1) || (echo -e "${ERROR}Unfortunately, binwalk threw an issue... This can't be fixed by me, I'm afraid...${NC}" && exit 1)

find _*/ -name 'bin'

ISSUE=$(echo "$?")

if [ "$ISSUE" -eq 0 ]
then
	echo -e "${INFO}Awesome! binwalk extracted the image perfectly!${NC}"
else
	echo -e "${ERROR}Darn... binwalk didn't extract the image perfectly...${NC}" && exit 1
fi;

THEDIR="$(find _*/ -name 'bin' | head -1)"

THISDIR="$(echo $PWD)"

THEARCH="$(file -b -e elf $THEDIR/* | grep -o ','.*',' | tr -d ' ' | tr -d ',' | uniq | tr '[:upper:]' '[:lower:]')"

NEWDIR="$(echo 'firmware-library/'$THEARCH$(echo _*/))"

mkdir $NEWDIR || (echo -e "${ERROR}The NEWDIR variable is wrong... Check the script${NC}" && exit 1)
mkdir $NEWDIR/in/
mkdir $NEWDIR/out/

cp $(find afl/testcases/ -type f) $NEWDIR/in/ || (echo -e "${ERROR}Issue copying the test cases over to the new directory. This is probably an issue with the script. Email ztaylor3@uncc.edu to resolve.${NC}" && exit 1)
cp auto-fuzz.sh $NEWDIR/auto-fuzz.sh

mv $1 $NEWDIR/ || (echo -e "${ERROR}Issue moving the img file to the new directory${NC}" && exit 1)

cp -r _*/* $NEWDIR/ || (echo -e "${ERROR}Issue copying everything into the newly created direcoty.${NC}" && exit 1)

rm -rf _*/

export CPU_TARGET="$(echo $THEARCH)"

cd afl/qemu_mode/

ORIG_CPU_TARGET="$CPU_TARGET"

test "$CPU_TARGET" = "" && CPU_TARGET="`uname -m`"
test "$CPU_TARGET" = "i686" && CPU_TARGET="i386"

cd qemu-*/ || (echo -e "${ERROR}The qemu directory isn't where it's supposed to be. Or your pwd is screwy.${NC}" && exit 1)

CFLAGS="-O3 -ggdb" ./configure --disable-system \
  --enable-linux-user --disable-gtk --disable-sdl --disable-vnc \
  --target-list="${CPU_TARGET}-linux-user" --enable-pie --enable-kvm || exit 1

echo "${INFO}[+] Configuration complete.${NC}"

echo "${INFO}[*] Attempting to build QEMU (fingers crossed!)...${NC}"

make || exit 1

echo "[+] Build process successful!"

echo "[*] Copying binary..."

cp -f "${CPU_TARGET}-linux-user/qemu-${CPU_TARGET}" "../../afl-qemu-trace" || exit 1

cd ..
ls -l ../afl-qemu-trace || exit 1

echo "${INFO}[+] Successfully created '../afl-qemu-trace'.${NC}"

if [ "$ORIG_CPU_TARGET" = "" ]; then

  echo "[*] Testing the build..."

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

sudo make install || (echo -e "${ERROR}Uh oh... there was a problem with make install... Scroll up for error details${NC}" && exit 1)

cd $THISDIR

echo -e "${INFO}###################################################${NC}"
echo -e "${INFO}#      You only need to run this file again       #${NC}"
echo -e "${INFO}# if you change the architecture you are fuzzing. #${NC}"
echo -e "${INFO}###################################################${NC}"

exit 0
