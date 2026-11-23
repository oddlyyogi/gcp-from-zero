#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
TABLE="$PROJECT_ID:snapshelf_analytics.upload_events"
NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
PUBSUB_AGENT="service-$NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com"

bq --location=us-central1 mk --dataset --default_table_expiration=7776000 \
  "$PROJECT_ID:snapshelf_analytics"
bq mk --table --schema=infra/upload_events_schema.json \
  --time_partitioning_field=publish_time --time_partitioning_type=DAY \
  --time_partitioning_expiration=7776000 --require_partition_filter=true \
  "$TABLE"

gcloud pubsub topics add-iam-policy-binding photo-events \
  --member="serviceAccount:snapshelf-run@$PROJECT_ID.iam.gserviceaccount.com" \
  --role=roles/pubsub.publisher
bq add-iam-policy-binding --member="serviceAccount:$PUBSUB_AGENT" \
  --role=roles/bigquery.dataEditor "$TABLE"
gcloud pubsub subscriptions create upload-events-bq --topic=photo-events \
  --bigquery-table="$TABLE" --use-table-schema --write-metadata \
  --drop-unknown-fields
