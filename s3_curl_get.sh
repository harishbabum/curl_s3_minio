#!/bin/bash
# usage: ./minio-upload my-bucket my-file.zip
set -x
bucket=$1
file=$2

host=nighthawk-n03.faction-lab.com:9000
s3_key='minioadmin'
s3_secret='minioadmin'

resource="/${bucket}/${file}"
content_type="application/octet-stream"
date=`date -R`
_signature="GET\n\n${content_type}\n${date}\n${resource}"
signature=`echo -en ${_signature} | openssl sha1 -hmac ${s3_secret} -binary | base64`

start=$(date +%s)
#curl -L -o /dev/null www.google.com 2>&1
curl -k -L -X  GET -o "${file}" \
          -H "Host: $host" \
          -H "Date: ${date}" \
          -H "Content-Type: ${content_type}" \
          -H "Authorization: AWS ${s3_key}:${signature}" \
          https://$host${resource}


#Caluclating Transfer Speed:
end=$(date +%s)
runtime=$((end-start))
file_size=$(ls -l --block-size=M $file  | awk -F' ' '{print $5}')
size=$(echo $file_size | sed 's/.$//')
transfer_speed=$(( $size / $runtime ))
echo $transfer_speed MB/S
