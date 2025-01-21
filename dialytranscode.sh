#!/bin/bash
clear

#Definitions
        echo ----------------------------------------------
        echo "Processing Daily Transcoding Jobs:"
	    echo "TV Shows"
	    echo "DVR Movies"
	    echo "Sports"
        echo ----------------------------------------------
        echo "Sedning Status Email email@domain.com"
        echo ----------------------------------------------
cd "/mnt/PlexNFS/Plex/DVR Movies"
        echo "Executing H265 (HEVC) DVR Movies Transcode Script in mounted storage"
        echo "See specific encoding details in log files"
bash "/mnt/PlexNFS/Plex/DVR Movies/h265_Movies.sh"
        echo "Completed DVR Movies Transcoding Script"
        echo ----------------------------------------------
cd "/mnt/PlexNFS/Plex/TV Shows"
        echo "Executing H265 (HEVC) TV Shows Transcode Script in mounted storage"
        echo "See specific encoding details in log files"
bash "/mnt/PlexNFS/Plex/TV Shows/h265_TV.sh"
        echo "Completed TV Shows Transcoding Script"
        echo ----------------------------------------------
cd "/mnt/PlexNFS/Plex/Sports"
        echo "Executing H265 (HEVC) Sports Transcode Script in mounted storage"
        echo "See specific encoding details in log files"
bash "/mnt/PlexNFS/Plex/Sports/h265_Sport.sh"
        echo "Completed Sports Transcoding Script"
        echo ----------------------------------------------
cd /root
        echo "Sending Email Summary"
bash "/root/mail.sh"
        echo "Daily Transcoding Processing Completed"
