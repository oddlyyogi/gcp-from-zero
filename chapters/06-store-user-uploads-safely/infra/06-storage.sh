#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
BUCKET="gs://$PROJECT_ID-uploads"
RUN_SA="snapshelf-run@$PROJECT_ID.iam.gserviceaccount.com"

gcloud storage buckets create "$BUCKET" --location=us-central1 \
  --default-storage-class=STANDARD --uniform-bucket-level-access \
  --public-access-prevention --labels=app=snapshelf
gcloud storage buckets update "$BUCKET" --versioning \
  --lifecycle-file=infra/lifecycle.json

gcloud storage buckets add-iam-policy-binding "$BUCKET" \
  --member="serviceAccount:$RUN_SA" --role=roles/storage.objectUser
gcloud iam service-accounts add-iam-policy-binding "$RUN_SA" \
  --member="serviceAccount:$RUN_SA" \
  --role=roles/iam.serviceAccountTokenCreator
