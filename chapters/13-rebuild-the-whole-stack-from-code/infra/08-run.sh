#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
RUN_SA="snapshelf-run@$PROJECT_ID.iam.gserviceaccount.com"
IMAGE="us-central1-docker.pkg.dev/$PROJECT_ID/snapshelf/api:${TAG:-v3}"

gcloud services enable secretmanager.googleapis.com run.googleapis.com
python3 -c "import secrets; print(secrets.token_urlsafe(24), end='')" \
  | gcloud secrets create snapshelf-api-key --data-file=-
gcloud secrets add-iam-policy-binding snapshelf-api-key \
  --member="serviceAccount:$RUN_SA" \
  --role=roles/secretmanager.secretAccessor

gcloud run deploy snapshelf --image="$IMAGE" --region=us-central1 \
  --service-account="$RUN_SA" \
  --set-env-vars="BUCKET=$PROJECT_ID-uploads" \
  --set-secrets="API_KEY=snapshelf-api-key:latest" \
  --max=3 --min-instances=0 --allow-unauthenticated
