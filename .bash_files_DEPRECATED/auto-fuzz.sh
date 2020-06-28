#/bin/bash
ERROR='\033[0;31m'
INFO='\033[1;34m'
NC='\033[0m'

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
