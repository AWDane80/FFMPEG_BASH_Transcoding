# FFMPEG_BASH_Transcoding

## Overall Project Description:
Debian Based BASH Script Project for daily FFMPEG transcoding of MPEG2 video files on Intel based iGPU (non-free repo) with VAAPI surface + deinterlacing to H265/HEVC MKV files.

## Developer Disclaimer:
I am __NOT__ an experienced developer and have relied heavily on community forums and instructional videos for the entire project incl. the foundational ProxMox infrastructure and general Linux configuration. Please feel free to comment on anything you see that is bad practice or areas for optimizations that could benefit others in their pursuit to create better BASH scripts of their own.

I have decided to establish this REPO since I wanted to give back to the community that helped me buidl my homelab from the ground up to the point where I now have a stable, efficient and modular transcoding platform up and running using nothing but open-source software. As I have gone through this project, I have begun to enjoy this part of the work a lot, and I am planning to take up more documentation and instructional projects, if you have a specific project in mind that could tie in with this sort of work, please feel free to comment so I can consider future projects.

   __###-Thank you to the entire community for your help and support, truly amazing to be part of it.__

----------------------------------------------------------------

## The Overall Project:

### Introduction:
My home Plex Server is connected to our _Verizon FIOS Cable TV_ subsciption via a _HDHomeRun Prime 3_, prociding access to all the __non-DRM__ channels for Plex to record from. With some daily recordings such as Jeopardy and various children's TV shows, I have adopted __H265/HEVC__ as the primary codec for all internal media files. Our streaming boxes consists of a combination of _nVidia Shield_ (2019 Pro edition) and _Roku TCL TV's_, all of which support native __H265/HEVC__ decoding up to __level 4.1/main profile__.

In the past I was running _MCEBuddy_ with _Handbrake Cli_ as its encoding foundation. After some shaky Windows 11 updates, the system which has very decent specs _(I7-8700K, 32GB, nVidia GTX1060/6GB)_ was performing utterly terrible, single digit FPS when hardware encoding __H265/HEVC__ 1080 files both on iGPU and dedicated nVidia GPU, and Microsoft would not stop updating components I really did not want my Plex/Transcode server to ever have to deal with _(read co-Pilot and other MS bloat)_, and eventually I broke down and decided to finally get into Linux via a ProxMox Virtual Environment _(PVE)_.

Some of the old hardware has been refurbished for a lab role in the new PVE environment, _(turned out this was a blessing in disguise as I discovered that my integrated liquid CPU cooler had been leaking all over the motherboard into the memory sockets)_ and is now reconfigured as a ProxMox Backup Server _(might create a separate repo on this part of the project later)_ and the new Plex Server is configured as an LXC _(Linux Container)_ in the PVE mapping to the media files vis NFS over a 10GBit _Ubiquiti Aggregate Switch_.

As I used to rely on MCEBuddy in Windows to handle the daily transcoding 
As a newly converted Windows to Linux user for my home Plex Server setup I have several proejcts I am working on to automate and optimze the setup, one of these were a way to automatically transcode DVR recordings from MPEG2 .TS files to H265 (HEVC) .MKV (Matroska) containers for more efficient storage usage and retain device compability to avoid playback issues and need for live transcoding.

Coming form a Windows setup (Win11) with Plex Media Server and supporting software, specfically MCEBuddy for transcoding management/scheduling, I decided to adopt some of the concepts MCEBuddy utlizes but change others as I learned more about FFMPEG and general BASH scripting. 



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
