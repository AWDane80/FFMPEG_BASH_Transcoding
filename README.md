# FFMPEG_BASH_Transcoding

## Overall Project Description:
Debian Based BASH Script Project for daily FFMPEG transcoding of MPEG2 video files on Intel based iGPU (non-free repo) with VAAPI surface + deinterlacing to H265/HEVC MKV files.

## Developer Disclaimer:
I am __NOT__ an experienced developer and have relied heavily on community forums and instructional videos for the entire project incl. the foundational ProxMox infrastructure and general Linux configuration. Please feel free to comment on anything you see that is bad practice or areas for optimizations that could benefit others in their pursuit to create better BASH scripts of their own.

I have decided to establish this REPO since I wanted to give back to the community that helped me build my homelab from the ground up, to the point where I now have a stable, efficient and modular transcoding platform up and running using nothing but open-source software. As I have gone through this project, I have begun to enjoy this part of the work a lot, and I am planning to take up more documentation and instructional projects, if you have a specific project in mind that could tie in with this sort of work, please feel free to comment so I can consider future projects.

###   -Thank you to the entire community for your help and support, truly amazing to be part of it.

----------------------------------------------------------------

## The Overall Project:

### Introduction:
My home Plex Server is connected to our _Verizon FIOS Cable TV_ subsciption via a _HDHomeRun Prime 3_, providing access to all the __non-DRM__ channels for Plex to record from. With some daily recordings such as Jeopardy and various children's TV shows. 

I have adopted __H265/HEVC__ as the primary codec for all internal media files. Our streaming boxes consists of a combination of _nVidia Shield_ (2019 Pro edition) and _Roku TCL TV's_, all of which support native __H265/HEVC__ decoding up to at least __level 4.1/main profile__ and generally should all support 4K material as well in level 5.1 as well, more on levels in the specific sub-section further down.

In the past I was running _MCEBuddy_ with _Handbrake Cli_ as its encoding foundation. After some shaky Windows 11 updates, the system which has very decent specs _(I7-8700K, 32GB, nVidia GTX1060/6GB)_ was performing utterly terrible, single digit FPS when hardware encoding __H265/HEVC__ 1080i/p files both on iGPU or the dedicated nVidia GPU. Furthermore, Microsoft would not stop updating components I really did not want my Plex/Transcode server to ever have to deal with _(read co-Pilot and other MS bloat)_, and eventually I broke down and decided to finally get into Linux via a ProxMox Virtual Environment _(PVE)_.

Some of the old hardware has been refurbished for a lab testing role in the new PVE environment, _(turned out this was a blessing in disguise as I discovered that my integrated liquid CPU cooler had been leaking all over the motherboard into the memory sockets)_ and is now reconfigured as a ProxMox Backup Server _(might create a separate repo on this part of the project later)_ and the new Plex Server is configured as an LXC _(Linux Container)_ in the PVE mapping to the media files vis NFS over a 10GBit _Ubiquiti Aggregate Switch_.

I used to rely on MCEBuddy (_great functionality but the app seemed to eat a lot of performance from the GUI_) in Windows to handle the daily transcoding to automatically transcode DVR recordings from MPEG2 _.TS_ files to H265 (HEVC) .MKV _(Matroska)_ containers for more efficient storage usage and retain device compability to avoid playback issues and eliminate the need for live transcoding for non-live TV playback. With the change to a Linux based Plex foundation I found myself with some options:
* Spin up a Windows VM in the PVE and run MCEBuddy with the old scripts
* Explore a Linux command line option

I obviously chose the latter, and the results are pretty awesome.

## All The Steps Outlined:
While the actual recording is entirely handled within the Plex application, all sub-sequent transcoding is conducted using base FFMPEG and basic BASH scripting, below you will find the steps being performed as part of the overall script execution:
* Overall BASH script executes as CRONJOB daily at 01:00 AM, currently consist of 4 separate sub-scripts called _(3 for transcoding specifics folders and 1 for emailing a summary of what has been done, you will find all these scripts in the repo with any perosnal information replaced with generic placeholders.)_
* Transcoding Scripts with specific FFMPEG configuration to suit the specific type of recording, _I transcode movies with a higher quality (lower setting technically as H265/HEVC quality setting is reverse in magnitude) as compared to TV shows and Sports_, 
  - Creating and adding to a dedicated working file to capture .TS files worked on.
  - Creating and adding to a dedicated log file for each specific transcoding process executed. _Examples of Working File Contents and Log Files are provided in this repo._ 
  - And finally moving the original .TS file to a temporary location outside the Plex library as a backup in case there is an issue with the transcoded MKV file. _I plan to build a clean up script in the near future once I am comfortable with the overall process execution._
