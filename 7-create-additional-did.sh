#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# Keys and DID log of the additional DID live in ./did2/.didtoolbox to keep them apart from the first DID
DIDTOOLBOX=$(pwd)/didtoolbox-2.3.0.jar
WORK_DIR=./did2

if [ -z "$IDENTIFIER_REGISTRY_URL_2" ]; then
  echo "IDENTIFIER_REGISTRY_URL_2 is not set in .env (see 6a-create-additional-did-space.sh or 6b-import-existing-additional-did.sh)"
  exit 1
fi

mkdir -p "$WORK_DIR/.didtoolbox"
if [ -f "$WORK_DIR/.didtoolbox/_didlog.jsonl" ]; then
  echo "$WORK_DIR/.didtoolbox/_didlog.jsonl already exists, refusing to overwrite."
  exit 1
fi

echo "Creating additional DID in the DID space: $IDENTIFIER_REGISTRY_URL_2"

(cd "$WORK_DIR" && java -jar "$DIDTOOLBOX" create --identifier-registry-url "$IDENTIFIER_REGISTRY_URL_2" > .didtoolbox/_didlog.jsonl) || exit 1

echo "DID: $(head -n 1 $WORK_DIR/.didtoolbox/_didlog.jsonl | jq -r '.state.id')"
echo "DID log saved in $WORK_DIR/.didtoolbox/_didlog.jsonl"
echo "Keys saved in $WORK_DIR/.didtoolbox/"
