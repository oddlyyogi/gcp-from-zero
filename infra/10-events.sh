#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"
THUMBS_SA="snapshelf-thumbs@$PROJECT_ID.iam.gserviceaccount.com"
EVENTS_SA="snapshelf-events@$PROJECT_ID.iam.gserviceaccount.com"

gcloud services enable pubsub.googleapis.com eventarc.googleapis.com
gcloud pubsub topics create photo-events
gcloud pubsub topics add-iam-policy-binding photo-events \
  --member="serviceAccount:snapshelf-run@$PROJECT_ID.iam.gserviceaccount.com" \
  --role=roles/pubsub.publisher
gcloud storage buckets create "gs://$PROJECT_ID-thumbs" \
  --location=us-central1 --uniform-bucket-level-access \
  --public-access-prevention
gcloud iam service-accounts create snapshelf-thumbs
gcloud iam service-accounts create snapshelf-events

gcloud storage buckets add-iam-policy-binding "gs://$PROJECT_ID-uploads" \
  --member="serviceAccount:$THUMBS_SA" --role=roles/storage.objectViewer
gcloud storage buckets add-iam-policy-binding "gs://$PROJECT_ID-thumbs" \
  --member="serviceAccount:$THUMBS_SA" --role=roles/storage.objectCreator
gcloud projects add-iam-policy-binding "$PROJECT_ID" --condition=None \
  --member="serviceAccount:$EVENTS_SA" --role=roles/eventarc.eventReceiver

gcloud run deploy snapshelf-thumbs --source=functions/thumbnail \
  --function=make_thumbnail --base-image=python314 --region=us-central1 \
  --no-allow-unauthenticated --service-account="$THUMBS_SA" \
  --set-env-vars="UPLOADS_BUCKET=$PROJECT_ID-uploads,THUMBS_BUCKET=$PROJECT_ID-thumbs" \
  --memory=1Gi --max=2
gcloud run services add-iam-policy-binding snapshelf-thumbs \
  --region=us-central1 --member="serviceAccount:$EVENTS_SA" \
  --role=roles/run.invoker

gcloud eventarc triggers create photo-uploaded --location=us-central1 \
  --destination-run-service=snapshelf-thumbs \
  --destination-run-region=us-central1 \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --transport-topic=photo-events --service-account="$EVENTS_SA"
