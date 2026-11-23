#!/usr/bin/env bash
set -euo pipefail

: "${PROJECT_ID:?set PROJECT_ID first}"

gcloud projects create "$PROJECT_ID" --name="SnapShelf" \
  --labels=app=snapshelf,env=learning --set-as-default

BILLING_ACCOUNT=$(gcloud billing accounts list --filter=open=true \
  --format="value(name.basename())")
gcloud billing projects link "$PROJECT_ID" \
  --billing-account="$BILLING_ACCOUNT"

gcloud services enable billingbudgets.googleapis.com

gcloud billing budgets create --billing-account="$BILLING_ACCOUNT" \
  --display-name="snapshelf-5usd" --budget-amount=5USD \
  --filter-projects="projects/$PROJECT_ID" \
  --credit-types-treatment=exclude-all-credits \
  --threshold-rule=percent=0.5 --threshold-rule=percent=0.9 \
  --threshold-rule=percent=1.0 \
  --threshold-rule=percent=1.0,basis=forecasted-spend
