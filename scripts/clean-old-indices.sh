#!/usr/bin/env bash
#
# Script to clean up the old logs
#
#

#Keep 10 days
days_ago=${ES_INDEX_RETENTION_DAYS}

# Variable used to count the number of cleaned indices
counter=0

# Elasticsearch connection info
ELASTICSEARCH_HOST="localhost"
ELASTICSEARCH_PORT="9200"
ELASTICSEARCH_USER="elastic"
ELASTICSEARCH_PASSWORD="elastic"

get_month(){
  if [ `uname` == "Darwin" ]; then
    date -v-$1d "+%m"
  else
    date +"%m" --date="-$1 day"
  fi
}

get_day(){
  if [ `uname` == "Darwin" ]; then
    date -v-$1d "+%d"
  else
    date +"%d" --date="-$1 day"
  fi
}

get_year(){
  if [ `uname` == "Darwin" ]; then
    date -v-$1d "+%Y"
  else
    date +"%Y" --date="-$1 day"
  fi
}


# Extract the current list of indices
INDICES=`curl -s http://${ELASTICSEARCH_USER}:${ELASTICSEARCH_PASSWORD}@${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_cat/indices?v`

echo "Current indices:"
echo "$INDICES"

while true; do
  month=$(get_month "$days_ago")
  day=$(get_day "$days_ago")
  year=$(get_year "$days_ago")

  INDICE_TO_DELETE="cloudflare-$year.$month.$day"

  # Test if the indice already exist.
  # If it doesn't exist, it means it has already been deleted
  # Which mean we can escape the loop
  echo "$INDICES" | grep -q "$INDICE_TO_DELETE"
  if [[ $? != 0 ]]; then
    echo "$counter indexes deleted"
    exit 0
  fi

  # Adding logs
  echo "Deleting $INDICE_TO_DELETE"

  curl -s -XDELETE http://${ELASTICSEARCH_USER}:${ELASTICSEARCH_PASSWORD}@${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${INDICE_TO_DELETE} > /dev/null
  echo
  sleep 1
  days_ago=$[$days_ago+1]
  counter=$[$counter+1]
done
