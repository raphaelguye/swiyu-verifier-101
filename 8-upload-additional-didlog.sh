#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

DIDLOG_FILE_PATH=./did2/.didtoolbox/_didlog.jsonl
if [ ! -f "$DIDLOG_FILE_PATH" ]; then
  echo "DID log file not found at $DIDLOG_FILE_PATH"
  exit 1
fi

echo "Uploading DID log to Identifier Registry $IDENTIFIER_REGISTRY_ID_2 for partner ID: $SWIYU_PARTNER_ID"

curl --data-binary @$DIDLOG_FILE_PATH \
    -H "Authorization: Bearer $SWIYU_IDENTIFIER_REGISTRY_ACCESS_TOKEN" \
    -H "Content-Type: application/jsonl+json" \
    -X PUT "$SWIYU_IDENTIFIER_REGISTRY_URL/api/v1/identifier/business-entities/$SWIYU_PARTNER_ID/identifier-entries/$IDENTIFIER_REGISTRY_ID_2" \
    -v

echo ""
echo "→ Try to get the DID log to confirm:"
echo "  $ curl \"$SWIYU_IDENTIFIER_REGISTRY_URL/api/v1/did/$IDENTIFIER_REGISTRY_ID_2/did.jsonl\""