* Summary Email Script, sending a summary of what has been worked on during the overall execution by reading defined variables that dig into the generated working files containing information on which files has been worked on. _An example output email with perosnal information replaced is provided in the repo along with the actual emailing BASH script._

## File Paths:
_Note: Please make sure to update ALL paths to match you specific setup unless you adopt an identical set of paths:_

For my specific setup I have the follwing file paths: 
```
Main Plex Media Library:           "/mnt/PlexNFS/Plex/"
Transcode Log Files:               "/mnt/PlexNFS/Plex/Daily Transcoding/Logs"
Transcode Working Files:           "/mnt/PlexNFS/Plex/Daily Transcoding/Working Files" 
Post-Transcode .TS File Archive:   "/mnt/PlexNFS/Plex/Daily Transcoding/TS Recordings Archive"
```

## Transcode Script Specifics:
In the three uploadded BASH scripts for transcoding __(h265_TYPE.sh)__ there are a few specific fields that are important to understand:
_Note: lines in a BASH script that ends with a _\_ is a way to tell the parser that it is continued line rather than a new specific line to parse, so you will see in the main FFMPEG section the lines generally end with _\_ to allow all the parameters to be properly parsed but retain a more read friendly format for editing specific paramters. So as you come across these in the documentation, I have kept them when separating them out from the overall script when explaining the details of the specific parameter._

### Send Output to Logfile instead of regular GRUB:
This section eliminates regular GRUB (Linux commandline) output and captures it all in a dedicated log file, automatically generated with a timestap incl. YEARMMDD + HH & MM for the specific transcode process.
```
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"/mnt/PlexNFS/Plex/Daily Transcoding/Logs/$( date '+%F_%H:%M')_h265_Sport_log.out" 2>&1
```

### Special FFMPEG Parameters
This section is a FFMPEG commandline option to slow down the update refresh rate to one every 10 seconds rather than every 0.5 seconds which make the log files much more manageable even for larger convresions.
```
-stats_period 10 \
```

This parameter for the video encorder is enabling the __"Low Power"__ mode of the processor, __NOTE: This only works if your specific Intel Processor is capable of working in Low Power mode for the specific codec (H265/HEVC in this case) and with the specific encording parameters, specifically RC modes.__ I recommend testing the script without the log file enabled (earlier section) and test your processor's ability to do this. I see some pretty solid increase in encoding performance when enabled for my specifc Alder Lake processor (N100), change the paramter to "false" if your command line execution fails and test again.
```
-low_power true \
```

This is the built in VAAPI deinterlacer to encode videos in progressive scan mode, I have seen solid performance on my processor, but note that deinterlacing costs CPU power and can't be entirely hardware offloaded, however for basic video transcoding this is fairly small and I am seeing near zero reduction in performance.
```
-vf deinterlace_vaapi \
```

### Quality Settings:
This is the quality setting for the H265/HEVC encoder to aim for, the lower the value the higher the bitrate aka quality, I have found for 1080 video values between 23 (movies), 25 (TV-Shows non-animated) and 28 (sport/live content/animated content) is all acceptable ranges, test with your specific video sources and evaluate quality vs. file size.
```
-global_quality 23 \
```

### RC Mode, Read Carefully to understand the specific tuning of the encoder used in my scripts:
This is one the most important parameters in your FFMPEG video encoder to understand. This took me a little while to understand and eventually decided to build my transcoder scripts around some KISS methodology.
```
-rc_mode 1 \
```
"RC Mode" is a setting in FFMPEG that configures the encoder to s specific quality or bitrage paradigm. Spefically for VAAPI's H265/HEVC Encoder there are six (technically seven)RC Modes avilable to it, you retrieve the compatible modes by running this command in your Linux terminal:
```
ffmpeg -h encoder=hevc_vaapi
```
Scroll to the RC section which should yield an output like the following:
```
  -rc_mode           <int>        E..V....... Set rate control mode (from 0 to 6) (default auto)
     auto            0            E..V....... Choose mode automatically based on other parameters
     CQP             1            E..V....... Constant-quality
     CBR             2            E..V....... Constant-bitrate
     VBR             3            E..V....... Variable-bitrate
     ICQ             4            E..V....... Intelligent constant-quality
     QVBR            5            E..V....... Quality-defined variable-bitrate
     AVBR            6            E..V....... Average variable-bitrate
```
As you cn see from the above output table, the specific tuning I have gone for is "RC Mode 1" or "Constant Quality", this then refers back to the global quality setting previously defined to create a target quality based on the encoders inspection of the source material.

If you want to work target bitrate RC modes I welcome you to post your findings as a comment, I am specifically going to test other modes to get a better sense of finetuning for specific encoding jobs in the future.

