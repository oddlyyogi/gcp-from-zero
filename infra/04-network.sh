#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"

for r in default-allow-internal default-allow-ssh default-allow-rdp \
  default-allow-icmp; do
  gcloud compute firewall-rules delete "$r" -q || true
done
gcloud compute networks delete default -q || true

gcloud compute networks create snapshelf-vpc --subnet-mode=custom
gcloud compute networks subnets create snapshelf-subnet \
  --network=snapshelf-vpc --region=us-central1 --range=10.10.0.0/24 \
  --enable-private-ip-google-access

gcloud compute firewall-rules create snapshelf-allow-iap \
  --network=snapshelf-vpc --direction=INGRESS --action=ALLOW \
  --rules=tcp:22,tcp:8080 --source-ranges=35.235.240.0/20 \
  --target-tags=snapshelf-vm
gcloud services enable iap.googleapis.com
