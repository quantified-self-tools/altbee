#!/usr/bin/env bash

set -euo pipefail

export MIX_ENV=prod

mix clean
mix distillery.release.clean
rm -rf priv/static/

mix format --check-formatted

mix deps.get
mix compile --warnings-as-errors

npm ci --prefix assets
NODE_ENV=production npm run deploy --prefix assets

mix phx.digest
mix distillery.release --warnings-as-errors
