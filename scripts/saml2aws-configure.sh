#!/usr/bin/env bash

set -euo pipefail

export OP_ITEM="${OP_ITEM:?OP_ITEM required}"
export OP_FIELD_USERNAME="${OP_FIELD_USERNAME:-username}"
export OP_FIELD_PASSWORD="${OP_FIELD_PASSWORD:-password}"
export OP_FIELD_OKTA_URL="${OP_FIELD_OKTA_URL:-unified-aws-url}"

saml2aws configure \
  --idp-provider Okta \
  --url "$(op item get "$OP_ITEM" --fields "$OP_FIELD_OKTA_URL")" \
  --username "$(op item get "$OP_ITEM" --fields "$OP_FIELD_USERNAME")"\
  --password "$(op item get "$OP_ITEM" --fields "$OP_FIELD_PASSWORD" --reveal)"\
  --profile default
