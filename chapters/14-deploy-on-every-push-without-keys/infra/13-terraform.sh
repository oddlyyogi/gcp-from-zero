#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
export TF_VAR_project_id="$PROJECT_ID"

# one-time: a versioned bucket for Terraform state
if ! gcloud storage buckets describe "gs://$PROJECT_ID-tfstate" >/dev/null 2>&1; then
  gcloud storage buckets create "gs://$PROJECT_ID-tfstate" --location=us-central1 \
    --uniform-bucket-level-access --public-access-prevention
  gcloud storage buckets update "gs://$PROJECT_ID-tfstate" --versioning
fi

cd "$(dirname "$0")/terraform"
terraform init -backend-config="bucket=$PROJECT_ID-tfstate"
terraform fmt -check
terraform validate
terraform plan -out=tfplan
read -r -p "Apply this plan? (yes/no) " answer
[ "$answer" = yes ] && terraform apply tfplan
