#!/usr/bin/bash
WORLD_STORAGE="$(pwd)/server"
WORLD_RAMDISK=$(mktemp -d)
RAM_USE=$1
LOG_PREPEND="RAMDISK SCRIPT:"
USER=$(whoami)
if [ "$RAM_USE" == "" ]
then
	echo "$LOG_PREPEND usage: sudo bash start.sh <Ramdisk size>";
	echo "$LOG_PREPEND example: sudo bash start.sh 4G";
	exit
fi

LOCK_FILE="server-ramdisk.lock" 
LOCK_FILE_PATH="$WORLD_RAMDISK/$LOCK_FILE"
WAIT_TIME_SEC=60;

echo "$LOG_PREPEND ramdisk location: $WORLD_RAMDISK";
move_to_ramdisk() {
	echo "$LOG_PREPEND moving to ramdisk";
	sudo mount -t tmpfs none "$WORLD_RAMDISK" -o size="$RAM_USE"
	sudo chown "$USER:$USER" -R "$WORLD_RAMDISK"
	sudo chmod 711 -R "$WORLD_RAMDISK"
	cp -r "$WORLD_STORAGE"/* "$WORLD_RAMDISK"  && touch "$LOCK_FILE_PATH"
}

rsync_to_server() {
	rsync -r "$WORLD_RAMDISK/" "$WORLD_STORAGE" && echo "$LOG_PREPEND succesfully ran ramdisk backup";
}

reconcile_server_data() {
	while true
	do
		sleep "$WAIT_TIME_SEC"
		if [  -e "$LOCK_FILE_PATH" ] 
		then 
			echo "$LOG_PREPEND backing up";
			rsync_to_server
		else
			break
		fi
		
	done
}

run_minecraft_server() {
	cd "$WORLD_RAMDISK" 	
	./run.sh
	echo "$LOG_PREPEND Running final backup"
	rsync_to_server 
       	echo "$LOG_PREPEND Deleting ramdisk"
       	sudo umount "$WORLD_RAMDISK"
	sudo rm -r "$WORLD_RAMDISK"
	rm "$WORLD_STORAGE/$LOCK_FILE"
}

move_to_ramdisk
reconcile_server_data & 
run_minecraft_server 
exit
