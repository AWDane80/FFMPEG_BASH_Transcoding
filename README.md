# FFMPEG_BASH_Transcoding

## Overall Project Description:
Debian Based BASH Script Project for daily FFMPEG transcoding of MPEG2 video files on Intel based iGPU (non-free repo) with VAAPI surface + deinterlacing to H265/HEVC MKV files.

## Developer Disclaimer:
I am __NOT__ an experienced developer and have relied heavily on community forums and instructional videos for the entire project incl. the foundational ProxMox infrastructure and general Linux configuration. Please feel free to comment on anything you see that is bad practice or areas for optimizations that could benefit others in their pursuit to create better BASH scripts of their own.

I have decided to establish this REPO since I wanted to give back to the community that helped me buidl my homelab from the ground up to the point where I now have a stable, efficient and modular transcoding platform up and running using nothing but open-source software. As I have gone through this project, I have begun to enjoy this part of the work a lot, and I am planning to take up more documentation and instructional projects, if you have a specific project in mind that could tie in with this sort of work, please feel free to comment so I can consider future projects.

###   -Thank you to the entire community for your help and support, truly amazing to be part of it.

----------------------------------------------------------------

## The Overall Project:

### Introduction:
My home Plex Server is connected to our _Verizon FIOS Cable TV_ subsciption via a _HDHomeRun Prime 3_, prociding access to all the __non-DRM__ channels for Plex to record from. With some daily recordings such as Jeopardy and various children's TV shows, I have adopted __H265/HEVC__ as the primary codec for all internal media files. Our streaming boxes consists of a combination of _nVidia Shield_ (2019 Pro edition) and _Roku TCL TV's_, all of which support native __H265/HEVC__ decoding up to __level 4.1/main profile__.

In the past I was running _MCEBuddy_ with _Handbrake Cli_ as its encoding foundation. After some shaky Windows 11 updates, the system which has very decent specs _(I7-8700K, 32GB, nVidia GTX1060/6GB)_ was performing utterly terrible, single digit FPS when hardware encoding __H265/HEVC__ 1080 files both on iGPU and dedicated nVidia GPU, and Microsoft would not stop updating components I really did not want my Plex/Transcode server to ever have to deal with _(read co-Pilot and other MS bloat)_, and eventually I broke down and decided to finally get into Linux via a ProxMox Virtual Environment _(PVE)_.

Some of the old hardware has been refurbished for a lab role in the new PVE environment, _(turned out this was a blessing in disguise as I discovered that my integrated liquid CPU cooler had been leaking all over the motherboard into the memory sockets)_ and is now reconfigured as a ProxMox Backup Server _(might create a separate repo on this part of the project later)_ and the new Plex Server is configured as an LXC _(Linux Container)_ in the PVE mapping to the media files vis NFS over a 10GBit _Ubiquiti Aggregate Switch_.

I used to rely on MCEBuddy in Windows to handle the daily transcoding to automatically transcode DVR recordings from MPEG2 _.TS_ files to H265 (HEVC) .MKV _(Matroska)_ containers for more efficient storage usage and retain device compability to avoid playback issues and need for live transcoding. With the change to a Linux based Plex foundation I found myself with some options:
* Spin up a Windows VM in the PVE and run MCEBuddy with the old scripts
* Explore a Linux command line option

I obviously chose the latter, and the results are pretty awesome.

## All The Steps Outlined:
While the actual recording is entirely handled within the Plex interface, all sub-sequent transcoding is conducted using base FFMPEG and basic BASH scripting, below you will find the steps being performed as part of the overall script execution:
* Overall BASH script executes as CRONJOB daily at 01:00 AM, currently consist of 4 separate sub-scripts called _(3 for transcoding specifics folders and 1 for emailing a summary of what has been done, you will find all these scripts in the repo with any perosnal information replaced with generic placeholders.)_
* Transcoding Scripts with specific FFMPEG configuration to suit the specific type of recording, _I transcode movies with a higher quality (lower setting technically as H265/HEVC quality setting is reverse in magnitude) as compared to TV shows and Sports_, 
        - Creating and adding to a dedicated working file to capture .TS files worked on.
        - Creating and adding to a dedicated log file for each specific transcoding process executed. _Examples of Working File Contents and Log Files are provided in this repo._ 
        - And finally moving the original .TS file to a temporary location outside the Plex library as a backup in case there is an issue with the transcoded MKV file. _I plan to build a clean up script in the near future once I am comfortable with the overall process execution._
* Summary Email Script, sending a summary of what has been worked on during the overall execution by reading defined variables that dig into the generated working files contained information on which files has been worked on. _An example output email with perosnal information replaced is provided in the repo along with the actual emailing BASH script._

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
