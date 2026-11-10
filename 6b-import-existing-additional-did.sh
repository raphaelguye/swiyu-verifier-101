#!/bin/bash

# Imports an already existing DID (log + keys) into ./did2/.didtoolbox so that
# 9-create-add-dids-PoPs.sh can be used without running 6a, 7 and 8.

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

WORK_DIR=./did2/.didtoolbox
DIDLOG_TARGET=$WORK_DIR/_didlog.jsonl
ASSERT_KEY_ID="assert-key-01"

expand_path() { eval echo "${1/#\~/$HOME}"; }

read -r -p "Existing DID (did:webvh:...): " DID
if [ -z "$DID" ]; then
  echo "DID is required."
  exit 1
fi

read -r -p "Path to the DID log file (empty = download from the registry): " DIDLOG_SOURCE
DIDLOG_SOURCE=$(expand_path "$DIDLOG_SOURCE")

read -r -p "Path to the assert PRIVATE key PEM (${ASSERT_KEY_ID}): " ASSERT_KEY_SOURCE
ASSERT_KEY_SOURCE=$(expand_path "$ASSERT_KEY_SOURCE")
if [ ! -f "$ASSERT_KEY_SOURCE" ]; then
  echo "Assert private key not found: $ASSERT_KEY_SOURCE"
  exit 1
fi

read -r -p "Path to the assert PUBLIC key PEM (optional): " ASSERT_PUB_SOURCE
ASSERT_PUB_SOURCE=$(expand_path "$ASSERT_PUB_SOURCE")

read -r -p "Path to the auth PRIVATE key PEM (optional): " AUTH_KEY_SOURCE
AUTH_KEY_SOURCE=$(expand_path "$AUTH_KEY_SOURCE")
read -r -p "Path to the auth PUBLIC key PEM (optional): " AUTH_PUB_SOURCE
AUTH_PUB_SOURCE=$(expand_path "$AUTH_PUB_SOURCE")

read -r -p "Path to the update/signing PRIVATE key PEM (optional, id_ed25519): " SIGNING_KEY_SOURCE
SIGNING_KEY_SOURCE=$(expand_path "$SIGNING_KEY_SOURCE")
read -r -p "Path to the update/signing PUBLIC key PEM (optional, id_ed25519.pub): " SIGNING_PUB_SOURCE
SIGNING_PUB_SOURCE=$(expand_path "$SIGNING_PUB_SOURCE")

if [ -f "$DIDLOG_TARGET" ]; then
  read -r -p "$DIDLOG_TARGET already exists. Overwrite? [y/N] " ANSWER
  [ "$ANSWER" = "y" ] || exit 1
fi

mkdir -p "$WORK_DIR"

if [ -n "$DIDLOG_SOURCE" ]; then
  if [ ! -f "$DIDLOG_SOURCE" ]; then
    echo "DID log not found: $DIDLOG_SOURCE"
    exit 1
  fi
  cp "$DIDLOG_SOURCE" "$DIDLOG_TARGET"
else
  # did:webvh:<scid>:<domain>:<path segments...> -> https://<domain>/<path>/did.jsonl
  IFS=':' read -r -a PARTS <<< "$DID"
  DOMAIN=${PARTS[3]}
  DID_PATH=$(IFS=/; echo "${PARTS[*]:4}")
  URL="https://$DOMAIN/$DID_PATH/did.jsonl"
  echo "Downloading DID log from $URL"
  if ! curl -sfL "$URL" -o "$DIDLOG_TARGET"; then
    echo "Download failed."
    rm -f "$DIDLOG_TARGET"
    exit 1
  fi
fi

LOG_DID=$(head -n 1 "$DIDLOG_TARGET" | jq -r '.state.id')
if [ "$LOG_DID" != "$DID" ]; then
  echo "DID in log ($LOG_DID) does not match the given DID ($DID)."
  rm -f "$DIDLOG_TARGET"
  exit 1
fi

cp "$ASSERT_KEY_SOURCE" "$WORK_DIR/$ASSERT_KEY_ID"
[ -f "$ASSERT_PUB_SOURCE" ] && cp "$ASSERT_PUB_SOURCE" "$WORK_DIR/$ASSERT_KEY_ID.pub"
[ -f "$AUTH_KEY_SOURCE" ] && cp "$AUTH_KEY_SOURCE" "$WORK_DIR/auth-key-01"
[ -f "$AUTH_PUB_SOURCE" ] && cp "$AUTH_PUB_SOURCE" "$WORK_DIR/auth-key-01.pub"
[ -f "$SIGNING_KEY_SOURCE" ] && cp "$SIGNING_KEY_SOURCE" "$WORK_DIR/id_ed25519"
[ -f "$SIGNING_PUB_SOURCE" ] && cp "$SIGNING_PUB_SOURCE" "$WORK_DIR/id_ed25519.pub"
chmod 600 "$WORK_DIR"/* 2>/dev/null

echo ""
echo "Imported DID $DID into $WORK_DIR"
ls -1 "$WORK_DIR"
echo ""
echo "Next step: ./9-create-add-dids-PoPs.sh"
