#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
LOG='resource.type="cloud_run_revision" AND resource.labels.service_name="snapshelf"'
URL=$(gcloud run services describe snapshelf --region=us-central1 \
  --format="value(status.url)")

gcloud logging metrics create upload_rejected \
  --description="Rejected SnapShelf uploads" \
  --log-filter="$LOG AND jsonPayload.event=\"upload_rejected\""
gcloud monitoring uptime create snapshelf-health --resource-type=uptime-url \
  --resource-labels="host=${URL#https://},project_id=$PROJECT_ID" \
  --protocol=https --path=/health --period=5 \
  --regions=usa-iowa,usa-oregon,usa-virginia
gcloud monitoring dashboards create --config-from-file=infra/dashboard.json
# The email channel and the two alert policies are created through the
# Monitoring API and infra/alert-uptime.json, as shown in the video.
