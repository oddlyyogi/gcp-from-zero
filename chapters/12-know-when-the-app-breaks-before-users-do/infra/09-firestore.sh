#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"

gcloud services enable firestore.googleapis.com
gcloud firestore databases create --location=us-central1

gcloud firestore indexes composite create --collection-group=photos \
  --field-config=field-path=owner,order=ascending \
  --field-config=field-path=created,order=descending

RUN_SA="snapshelf-run@$PROJECT_ID.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding "$PROJECT_ID" --condition=None \
  --member="serviceAccount:$RUN_SA" --role=roles/datastore.user
