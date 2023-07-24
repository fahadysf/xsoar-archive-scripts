#!/bin/bash
#
# README: This script creates compressed archives of Demisto data 
# based on the official documentation for freeing up disk space
# by archiving data. The ARCHIVE_FOLDER and THRESHOLD are configurable.
# -------------------------------------------------------------------

#### SETTINGS ####
BASE_LOCATION="/var/lib/demisto/data"
ARCHIVE_FOLDER="/var/lib/demisto-archive"
# Threshold of oldness in days to archive data for
THRESHOLD=60

# Use with care. This will delete the local copy of the data
DELETE_LOCAL=false

# Core activity
mkdir -p $ARCHIVE_FOLDER

folder="demistoidx"
mkdir -p $ARCHIVE_FOLDER/$folder
for i in $(find $BASE_LOCATION/$folder -maxdepth 2 -type d -mtime +$THRESHOLD -regextype posix-extended -regex ".*/\w+_[0-9]+")
do 
    data_name=$(basename $i)
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Saving $i into $ARCHIVE_FOLDER/$folder/$data_name.tar.gz"
    echo "Moving the data"
    cp -fr $BASE_LOCATION/$folder/$data_name $ARCHIVE_FOLDER/$folder/$data_name
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Making a Compressed TAR Archive ($data_name.tar.gz)"
    tar -czf $ARCHIVE_FOLDER/$folder/$data_name.tar.gz $ARCHIVE_FOLDER/$folder/$data_name
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Deleting the uncompressed folder $ARCHIVE_FOLDER/$folder/$data_name"
    if $DELETE_LOCAL
    then    
        rm -fr $ARCHIVE_FOLDER/$folder/$data_name 
        rm -fr $BASE_LOCATION/$folder/$data_name
    fi
done

folder="partitionsData"
mkdir -p $ARCHIVE_FOLDER/$folder
for i in $(find $BASE_LOCATION/$folder -maxdepth 2 -type f -mtime +$THRESHOLD -regextype posix-extended -regex ".*/\w+_[0-9]+.db")
do 
    data_name=$(basename $i)
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Saving $i into $ARCHIVE_FOLDER/$folder/$data_name.tar.gz"
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Moving the data"
    cp -fr $BASE_LOCATION/$folder/$data_name $ARCHIVE_FOLDER/$folder/$data_name 
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Making a Compressed TAR Archive ($data_name.tar.gz)"
    gzip -f $ARCHIVE_FOLDER/$folder/$data_name 
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Deleting the uncompressed data $ARCHIVE_FOLDER/$folder/$data_name"
    if $DELETE_LOCAL
    then
        rm -fr $ARCHIVE_FOLDER/$folder/$data_name 
        rm -fr $BASE_LOCATION/$folder/$data_name
    fi
done

archive_folder_size=$(du -hs $ARCHIVE_FOLDER/)
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Size of compressed data in $ARCHIVE_FOLDER is $archive_folder_size"
