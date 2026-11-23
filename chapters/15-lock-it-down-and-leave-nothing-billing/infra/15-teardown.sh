#!/usr/bin/env bash
# Removes everything SnapShelf created. Deleting the project is final after 30 days.
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
read -r -p "Delete project $PROJECT_ID and everything in it? (type the ID) " answer
[ "$answer" = "$PROJECT_ID" ] || { echo "cancelled"; exit 1; }

# stop the pipeline first, so nothing deploys while we clean up
gh variable set GCP_DEPLOY --body false || true

gcloud iam workload-identity-pools providers delete snapshelf \
  --workload-identity-pool=github-ci --location=global --quiet || true
gcloud iam workload-identity-pools delete github-ci --location=global --quiet || true

gcloud projects delete "$PROJECT_ID" --quiet
gcloud projects describe "$PROJECT_ID" --format="value(lifecycleState)"
