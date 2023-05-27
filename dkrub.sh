#!/bin/bash

function showHelp() {
	echo
	echo 'NAME'
	echo '    Disk Rubber'
	echo
	echo 'SYNOPSIS'
	echo '    drub -t|--target <TargetDirname> -r|--repeat <RepeatTimes>'
	echo
	echo 'DESCRIPTION'
	echo '    To remove the ... of deleted files.'
	echo '    DiskRubber will fill the free space of the disk with random data.'
	echo '    At the end, the written random data will be deleted.'
	echo
}

TEMP=$( getopt t:r: $* )
set -- $TEMP
while [ "$1" ]; do
	case "$1" in
		-t | --target)
			OPT_target=$2
			shift 2
			;;
		-r | --repeat)
			OPT_repeat=$2
			shift 2
			;;
		--)
			shift
			break;
			;;
	esac
done

if [ ! $OPT_target ]; then
	showHelp	
	exit 1
fi

if [ ! -d $OPT_target ]; then
	mkdir -p $OPT_target
fi

echo 'target:' $OPT_target
echo 'repeat:' $OPT_repeat

#-------------------------------------------------------------------------------
echo 'Generate FILLER ...'

i=0
FILLER=FILLER.$i
until [ ! -e $FILLER ]; do
	i=$((i + 1))
	FILLER=FILLER.$i
done

i=0
FILLED=$OPT_target/FILLED.$i
until [ ! -e $FILLED ]; do
	i=$((i + 1))
	FILLED=$OPT_target/FILLED.$i
done
mkdir $FILLED

# Generate a filler file composed of random data.
od -N10000000 /dev/random > $FILLER
FILLER_SIZE=$(expr $(wc -c $FILLER | awk '{print $1;}' ) / 512)

#-------------------------------------------------------------------------------
echo 'Start filling ...'

i=0
while [ 1 ]; do
	cp $FILLER $FILLED/$i
	CAPACITY=$( df $OPT_target | grep / | awk '{print $5;}' | tr -d '%' )
	AVAILABLE=$( df $OPT_target | grep / | awk '{print $4;}' )
	echo -ne "\r"
	printf "Disk Capacity: %3d%% [ i = %6d ]" $CAPACITY $i
	
	if [ $AVAILABLE -lt $FILLER_SIZE ]; then break; fi
	i=$((i + 1))
done
echo

#-------------------------------------------------------------------------------
echo 'Remove the vestige ...'
rm -f $FILLER
rm -fr $FILLED
