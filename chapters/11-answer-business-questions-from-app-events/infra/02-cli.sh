#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"

ACCOUNT=$(gcloud config get-value account)
gcloud config configurations create snapshelf
gcloud config set account "$ACCOUNT"
gcloud config set project "$PROJECT_ID"
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
gcloud config set run/region us-central1
gcloud config set artifacts/location us-central1

gcloud services enable compute.googleapis.com iam.googleapis.com \
  iamcredentials.googleapis.com cloudquotas.googleapis.com
