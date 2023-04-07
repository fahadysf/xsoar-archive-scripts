#!/bin/bash
#
# README: This script will upload all files from your ARCHIVE_FOLDER to
# a path on an S3 bucket specified by S3_ROOT_PATH. Once the upload is 
# successful and the filesizes match for the uploaded and local file
# it will delete the local file.
# -------------------------------------------------------------------
ARCHIVE_FOLDER="/var/lib/demisto-archive"
S3_ROOT_PATH="s3://fy-s3-bucket-test/demisto-archive"

# S3 upload function
function upload_to_s3() {
    filepath=$1
    filename=$(basename $filepath)
    dir=$(basename $2)
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Executing: aws s3 cp $filepath $S3_ROOT_PATH/$dir/$filename" 
    aws s3 cp $filepath "$S3_ROOT_PATH/$dir/$filename"
}

for dir in $ARCHIVE_FOLDER/*/
do
    echo ""
    echo "Working on $dir:"
    for file in $(find $dir -type f -regex ".*\.gz" )
    do 
        filepath=$(echo $file | sed 's/\/\//\//g')
        filesize=$(stat -c%s $filepath)
        base_filename=$(basename $filepath)
        base_dirname=$(basename $dir)
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] Uploading $filepath with size $filesize bytes."
        upload_to_s3 $filepath $dir
        filesize_s3=$(aws s3 ls $S3_ROOT_PATH/$base_dirname/$base_filename | awk '{print $3}')
        if [ "$filesize_s3" -eq "$filesize" ]; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] Filesizes for $base_filename equal on S3 and locally. Deleting local copy";
            rm $filepath
        else 
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] For $base_filename. Localsize: $filesize, S3 uploaded size: $filesize_s3"
        fi
    done
done

