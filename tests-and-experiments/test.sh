THEDIR="$(find firmware-library/ -name 'bin' | head -1)/"

echo 'Number of files in directory is '
ls $THEDIR | wc -l

COUNTER=0
BINARIES="
$(for BIN in $THEDIR*; do
  TYPE="$(file $BIN)"
  TEST="$(echo $TYPE | grep -E 'ARM|busybox')"
  
  if [ ! "$TEST" = "" ]; then
    COUNTER="$(expr $COUNTER + 1)"
   
    echo "[$COUNTER] $(basename "$BIN")"

  fi
done)"

# The below script requires more testing. For now, just output everyhing in a blob
#echo "$BINARIES" | less || echo 'Exiting because of an issue with less'; exit 1

echo $BINARIES

printf "\nEnter the name of the program you want to fuzz: "
read FUZZ

echo "Fuzzing $FUZZ"i

# ulimit -Sv $[1023 << 10]; /path/to/fuzzed_app
