#!/bin/bash
#
# README: This script will upload all files from your DAILY_BACKUP_FOLDER to
# a path on an S3 bucket specified by S3_ROOT_PATH. Once the upload is
# successful and the filesizes match for the uploaded and local file
# it will delete the local file.
# -------------------------------------------------------------------
DAILY_BACKUP_FOLDER="/var/lib/demisto/backup"
S3_ROOT_PATH="s3://fy-s3-bucket-test/demisto-backup"

# S3 upload function
function upload_to_s3() {
    filepath=$1
    filename=$(basename $filepath)
    dir=$(basename $2)
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Executing: aws s3 cp $filepath $S3_ROOT_PATH/$dir/$filename"
    aws s3 cp $filepath "$S3_ROOT_PATH/$dir/$filename"
}
dir=$DAILY_BACKUP_FOLDER
echo ""
echo "Working on $dir:"
for file in $(find $dir -type f -regex ".*\.gzip" )
do
filepath=$(echo $file | sed 's/\/\//\//g')
filesize=$(stat -c%s $filepath)
base_filename=$(basename $filepath)
s3_dir=$(basename $dir)
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Uploading $filepath with size $filesize bytes."
upload_to_s3 $filepath $dir
filesize_s3=$(aws s3 ls $S3_ROOT_PATH/$s3_dir/$base_filename | awk '{print $3}')
echo "### filesize_s3 for $base_filename with filepath $S3_ROOT_PATH/$s3_dir/$base_filename is $filesize_s3"
if [ "$filesize_s3" -eq "$filesize" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Filesizes for $base_filename equal on S3 and locally. Deleting local copy";
    rm $filepath
else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] For $base_filename. Localsize: $filesize, S3 uploaded size: $filesize_s3"
fi
done