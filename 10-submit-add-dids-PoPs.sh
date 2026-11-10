#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

TRUST_ADD_SUBMISSION_ID="$1"
POP_JWT_1="$2"
POP_JWT_2="$3"

if [ -z "$TRUST_ADD_SUBMISSION_ID" ] || [ -z "$POP_JWT_1" ] || [ -z "$POP_JWT_2" ]; then
  echo "Usage: $0 <submission_id> <pop_jwt_permission_did> <pop_jwt_new_did>"
  echo ""
  echo "The values are printed at the end of 9-create-add-dids-PoPs.sh"
  exit 1
fi

echo "Submitting PoPs for trust-add-dids submission: $TRUST_ADD_SUBMISSION_ID"

curl -X POST \
  "https://trust-reg-api.trust-infra.swiyu-int.admin.ch/api/v1/trust/trust-add-dids-submissions/$TRUST_ADD_SUBMISSION_ID" \
  -H "Authorization: Bearer $SWIYU_TRUST_REGISTRY_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"proofOfPossessions\": [\"$POP_JWT_1\", \"$POP_JWT_2\"]}" \
  -v

echo ""
echo "PoPs submitted. The new DID should now be added to the trust registry."
