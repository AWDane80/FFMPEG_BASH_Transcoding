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
_Note: lines in a BASH script that ends with a \ is a way to tell the parser that it is continued line rather than a new specific line to parse, so you will see in the main FFMPEG section the lines generally end with \ to allow all the parameters to be properly parsed but retain a more read friendly format for editing specific paramters._

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

This parameter for the video encorder is enabling the __"Low Power"__ mode of the processor, __NOTE: This only works if your specific Intel Processor is capable of working in Low Power mod for the specific codec (H265/HEVC in this case).__ I recommend testing the script without the log file enabled (earlier section) and test your processors ability to do this. I see some pretty solid increase in encoding performance when enabled for my specifc Alder Lake processor (N100), change the paramter to "false" if your command line execution fails and test again.
```
-low_power true \
```

This is the built in VAAPI deinterlacer to encode videos in progressive mode, I have seen solid performance on my processor, but note that deinterlacing costs CPU power and can't be entirely hardware offloaded, however for basic video transcoding this is fairly small and I am seeing near zero reduction in performance.
```
-vf deinterlace_vaapi \
```

### Quality Settings:
This is the quality setting for the H265/HEVC encoder to aim for, the lower the value the higher the bitrate aka quality, I have found for 1080 video values between 23 (movies) and 28 (sport/live content) is all acceptable ranges, test with your specific video sources and evaluate quality vs. file size.
```
-global_quality 23 \
```

### RC Mode, Read Carefully to understand the specific tuning of the encoder used in my scripts:
This is one the most important parameters in your FFMPEG video encoder to understand. This took me a little while to understand and eventually decided to build my transcoder scripts around.
```
-rc_mode 1 \
```
"RC Mode" is a setting in FFMPEG that configured that encoder to s specific quality or bitrage paradigm. Spefically for VAAPI's H265/HEVC Encoder there are six (technically seven)RC Modes avilable to it, you retrieve the compatible modes by running this command in your Linux terminal:
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

You can reduce the file size by adoption other modes such as the popular __ICQ (4)__ RC Mode, which analyzes frames in more detail to optimize the bitrate scene by scene or rather frame by frame. For my purpose I saw very little (practically none) quality impact on the files and very small improvements to file sizes for DVR recordings, so I decided to go with keeping things simple and stcking the contant quality mode and simply change the global quality setting depending on source material.

_Note: I plan to create a __High Quality Encoder__ for ripped physical media (BluRay/DVD, all owned, not pirating here!) and will likely be testing that with RC Mode 4 aka ICQ settings, depending on outcome I will post an update script for that when I have results with a separate documentation._

_Note: __Low Power Mode__ only work with: CQP (1), CBR (2), VBR (3), QVBR (5)_

### Profile and Levels:
```
-profile:v main \
-level 123 \
```
This spefically sets the encorder to use a specific H265/HEVC profile (Main) and Level (4.1) which specifies some limitations to the content of the file. Check out the Wiki Article on H265/HEVC Profiles and Levels to understand more. 

I have configured the encoder to use what would be near the lowest common denominator allowing for 1080P resolution and bitrates high enough to accomodate my specific needs as well as retain compability with my playback devices, unless you have some specific needs or need to encode __4K material (which requires at least level 5)__ this is a great middle of the road setting. You could theoretically drop the level a little for 720P video but you are almost certain to have devices able to natively read 4.1 levels if they can do H265/HEVC in the first place.

If you do want to mess around with levels for some reason, run the command:
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
As you probably see, the interger in the middle section indicates a logical way to refer to the level in the FFMPEG command line. My scripts are set to "Level 4.1" or "123", to encode 4K material you would have to bumb this up to at least "Level 5.0" or "150".

