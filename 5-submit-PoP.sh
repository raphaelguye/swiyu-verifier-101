#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# Accept the PoP JWT as a command-line argument or env variable
POP_JWT="${1:-$POP_JWT}"

if [ -z "$POP_JWT" ]; then
  echo "Usage: $0 <pop_jwt>"
  echo "  or set POP_JWT environment variable"
  echo ""
  echo "The PoP JWT is printed at the end of 4-fetch-PoP-challenge.sh"
  exit 1
fi

echo "Submitting Proof-of-Possession for partner ID: $SWIYU_PARTNER_ID"
echo "Using Trust Registry URL: https://trust-reg-api.trust-infra.swiyu-int.admin.ch"

curl -X POST \
  "https://trust-reg-api.trust-infra.swiyu-int.admin.ch/api/v1/trust/trust-onboarding-submission/proof-of-possessions" \
  -H "Authorization: Bearer $SWIYU_TRUST_REGISTRY_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"proofOfPossessions\": [\"$POP_JWT\"]}" \
  -v

echo ""
echo "Proof-of-Possession submitted. Trust onboarding submission complete."