You can reduce the file size by adoption other modes such as the popular __ICQ (4)__ RC Mode, which analyzes frames in more detail to optimize the bitrate scene by scene or rather frame by frame. For my purpose I saw very little (practically none) quality impact on the files and very small improvements to file sizes for DVR recordings, so I decided to go with keeping things simple and stcking the contant quality mode and simply change the global quality setting depending on source material.

_Note: I plan to create a __High Quality Encoder__ for ripped physical media (BluRay/DVD, all owned, not pirating here!) and will likely be testing that with RC Mode 4 aka ICQ settings, depending on outcome I will post an updated script for that when I have results with a separate documentation._

_Note: __Low Power Mode__ only work with: CQP (1), CBR (2), VBR (3), QVBR (5)_

### Profile and Levels:
```
-profile:v main \
-level 123 \
```
This spefically sets the encorder to use a specific H265/HEVC profile (Main) and Level (4.1) which specifies some limitations to the content of the file. Check out the [Wiki Article on H265/HEVC Profiles and Levels](https://en.wikipedia.org/wiki/High_Efficiency_Video_Coding_tiers_and_levels) to understand these in more detail. 

I have configured the encoder to use what would be near the lowest common denominator allowing for 1080P resolution and bitrates high enough to accomodate my specific needs as well as retain compability with my playback devices, unless you have some specific needs or need to encode __4K material (which requires at least level 5)__ this is a great middle of the road setting. You could theoretically drop the level a little for 720P video but you are almost certain to have devices able to natively read 4.1 levels if they can do H265/HEVC in the first place.

If you do want to mess around with levels, run the command:
```
ffmpeg -h encoder=hevc_vaapi
```
Scroll down to the Profiles and Levels sections and you will see something like this:
```
  -level             <int>        E..V....... Set level (general_level_idc) (from -99 to 255) (default -99)
     1               30           E..V.......
     2               60           E..V.......
     2.1             63           E..V.......
     3               90           E..V.......
     3.1             93           E..V.......
     4               120          E..V.......
     4.1             123          E..V.......
     5               150          E..V.......
     5.1             153          E..V.......
     5.2             156          E..V.......
     6               180          E..V.......
     6.1             183          E..V.......
     6.2             186          E..V.......
```
As you probably see, the interger in the middle section indicates a logical way to refer to the level in the FFMPEG command line. The scripts used for this purpose are all set to "Level 4.1" or "123", to encode 4K material you would have to bumb this up to at least "Level 5.0" or "150".

## Example Full Script TV Shows (Stored in TV Shows Library Plex Root Folder "/mnt/PlexNFS/Plex/TV Shows"):
```
#!/bin/bash
  echo "-----------------------------------------------------------"
  echo "BASH Script Processing with GRUB output sent to log file:"
  echo "Daily TV Recordings Batch Transcode Scipt"
  echo "Conversion JOB: CronTab:TV Recordings on $( date '+%F_%H:%M')"
  echo "Converting The Following .TS MPEG2 Files:"
  find . | grep "\.ts$"
  echo "-----------------------------------------------------------"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"/mnt/PlexNFS/Plex/Daily Transcoding/Logs/$( date '+%F_%H:%M')_h265_TV_log.out" 2>&1
  echo "Daily TV Recordings Batch Transcode Scipt"
  echo "Conversion JOB: CronTab:TV Recordings on $( date '+%F_%H:%M')"
  echo "------------------------------------------------------"
  echo "Encoder:	FFMPEG H265_VAAPI"
  echo "CODEC:		H265 (HEVC)"
  echo "Quality: 	25"
  echo "Profile: 	Main"
  echo "Level: 		4.1"
  echo "Features:   VAAPI Deinterlace"
  echo "Progress Update Frequency 10 Seconds"
  echo "Working File: /mnt/PlexNFS/Plex/Daily Transcoding/Working Files/TVScript_$( date +%F).txt"
  echo "Converting The Following .TS MPEG2 Files:"
  find . | grep "\.ts$"
  echo "------------------------------------------------------"
  touch "/mnt/PlexNFS/Plex/Daily Transcoding/Working Files/TVScript_$( date +%F).txt"
  shopt -s globstar
  for filename in ./**/*.ts
  do
  echo "Converting ${filename##*/}"
  ffmpeg -y \
	-stats_period 10 \
	-hwaccel vaapi \
	-hwaccel_output_format vaapi \
		-i "${filename}" \
		-c:v hevc_vaapi \
			-low_power true \
			-vf deinterlace_vaapi \
			-global_quality 25 \
			-rc_mode 1 \
			-profile:v main \
			-level 123 \
		-c:a copy -map 0 \
			-metadata:s:a:0 language=eng \
                        -metadata:s:a:1 language=eng \
                        -metadata:s:a:2 language=eng \
		-c:s copy  \
			-metadata:s:s:0 language=eng \
                        -metadata:s:s:1 language=eng \
	"${filename}.mkv"
  echo "$( date '+%F_%H:%M') Finished Converting ${filename##*/}"
  echo "$( date '+%F_%H:%M') Moving ${filename##*/} To Temp Archive /mnt/PlexNFS/Plex/Daily Transcoding/TS Recordings Archive/"
  mv "${filename}" "/mnt/PlexNFS/Plex/Daily Transcoding/TS Recordings Archive/"
  echo "${filename##/}" >> "/mnt/PlexNFS/Plex/Daily Transcoding/Working Files/TVScript_$( date +%F).txt"
  echo "------------------------------------------------------"
done
```
_Note: Remember, to be able to execute a BASH script you need to make the BASH script file executable, depending on your specific setup you may want to change who or what can execute the specific script,_ for me I am executing my main script (and all sub-scripts) as Root on my dedicated PVE Transcoder LXC as a CRONJOB, so for me this is my go to, theoretically allowing for other users to execute the scripts as well from other systems but only allow for writing on the Root account.
```
chmod 755 script.sh
```
_Note: For my specific setup I also have "Access Control Lists" (ACL's) configured on the NFS shared folder on the File Server to ensure proper file access permissions for both Transcoder LXC and the dedicated Plex user/group that is created by the Plex installer which owns files and folders generated by the Plex Media Server when recording Live TV to the DVR, to learn more about ACL's see the [Geeks for Geeks Article](https://www.geeksforgeeks.org/access-control-listsacl-linux/)_

_If you run everything locally on the same Linux container (or bare metal) all you need to do is to ensure that the user executing the scripts have execute permissions and that your Plex accounts retain at least read access to the files you encode with your FFMPEG script (write if you wish Plex Media Server to be able to remove media files via the GUI's)_

Check out the other scripts for Movies and Sport in the repo's file list for their specific setup. You will notice changes to the output log files, working files and minor tweaks to the FFMPEG parameters depending on my specific needs based on source material and long term quality retention.

Each of these scripts can be modified to your specific needs, however if you wish retain the log file output and ability to email a summary you will need adapt any changes to log and working files to match your specific needs.

## Mail Script
This section shows you the email script I developed to send a summary email when the overall main script completes. I have made the email address generic, simply update it to the email address you wish to email the script contents to:

__Note: If you are working on a base Debian host, make sure you have installed mailutils for this to function, that may come with additional security concerns for your specific situation, so consider your options here, if you want to opt out of email all togther simply remove (or comment out) the mail.sh call in the main script to stop the script from attempting to email you.__
```
apt-get install mailutils
```

Email Script: (stored in /root/)
```
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
    echo "Sedning Status Email email@domain.com"
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
```
The script initially reads the contents of the defined "Working Files" the main transcoding scripts have generated and populated during their run prior to the email script executing, and prints this retrieved content into the body of the email, outlining which files were processed as part of the overall transcoding.

The script then slaps a date and time marker in the topic line for easy refence to how long the script was running for during the daily run (my regular runtime is between 15 and 60 minutes depending on how much the DVR recorded that day).

## Main Daily Script (located in /root/)
This is the script that executes all the other scripts. You can add/remove entries as needed, just remember to update all your paths to accomodate new/changed script name for output log and working files to ensure you capture all the work done into the mail.sh processing.
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
```
As you may have noticed by this point, I am a sucker for formatting my output into sections both in GRUB output if you were to run the scripts manually (you may have added content manually or want to test out some specific changes and with the GRUB output sent to the log file you would have zero feedback without some echo commands here and there), to allow you to follow along a little what the main script is doing as well as capture some of the regular transcoding scripts status and the file listing to get a sense of how you are going to wait for.

## Scheduling CRONJOB
Finally we schedule the _dailytranscode.sh_ main script to run at our desired time, in my case 1.00 AM local time:

To Schedule your CRONJOB enter the following in a command line logged in as the user you plan to execute the script as, in my case this is root:
```
crontab -e
```
Add/edit the line where you execute your main dailytranscode.sh script like the following:
```
 * 1 * * * /root/dailytranscode.sh
```
For reference on how to customize crontab see this [PhoenixNap Article](https://phoenixnap.com/kb/set-up-cron-job-linux) which outlines in detail how to customize your specific cron job

_Note: CRONTAB has its own email options and output options, I have specifically written my scripts to build their own output and email functions to retain the functionality when executing the scripts manually, if you like you can explore the CRONTAB options and adapt your setup if you prefer going that route._

Finally check out the Output Exmaples uploaded to the repo for Email output exmaple and FFMPEG output log file exmaples with files found as well as for no files found for the script to get a sense of level of detail these functions perform.

I hope you enjoy this setup and continue your journey down the road of awesome Linux BASH scripting and optimizing the parameters to your specific needs.