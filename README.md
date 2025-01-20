# FFMPEG_BASH_Transcoding
Debian Based BASH Script Project for daily transcoding of video files on Intel based iGPU (non-free repo) with VAAPI surface + deinterlacing

As newly converted Windows to Linux user for my home Plex Server setup I have several proejcts I am working on to automate and optimze the setup, one of these were a way to automatically transcode DVR recordings from MPEG2 .TS files to H265 (HEVC) .MKV (Matroska) containers for more efficient storage usage and retain device compability to avoid playback issues and need for live transcoding.

Coming form a Windows setup (Win11) with Plex Media Server and supporting software, specfically MCEBuddy for transcoding management/scheduling, I decided to adopt some of the concepts MCEBuddy utlizes but change others as I learned more about FFMPEG and general BASH scripting. 

Full disclosure I am in no way a Linux or BASH savant and I imagine there are many optimizations and/or security issues that can be done. My setup is exclusively a home setup with zero public exposure outside of VPN connections!

Basic Setup info:
My specific setup is running on a ProxMox Virtual environment in a priviliged (you can make it run unpriviliged with some tweaks) container with 4 cores (Intel N100) and 4 GB RAM
