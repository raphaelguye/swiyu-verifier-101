#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

DIDTOOLBOX=didtoolbox-1.3.1-jar-with-dependencies.jar # currently, only working with v1.3.1

echo "local java version: $(java -version 2>&1 | head -n 1)"
echo "Creating first DID in the DID space: $IDENTIFIER_REGISTRY_URL"

# Parameter
java -jar $DIDTOOLBOX create --identifier-registry-url $IDENTIFIER_REGISTRY_URL

echo ""
echo "TODO: Save the DID log output in ./.didtoolbox/_didlog.jsonl for the next step"
echo ""
