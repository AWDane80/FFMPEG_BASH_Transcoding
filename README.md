# FFMPEG_BASH_Transcoding
Debian Based BASH Script Project for daily transcoding of video files on Intel based iGPU (non-free repo) with VAAPI surface + deinterlacing

As newly converted Windows to Linux user for my home Plex Server setup I have several proejcts I am working on to automate and optimze the setup, one of these were a way to automatically transcode DVR recordings from MPEG2 .TS files to H265 (HEVC) .MKV (Matroska) containers for more efficient storage usage and retain device compability to avoid playback issues and need for live transcoding.

Coming form a Windows setup (Win11) with Plex Media Server and supporting software, specfically MCEBuddy for transcoding management/scheduling, I decided to adopt some of the concepts MCEBuddy utlizes but change others as I learned more about FFMPEG and general BASH scripting. 

Full disclosure I am in no way a Linux or BASH savant and I imagine there are many optimizations and/or security issues that can be done. My setup is exclusively a home setup with zero public exposure outside of VPN connections!
----------------------------------------------------------------
Basic Setup info:
My specific setup is running on a ProxMox Virtual environment in a priviliged (you can make it run unpriviliged with some tweaks) container with 4 cores (Intel N100) and 4 GB RAM, however this is basic Debian (or any other degular distro to my understanding) so this should all be fully transferable to any bare metal or virtual environment where you have direct access to the Intel iGPU.
Note: You can run this general solution with software processing as opossed to HW accellerated transcoding, however you would have to change the encoding scripts to fit the x265lib encoder and its specific parameters, which would generate quality output video but at a significant processor cost. I may play around with this in the future when I upgrade the homelab and comapre the outcomes, but for now my N100 Alder Lake is doing an outstanding job and producing quality outcomes at 8 watt cost, yes this machine runs at just 8 watts when in full utilization mode, it's pretty damn impressive.

I am not going to go over the passthrough and general LXC setup to gian access to the render hardware here, you can find details on this from Jim's Garage https://youtu.be/0ZDr5h52OOE?si=upQh3_PikvpoJ5Ck (video) https://github.com/JamesTurland/JimsGarage/tree/main/LXC/Jellyfin (instructions) which are technically for a Jellyfin container setup, but the basics are the same in terms of passing through the iGPU to your LXC. 

My Plex Media Server is running on the same ProxMox node but as its own separate LXC and all media files on NFS shares from a dedicated NFS/NAS (I prefer to manage my file shares manually, so I am not utilzing any NAS software but rather managing NFS and SMB shares myself on bare metal Debian), hosted on a RAID5 48TB ext4 array (you can do ZFS if you like, will need memory and ensure you understand ZFS fully to entrust your media files to it, again I perfer hardware RAID for this purpose, there are many other situations where I would go with ZFS),
