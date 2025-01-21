# FFMPEG_BASH_Transcoding
Debian Based BASH Script Project for daily transcoding of video files on Intel based iGPU (non-free repo) with VAAPI surface + deinterlacing

As a newly converted Windows to Linux user for my home Plex Server setup I have several proejcts I am working on to automate and optimze the setup, one of these were a way to automatically transcode DVR recordings from MPEG2 .TS files to H265 (HEVC) .MKV (Matroska) containers for more efficient storage usage and retain device compability to avoid playback issues and need for live transcoding.

Coming form a Windows setup (Win11) with Plex Media Server and supporting software, specfically MCEBuddy for transcoding management/scheduling, I decided to adopt some of the concepts MCEBuddy utlizes but change others as I learned more about FFMPEG and general BASH scripting. 

Full disclosure I am in no way a Linux or BASH savant and I imagine there are many optimizations and/or security issues that can be done. My setup is exclusively a home setup with zero public exposure outside of VPN connections!

----------------------------------------------------------------

## The Overall Project:


```
#!/bin/bash
clear

#Definitions
        echo ----------------------------------------------
        echo "Processing Daily Transcoding Jobs:"
        echo "TV Shows"
        echo "DVR Movies"
        echo "Sports"
        echo ----------------------------------------------
        echo "Sedning Status Email email@address.domain"
        echo ----------------------------------------------
cd "/mnt/PlexNFS/Plex/DVR Movies"
bash "/mnt/PlexNFS/Plex/DVR Movies/h265_Movies.sh"
cd "/mnt/PlexNFS/Plex/TV Shows"
bash "/mnt/PlexNFS/Plex/TV Shows/h265_TV.sh"
cd "/mnt/PlexNFS/Plex/Sports"
bash "/mnt/PlexNFS/Plex/Sports/h265_Sport.sh"
cd /root
bash "/root/mail.sh"
```
