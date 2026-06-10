#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# echo "Access Token: $SWIYU_IDENTIFIER_REGISTRY_ACCESS_TOKEN"
echo "Creating DID space for partner ID: $SWIYU_PARTNER_ID"
echo "Using Identifier Registry URL: $SWIYU_IDENTIFIER_REGISTRY_URL"

# Run the curl command
curl \
  -H "Authorization: Bearer $SWIYU_IDENTIFIER_REGISTRY_ACCESS_TOKEN" \
  -X POST "$SWIYU_IDENTIFIER_REGISTRY_URL/api/v1/identifier/business-entities/$SWIYU_PARTNER_ID/identifier-entries" \
  -v

echo 
echo "DID space created successfully!"
echo "Save the identifierRegistryUrl value in your .env variable IDENTIFIER_REGISTRY_URL"
echo "save the identifierRegistryId value in your .env variable IDENTIFIER_REGISTRY_ID"
echo 