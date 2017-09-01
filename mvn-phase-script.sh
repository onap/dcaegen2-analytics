#!/bin/bash

echo "running script: [$0] for module [$1] at stage [$2]"

echo "=> Prepare environment "
#env

TIMESTAMP=$(date +%C%y%m%dT%H%M%S) 
export BUILD_NUMBER="${TIMESTAMP}"

# expected environment variables 
if [ -z "${MVN_NEXUSPROXY}" ]; then
    echo "MVN_NEXUSPROXY environment variable not set.  Cannot proceed"
    exit
fi
MVN_NEXUSPROXY_HOST=$(echo $MVN_NEXUSPROXY |cut -f3 -d'/' | cut -f1 -d':')


# use the version text detect which phase we are in in LF CICD process: verify, merge, or (daily) release

# mvn phase in life cycle 
MVN_PHASE="$2"

case $MVN_PHASE in
clean)
  echo "==> clean phase script"
  ;;
generate-sources)
  echo "==> generate-sources phase script"
  ;;
compile)
  echo "==> compile phase script"

  set -x
  echo '================= STARTING SCRIPT TO CREATE DEBIAN FILE ================='
  # Extract the username and password to the nexus repo from the settings file
  USER=$(xpath -q -e "//servers/server[id='ecomp-raw']/username/text()" "$SETTINGS_FILE")
  PASS=$(xpath -q -e "//servers/server[id='ecomp-raw']/password/text()" "$SETTINGS_FILE")
  REPO="${MVN_NEXUSPROXY}/content/sites/raw"
  NETRC=$(mktemp)
  echo "machine nexus.onap.org login $USER password $PASS" > "$NETRC"
  #echo "NETRC=$NETRC" > "$WORKSPACE/netrc_env.txt"


  OUTPUT_FILE='analytics.wgn'
  echo "Test" > ${OUTPUT_FILE}

  SEND_TO="${REPO}/org.onap.dcaegen2.analytics/todelete/${OUTPUT_FILE}"
  echo "Sending ${OUTPUT_FILE} to Nexus: ${SEND_TO}"
  curl -vkn --netrc-file "${NETRC}" --upload-file ${OUTPUT_FILE} ${SEND_TO}

  ;;
test)
  echo "==> test phase script"
  ;;
package)
  echo "==> package phase script"
  ;;
install)
  echo "==> install phase script"
  ;;
deploy)
  echo "==> deploy phase script"
  ;;
*)
  echo "==> unprocessed phase"
  ;;
esac

