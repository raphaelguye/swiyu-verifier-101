# swiyu Verifier 101

A quick guide to set up and test the [swiyu-verifier](https://github.com/swiyu-admin-ch/swiyu-verifier) service for VC verification.

## Prerequisites

- Docker and Docker Compose
- ngrok (for external access)

## DID creation and registration

Based on the [official cookbook](https://swiyu-admin-ch.github.io/cookbooks/onboarding-base-and-trust-registry/):

1. Register a business partner on ePortal
2. Create a `.env` based on the [.env template](./.env.template)
3. Run the following scripts
  1. `1-create-did-space.sh`
    1. Set the variable `IDENTIFIER_REGISTRY_URL` in `.env`
    2. Set the variable `IDENTIFIER_REGISTRY_ID` in `.env`
  2. `2-create-first-did.sh`
  3. `3-upload-didlog.sh`

🚀 You should have a DID register in the base registry.

## Trust Registry Onboarding

Based on the [official cookbook](https://swiyu-admin-ch.github.io/cookbooks/onboarding-base-and-trust-registry/):

4. Run `4-create-trust-PoP.sh`
   - Fetches the pending trust onboarding submission (DID + one-time nonce) from the trust registry
   - Signs the nonce with your assertion private key using the DID Toolbox
   - Prints the signed Proof-of-Possession JWT
5. Run `5-submit-PoP.sh <pop_jwt>` with the JWT printed by the previous script
6. Process on the KYB process on the platform, which require at some point the PoP submitted

🚀 You should now be registered in the trust registry.

## Adding an additional DID

Based on [section 6 of the cookbook](https://swiyu-admin-ch.github.io/cookbooks/onboarding-base-and-trust-registry/#6-adding-additional-dids). Requires the first DID to be onboarded in the trust registry.

1. `6a-create-additional-did-space.sh`: set `IDENTIFIER_REGISTRY_URL_2` and `IDENTIFIER_REGISTRY_ID_2` in `.env`
2. `7-create-additional-did.sh`: creates the DID and keys in `./did2/.didtoolbox/`
3. `8-upload-additional-didlog.sh`

   Already have the DID? Run `6b-import-existing-additional-did.sh` instead of 6a to 8: it asks for the DID, the key files and the log (or downloads it from the registry) and stores them in `./did2/.didtoolbox/`.

4. `9-create-add-dids-PoPs.sh`: creates the trust-add-dids submission and the PoPs of both DIDs
5. `10-submit-add-dids-PoPs.sh <submission_id> <pop_jwt_1> <pop_jwt_2>` with the values printed by the previous script

Check the result (requires `SWIYU_TRUST_REGISTRY_ACCESS_TOKEN`); `status` should become `SUCCEEDED`:

```bash
curl -s "https://trust-reg-api.trust-infra.swiyu-int.admin.ch/api/v1/trust/trust-add-dids-submissions/<submission_id>" \
  -H "Authorization: Bearer $SWIYU_TRUST_REGISTRY_ACCESS_TOKEN" | jq
```

## swiyu-verifier Setup

The config has been done following the [official cookbook](https://swiyu-admin-ch.github.io/cookbooks/onboarding-generic-verifier/).
The next sections explain how to run this verifier locally and test it with the swiyu wallet app.

### 1. Start Local Services

```bash
cd swiyu-verifier
docker compose up -d

# Verify services are running
docker compose ps
```

Expected services: verifier-service (port 8083) and postgres (port 5434)

### 2. Expose Service for local debugging

In order to be able to be tested with a phone:

```bash
# Expose verifier service
ngrok http 8083

# Update EXTERNAL_URL in docker-compose.yml with the ngrok HTTPS URL
```

## Testing

### Create Verification Request

1. Open Swagger UI: http://localhost:8083/swagger-ui/index.html
2. Use `POST /management/api/verifications` with a payload such as:

```json
{
  "presentation_definition": {
    "id": "simple-test",
    "name": "Simple Test",
    "purpose": "Testing basic verification",
    "input_descriptors": [
      {
        "id": "any-credential",
        "name": "Any Credential",
        "format": {
          "vc+sd-jwt": {
            "sd-jwt_alg_values": ["ES256"],
            "kb-jwt_alg_values": ["ES256"]
          }
        },
        "constraints": {
          "fields": [
            {
              "path": ["$.family_name"]
            }
          ]
        }
      }
    ]
  }
}
```

3. Copy the `verification_url` or `verification_deeplink` from the response
4. Use it with the official swiyu wallet to complete verification 
  (requires a credential with `family_name` claim, e.g., [BetaID](https://www.bcs.admin.ch/bcs-web/#/))

### Check Verification Status

Use `GET /management/api/verifications/{verificationId}` to monitor status changes from PENDING to SUCCESS once the wallet has send a valid verification response.