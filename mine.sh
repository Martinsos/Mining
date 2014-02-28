#!/bin/bash

# This script starts cuda miner with some basic settings.
# If temperature of GPU gets to high, it stops mining to stop GPU from getting damaged.

USERNAME=FILL_THIS
WORKERNAME=FILL_THIS
WORKERPASS=FILL_THIS
STRATUM=FILL_THIS

MAX_TEMP=80


function gpu_temp() {
	nvidia-smi -q -d TEMPERATURE | grep Gpu | grep -P -o "[0-9]+"
}

echo "Starting mining!"

./cudaminer -H 1 -i 0 -l auto -C 1 -o $STRATUM -O $USERNAME.$WORKERNAME:$WORKERPASS &
MINERPID=$!

while true; do
	TEMP=`gpu_temp`
	echo $TEMP
	if [ $TEMP -gt $MAX_TEMP ]; then
		echo "GPU temperature got over $MAX_TEMP°C! Killing cuda miner"
		kill $MINERPID
		sleep 1
		if [ -d /proc/$MINERPID ]; then
			kill -9 $MINERPID
		fi
		break
	fi
	sleep 1
done











