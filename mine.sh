#!/bin/bash

# This script starts cuda miner with some basic settings.
# If temperature of GPU gets to high, it stops mining to stop GPU from getting damaged.

USERNAME=FILL_THIS
WORKERNAME=FILL_THIS
WORKERPASS=FILL_THIS
STRATUM=FILL_THIS

MAX_TEMP=80


# Script will stop after executing MAX_TIME seconds. 
# If TIME_LIMIT <= 0 then script will execute forever.
MAX_TIME=${1:-0}


# Returns GPU temperature for nvidia GPU
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


START_TIME=$(date +%s)

# start cudaminer
./cudaminer -H 1 -i 0 -l auto -C 1 -o $STRATUM -O $USERNAME.$WORKERNAME:$WORKERPASS &
MINERPID=$!

# Kill cudaminer if script ends
trap "kill_gracefully $MINERPID" EXIT

# Check GPU temperature and end script if GPU becomes too hot
while  (($MAX_TIME <= 0 || $(date +%s) - $START_TIME < $MAX_TIME )); do
	TEMP=`gpu_temp`
	if [ $TEMP -gt $MAX_TEMP ]; then
		echo "GPU temperature got over $MAX_TEMP°C! Killing cuda miner"
		exit
	fi
	sleep 1
done

echo "Time limit excedeed! Killing cuda miner"











