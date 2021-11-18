#!/bin/bash

# create geo mapping
curl -s -H "Content-type: application/json" -X PUT localhost:9200/_template/cloudflare -d'{
  "template": "cloudflare-*",
  "settings": {},
  "mappings": {
      "properties": {
        "geoip" : {
          "properties" : {
            "location" : {
              "type" : "geo_point"
            }
          }
        },
        "@timestamp": {
          "type": "date"
        }
      }
  }
}'

# import dashboards into kibana
curl -s -H "kbn-xsrf: true" -X POST localhost:5601/api/saved_objects/_import?overwrite=true --form file=@/scripts/export.ndjson
