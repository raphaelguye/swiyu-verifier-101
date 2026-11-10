#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

echo "Creating additional DID space for partner ID: $SWIYU_PARTNER_ID"

RESPONSE=$(curl -s -X POST \
  "$SWIYU_IDENTIFIER_REGISTRY_URL/api/v1/identifier/business-entities/$SWIYU_PARTNER_ID/identifier-entries" \
  -H "Authorization: Bearer $SWIYU_IDENTIFIER_REGISTRY_ACCESS_TOKEN" \
  -H "Content-Type: application/json")

echo "Response: $RESPONSE"

echo ""
echo "Save the identifierRegistryUrl value in your .env variable IDENTIFIER_REGISTRY_URL_2"
echo "Save the id value in your .env variable IDENTIFIER_REGISTRY_ID_2"
echo ""
