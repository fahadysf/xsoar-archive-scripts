#!/bin/bash
# This script is usefule for backing up artifacets and other
# important files mentioned in the official docs for full server 
# migrations.
# --------------------------------------------------------------

#CONFIG PARAMETERS
BACKUP_LOG="/tmp/demisto-other-paths-backup.log"
BACKUP_PATH="/var/lib/demisto-archive/other_backups/"

# Do not edit below this line
items=("/var/lib/demisto/artifacts" \
"/var/lib/demisto/attachments" \
"/var/lib/demisto/images" \
"/var/lib/demisto/d2_server.key" \
"/var/lib/demisto/tools" \
"/var/lib/demisto/versionControlRepo" \
"/usr/local/demisto" \
"/etc/demisto.conf")

# Try to create the directory if it doesn't exist
mkdir -p $BACKUP_PATH

echo "Backup attempted at $(date)" > $BACKUP_LOG
for i in "${items[@]}"
do
    tarfilename=$(echo $i | sed "s/\//_/g" | sed 's/^.//g')".$(date +"%Y%m%d%H%M%S").tar.gz"
    echo $(date +"[%Y-%m-%d %H:%M:%S]")" Saving conents of $i in $tarfilename" >> $BACKUP_LOG
    tar -czf $tarfilename $i >>$BACKUP_LOG 2>&1
done
