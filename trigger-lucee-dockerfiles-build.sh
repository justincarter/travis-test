#!/bin/sh

# read current job log
sleep 10s
curl -s "https://api.travis-ci.org/v3/job/${TRAVIS_JOB_ID}/log.txt?deansi=true" > travis_output.log

# get lucee version
LUCEE_VERSION=$(grep -oP "(?<=\[INFO\] Building Lucee Loader Build )(\d+\.\d+\.\d+\.\d+(.*)?)" travis_output.log)
echo "LUCEE_VERSION = $LUCEE_VERSION\n"

# build the travis request body
REQUEST_BODY=`cat <<EOF
  {
    "request": {
      "message": "Testing automated build for version $LUCEE_VERSION",
      "branch":"travis-build-matrix",
      "config": {
        "merge_mode": "deep_merge",
        "env": {
          "global": {
            "LUCEE_VERSION": "$LUCEE_VERSION"
          }
        }
      }
    }
  }
EOF
`
echo "REQUEST_BODY = $REQUEST_BODY"

# trigger the lucee-dockerfiles travis job for this lucee version
curl -v -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token $TRAVIS_TOKEN" \
  -d "$REQUEST_BODY" \
  https://api.travis-ci.org/repo/lucee%2Flucee-dockerfiles/requests
