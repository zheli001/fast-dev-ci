#!/bin/bash
SCOPE=$1
for d in $SCOPE; do
  if [[ $d == "sample-service" ]]; then
    echo "Verification failed for $d"
    exit 1
  fi
done
