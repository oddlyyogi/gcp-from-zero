#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
RUN_SA="snapshelf-run@$PROJECT_ID.iam.gserviceaccount.com"
DEPLOY_SA="snapshelf-deploy@$PROJECT_ID.iam.gserviceaccount.com"

gcloud iam service-accounts create snapshelf-run \
  --display-name="SnapShelf runtime"
gcloud iam service-accounts create snapshelf-deploy \
  --display-name="SnapShelf deployer"

for role in roles/logging.logWriter roles/monitoring.metricWriter; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$RUN_SA" --role="$role" --condition=None
done

gcloud iam service-accounts add-iam-policy-binding "$RUN_SA" \
  --member="serviceAccount:$DEPLOY_SA" --role="roles/iam.serviceAccountUser"

ACCOUNT=$(gcloud config get-value account)
gcloud iam service-accounts add-iam-policy-binding "$RUN_SA" \
  --member="user:$ACCOUNT" --role="roles/iam.serviceAccountTokenCreator"
