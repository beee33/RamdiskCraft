### Small script to have a neoforge server to be run in Linux Ramdisk for better disk performance, it periodictly has ramdisk sync to disk to prevent dataloss.

#### to use:
1) git clone https://github.com/beee33/RamdiskCraft
2) copy neoforge/forge server in the /server directory
3) run `sudo bash start.sh <ramdisk-storage-size>`
4) use ^C or /stop to exit server. 

Notes:
- ramdisk can only be as large as free memory avalible
- there could be risk of filesystem corruption so make sure to keep a backup of the server
