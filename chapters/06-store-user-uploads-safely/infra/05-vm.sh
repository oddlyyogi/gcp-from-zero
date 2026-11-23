#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?set PROJECT_ID first}"

gcloud compute instances create snapshelf-vm --zone=us-central1-a \
  --machine-type=e2-micro --subnet=snapshelf-subnet --tags=snapshelf-vm \
  --image-family=debian-12 --image-project=debian-cloud \
  --boot-disk-size=10GB --boot-disk-type=pd-standard \
  --service-account="snapshelf-run@$PROJECT_ID.iam.gserviceaccount.com" \
  --scopes=cloud-platform \
  --metadata=enable-oslogin=TRUE \
  --metadata-from-file=startup-script=infra/vm-startup.sh,\
app-main=app/main.py,app-reqs=requirements.txt
