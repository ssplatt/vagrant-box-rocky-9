#!/usr/bin/env bash
set -e

# https://developer.hashicorp.com/vagrant/vagrant-cloud/api/v2

VAGRANT_TOKEN=${VAGRANT_TOKEN:-""}
VAGRANT_USER=${VAGRANT_USER:-"ssplatt"}
BOX_NAME=${BOX_NAME:-"centos-stream-9"}
VERSION=${VERSION:-"0.0.1"}
PROVIDER=${PROVIDER:-"virtualbox"}
BOX_PATH=${BOX_PATH:-"$PROVIDER/package.box"}
ARCHITECTURE=${ARCHITECTURE:-$(uname -m)}

if [[ "$ARCHITECTURE" == "x86_64" ]]; then
  ARCHITECTURE="amd64"
fi

echo "VAGRANT_USER=$VAGRANT_USER"
echo "BOX_NAME=$BOX_NAME"
echo "VERSION=$VERSION"
echo "BOX_PATH=$BOX_PATH"
echo "PROVIDER=$PROVIDER"
echo "ARCHITECTURE=$ARCHITECTURE"

# Create a new version
is_version=$(curl -s "https://app.vagrantup.com/api/v2/box/${VAGRANT_USER}/${BOX_NAME}/version/${VERSION}/" | jq -r .version)
if [[ "$is_version" == "$VERSION" ]]; then
  echo "... Version $VERSION already exists, adding new provider"
else
  curl \
    --request POST \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer ${VAGRANT_TOKEN}" \
    "https://app.vagrantup.com/api/v2/box/${VAGRANT_USER}/${BOX_NAME}/versions" \
    --data "{ \"version\": { \"version\": \"${VERSION}\" } }"
fi

# Create a new provider
if [[ "$ARCHITECTURE" == "amd64" ]]; then
  default_arch=true
else
  default_arch=false
fi
curl \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer ${VAGRANT_TOKEN}" \
  "https://app.vagrantup.com/api/v2/box/${VAGRANT_USER}/${BOX_NAME}/version/${VERSION}/providers" \
  --data "{ \"provider\": { \"name\": \"${PROVIDER}\",
            \"architecture\": \"${ARCHITECTURE}\",
            \"default_architecture\": ${default_arch}} }"

# Prepare the provider for upload/get an upload URL
response=$(curl \
    --request GET \
    --header "Authorization: Bearer ${VAGRANT_TOKEN}" \
    "https://app.vagrantup.com/api/v2/box/${VAGRANT_USER}/${BOX_NAME}/version/${VERSION}/provider/${PROVIDER}/${ARCHITECTURE}/upload")

# Extract the upload URL from the response (requires the jq command)
upload_path=$(echo "$response" | jq -r .upload_path)

# Perform the upload
curl \
    --request PUT \
    --upload-file "${BOX_PATH}" \
    "$upload_path"

# Release the version
curl \
  --request PUT \
  --header "Authorization: Bearer ${VAGRANT_TOKEN}" \
  "https://app.vagrantup.com/api/v2/box/${VAGRANT_USER}/${BOX_NAME}/version/${VERSION}/release"
