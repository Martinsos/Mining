#!/bin/bash

# This script starts cuda miner with some basic settings.
# If temperature of GPU gets to high, it stops mining to stop GPU from getting damaged.

USERNAME=FILL_THIS
WORKERNAME=FILL_THIS
WORKERPASS=FILL_THIS
STRATUM=FILL_THIS

MAX_TEMP=80


# Returns GPU temperature
function gpu_temp() {
	nvidia-smi -q -d TEMPERATURE | grep Gpu | grep -P -o "[0-9]+"
}

# Kills process. First sends SIGTERM, then SIGKILL if needed.
# Takes one argument: PID
function kill_gracefully() {
	kill $1
	sleep 1
	if [ -d /proc/$1 ]; then
		kill -9 $1
	fi
}



# start cudaminer
./cudaminer -H 1 -i 0 -l auto -C 1 -o $STRATUM -O $USERNAME.$WORKERNAME:$WORKERPASS &
MINERPID=$!

# Kill cudaminer if script ends
trap "kill_gracefully $MINERPID" EXIT

# Check GPU temperature and end script if GPU becomes too hot
while true; do
	TEMP=`gpu_temp`
	if [ $TEMP -gt $MAX_TEMP ]; then
		echo "GPU temperature got over $MAX_TEMP°C! Killing cuda miner"
		exit
	fi
	sleep 1
done











