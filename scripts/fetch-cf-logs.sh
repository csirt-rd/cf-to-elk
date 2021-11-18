#!/bin/bash

# date
CF_DATE=$(date +"%Y-%m-%d")

# add one min to our request since we have to start one minute behind
((CF_LOGS_FETCH_MIN+=1))

# set from and to times
CF_FROM_TIME=$(date +"%H:%M:%S" --date "-${CF_LOGS_FETCH_MIN} min" --utc)
CF_TO_TIME=$(date +"%H:%M:%S" --date "-1 min"--utc)
# replace colons with periods for filename
CF_FROM_TIME_FILENAME=$(echo ${CF_FROM_TIME} | sed 's/:/./g')
CF_TO_TIME_FILENAME=$(echo ${CF_TO_TIME} | sed 's/:/./g')

# grab logs from cloudflare
for i in $(echo ${CF_ZONES} | sed "s/,/ /g"); do
  OUTPUT_DIR="/logstash-logs/${i}/${CF_DATE}"
  OUTPUT_LOG="${OUTPUT_DIR}/${CF_FROM_TIME_FILENAME}-${CF_TO_TIME_FILENAME}.gz"
  mkdir -p "${OUTPUT_DIR}"
  curl -H "accept-encoding: gzip" -H "X-Auth-Email: ${CF_EMAIL}" -H "X-Auth-Key: ${CF_API_KEY}" "https://api.cloudflare.com/client/v4/zones/${i}/logs/received?start=${CF_DATE}T${CF_FROM_TIME}Z&end=${CF_DATE}T${CF_TO_TIME}Z&fields=${CF_FIELDS}" > ${OUTPUT_LOG}
done
