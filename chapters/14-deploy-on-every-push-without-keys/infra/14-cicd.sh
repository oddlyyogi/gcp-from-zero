#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
: "${REPO_ID:?set REPO_ID (gh api repos/OWNER/REPO --jq .id)}"
: "${OWNER_ID:?set OWNER_ID (gh api repos/OWNER/REPO --jq .owner.id)}"
NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
DEPLOY_SA="snapshelf-deploy@$PROJECT_ID.iam.gserviceaccount.com"

gcloud services enable iamcredentials.googleapis.com sts.googleapis.com
gcloud iam workload-identity-pools create github-ci --location=global
gcloud iam workload-identity-pools providers create-oidc snapshelf \
  --location=global --workload-identity-pool=github-ci \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository_id=assertion.repository_id,attribute.repository_owner_id=assertion.repository_owner_id" \
  --attribute-condition="assertion.repository_owner_id == '$OWNER_ID' && assertion.repository_id == '$REPO_ID'"

gcloud iam service-accounts add-iam-policy-binding "$DEPLOY_SA" \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/$NUMBER/locations/global/workloadIdentityPools/github-ci/attribute.repository_id/$REPO_ID"
gcloud run services add-iam-policy-binding snapshelf --region=us-central1 \
  --member="serviceAccount:$DEPLOY_SA" --role=roles/run.developer

echo "GCP_WIF_PROVIDER=projects/$NUMBER/locations/global/workloadIdentityPools/github-ci/providers/snapshelf"
echo "GCP_DEPLOY_SA=$DEPLOY_SA"
