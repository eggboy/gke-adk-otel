#!/bin/sh
# Build the agent image with Cloud Build and push it to Artifact Registry,
# using PROJECT_ID, LOCATION, and AR_REPO from ./.env (same file render.sh uses).
#
#   ./build.sh            # pushes ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/adk-demo-agent:latest
#
# Needs only POSIX sh and gcloud.
set -eu
cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "error: .env not found. Run: cp .env.example .env   (then edit it)" >&2
  exit 1
fi

set -a
# .env is user-created and git-ignored, so ShellCheck cannot follow it.
# shellcheck source=/dev/null
. ./.env
set +a

# Fail fast with a clear message if any required key is missing or empty.
: "${PROJECT_ID:?is not set in .env}"
: "${LOCATION:?is not set in .env}"
: "${AR_REPO:?is not set in .env}"

image="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/adk-demo-agent:latest"

echo "Building and pushing ${image}" >&2
cd app
exec gcloud builds submit \
  --project="$PROJECT_ID" \
  --config=cloudbuild.yaml \
  --substitutions="_LOCATION=${LOCATION},_REPO=${AR_REPO}"
