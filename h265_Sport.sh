#!/bin/bash
  echo "-----------------------------------------------------------"
  echo "BASH Script Processing with GRUB output sent to log file:"
  echo "Daily TV Recordings Batch Transcode Scipt"
  echo "Conversion JOB: CronTab:Sport Recordings on $( date '+%F_%H:%M')"
  echo "Converting The Following .TS MPEG2 Files:"
  find . | grep "\.ts$"
  echo "-----------------------------------------------------------"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"/mnt/PlexNFS/Plex/Daily Transcoding/Logs/$( date '+%F_%H:%M')_h265_Sport_log.out" 2>&1
  echo "Daily Sport Recordings Batch Transcode Scipt"
  echo "Conversion JOB: CronTab:Sport Recordings on $( date '+%F_%H:%M')"
  echo "------------------------------------------------------"
  echo "Encoder:	FFMPEG H265_VAAPI"
  echo "CODEC:		H265 (HEVC)"
  echo "Quality: 	27"
  echo "Profile: 	Main"
  echo "Level: 		4.1"
  echo "Features:	VAAPI Deinterlace"
  echo "Progress Update Frequency 10 Seconds"
  echo "Working File: /mnt/PlexNFS/Plex/Daily Transcoding/Working Files/SportScript_$( date +%F).txt"
  echo "Converting The Following .TS MPEG2 Files:"
  find . | grep "\.ts$"
  echo "------------------------------------------------------"
  touch "/mnt/PlexNFS/Plex/Daily Transcoding/Working Files/SportScript_$( date +%F).txt"
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
			-global_quality 27 \
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
  echo "${filename##/}" >> "/mnt/PlexNFS/Plex/Daily Transcoding/Working Files/SportScript_$( date +%F).txt"
  echo "------------------------------------------------------"
done