#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
DEPLOY_SA="snapshelf-deploy@$PROJECT_ID.iam.gserviceaccount.com"

gcloud services enable artifactregistry.googleapis.com \
  cloudbuild.googleapis.com
gcloud artifacts repositories create snapshelf --location=us-central1 \
  --repository-format=docker --description="SnapShelf images"
gcloud artifacts repositories set-cleanup-policies snapshelf \
  --location=us-central1 --policy=infra/cleanup-policy.json --no-dry-run

gcloud projects add-iam-policy-binding "$PROJECT_ID" --condition=None \
  --member="serviceAccount:$DEPLOY_SA" --role=roles/logging.logWriter
gcloud artifacts repositories add-iam-policy-binding snapshelf \
  --location=us-central1 --member="serviceAccount:$DEPLOY_SA" \
  --role=roles/artifactregistry.writer
gcloud projects add-iam-policy-binding "$PROJECT_ID" --condition=None \
  --member="serviceAccount:$DEPLOY_SA" --role=roles/storage.objectUser
