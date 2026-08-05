#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

DIDTOOLBOX=didtoolbox-2.3.0.jar
DID_LOG_PATH=./.didtoolbox/_didlog.jsonl
ASSERT_KEY_ID="assert-key-01"
ASSERT_KEY_PEM=.didtoolbox/$ASSERT_KEY_ID

echo "Fetching Proof-of-Possession challenge for partner ID: $SWIYU_PARTNER_ID"
echo "Using Trust Registry URL: https://trust-reg-api.trust-infra.swiyu-int.admin.ch"

RESPONSE=$(curl -s -X GET \
  "https://trust-reg-api.trust-infra.swiyu-int.admin.ch/api/v1/trust/trust-onboarding-submission/proof-of-possessions" \
  -H "Authorization: Bearer $SWIYU_TRUST_REGISTRY_ACCESS_TOKEN")

echo "Response: $RESPONSE"

DID=$(echo "$RESPONSE" | jq -r '.[0].did')
NONCE=$(echo "$RESPONSE" | jq -r '.[0].nonce')

if [ -z "$DID" ] || [ "$DID" = "null" ]; then
  echo "Failed to parse DID from response."
  exit 1
fi
if [ -z "$NONCE" ] || [ "$NONCE" = "null" ]; then
  echo "Failed to parse nonce from response."
  exit 1
fi

echo ""
echo "DID:   $DID"
echo "Nonce: $NONCE"
echo ""
echo "Creating Proof of Possession..."

java -jar $DIDTOOLBOX create-pop \
  -d $DID_LOG_PATH \
  -k "${DID}#${ASSERT_KEY_ID}" \
  -s $ASSERT_KEY_PEM \
  -n "$NONCE"
