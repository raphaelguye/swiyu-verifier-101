#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# Creates a trust-add-dids submission and the PoPs (existing permission DID + new DID) signed with its nonce
DIDTOOLBOX=didtoolbox-2.3.0.jar
ASSERT_KEY_ID="assert-key-01"
TRUST_URL=https://trust-reg-api.trust-infra.swiyu-int.admin.ch

DID_LOG_PATH=./.didtoolbox/_didlog.jsonl
DID2_LOG_PATH=./did2/.didtoolbox/_didlog.jsonl

for f in "$DID_LOG_PATH" "$DID2_LOG_PATH"; do
  if [ ! -f "$f" ]; then
    echo "DID log file not found at $f"
    exit 1
  fi
done

DID=$(head -n 1 "$DID_LOG_PATH" | jq -r '.state.id')
NEW_DID=$(head -n 1 "$DID2_LOG_PATH" | jq -r '.state.id')
echo "Permission DID: $DID"
echo "New DID:        $NEW_DID"

RESPONSE=$(curl -s -X POST "$TRUST_URL/api/v1/trust/trust-add-dids-submissions" \
  -H "Authorization: Bearer $SWIYU_TRUST_REGISTRY_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"permissionDid\": \"$DID\", \"didsToAdd\": [\"$NEW_DID\"]}")

echo "Response: $RESPONSE"

TRUST_ADD_SUBMISSION_ID=$(echo "$RESPONSE" | jq -r '.id')
NONCE_2=$(echo "$RESPONSE" | jq -r '.nonce')
if [ -z "$TRUST_ADD_SUBMISSION_ID" ] || [ "$TRUST_ADD_SUBMISSION_ID" = "null" ] || [ -z "$NONCE_2" ] || [ "$NONCE_2" = "null" ]; then
  echo "Failed to parse submission id / nonce from response."
  exit 1
fi

POP_JWT_1=$(java -jar $DIDTOOLBOX create-pop \
  -d $DID_LOG_PATH \
  -k "${DID}#${ASSERT_KEY_ID}" \
  -s ./.didtoolbox/$ASSERT_KEY_ID \
  -n "$NONCE_2") || exit 1

POP_JWT_2=$(java -jar $DIDTOOLBOX create-pop \
  -d $DID2_LOG_PATH \
  -k "${NEW_DID}#${ASSERT_KEY_ID}" \
  -s ./did2/.didtoolbox/$ASSERT_KEY_ID \
  -n "$NONCE_2") || exit 1

echo ""
echo "Submission ID: $TRUST_ADD_SUBMISSION_ID"
echo ""
echo "Next step:"
echo "  ./10-submit-add-dids-PoPs.sh $TRUST_ADD_SUBMISSION_ID \"$POP_JWT_1\" \"$POP_JWT_2\""
echo ""
echo "Or copy-paste:"
echo "./10-submit-add-dids-PoPs.sh $TRUST_ADD_SUBMISSION_ID \"$POP_JWT_1\" \"$POP_JWT_2\""
