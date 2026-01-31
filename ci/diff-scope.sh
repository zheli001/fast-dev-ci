#!/bin/bash
# Simple diff to get changed directories
SCOPE=$(git diff --name-only @{upstream}...HEAD | cut -d/ -f1 | sort -u)
export SCOPE
echo "Changed scope: $SCOPE"
export SCOPE_HASH=$(echo $SCOPE | md5sum | cut -d' ' -f1)
echo "Scope hash: $SCOPE_HASH"
