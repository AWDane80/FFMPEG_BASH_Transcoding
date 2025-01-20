#!/bin/bash
clear

#Definitions
tvvalue=$(<"/mnt/PlexNFS/Plex/Daily Transcoding/Working Files/TVScript_$( date +%F).txt")
movievalue=$(<"/mnt/PlexNFS/Plex/Daily Transcoding/Working Files/MovieScript_$( date +%F).txt")
sportvalue=$(<"/mnt/PlexNFS/Plex/Daily Transcoding/Working Files/SportScript_$( date +%F).txt")
        echo ----------------------------------------------
	echo "Processing the following sciprt output files:"
	echo "$tvvalue"
	echo "$movievalue"
	echo "$sportvalue"
	echo ----------------------------------------------
        echo "Sedning Status Email proxmox@w-family.com"
        echo ----------------------------------------------

#Email Subsystem Sending Command
mail -s "Proxmox Transcoder Process -  $( date '+%F_%H:%M')" "email@domain.com" <<EOF
---------------------------------------------------------------------------------------
Sender:         Root @ FFMPEG Debian Transcode LXC
System:         Orion Proxmox Cluster
Process:        Daily Transcoder Cronjob Completion Notification
---------------------------------------------------------------------------------------
TV Files Processed:
"$tvvalue"
---------------------------------------------------------------------------------------
Movies Files Processed:
"$movievalue"
---------------------------------------------------------------------------------------
Sports Files Processed:
"$sportvalue"
---------------------------------------------------------------------------------------

EOF
