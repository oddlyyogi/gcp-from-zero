# Google Cloud from Zero: SnapShelf

[![ci](https://github.com/oddlyyogi/gcp-from-zero/actions/workflows/ci.yml/badge.svg)](https://github.com/oddlyyogi/gcp-from-zero/actions/workflows/ci.yml)

The code for the **Google Cloud from Zero** video course. One project, **SnapShelf**, a small photo-sharing API in
Python (FastAPI), grows chapter by chapter on a Google Cloud Free Trial account: a project with budgets, the gcloud CLI,
IAM and service accounts, a private VPC, a free e2-micro VM, Cloud Storage with signed URLs, a container image built by
Cloud Build, Cloud Run with Secret Manager, Firestore, Pub/Sub + Eventarc + a thumbnail function, BigQuery analytics,
logging and alerting, Terraform, GitHub Actions with Workload Identity Federation, and finally a full teardown.

The root of this repository is the finished project. Each chapter's finished project is in [`chapters/`](chapters).
Every `infra/NN-*.sh` script repeats the commands of chapter NN; set `PROJECT_ID` first. Nothing here contains keys:
the apps use Application Default Credentials and attached service accounts.

| # | Chapter | Folder |
|---|---------|--------|
| 1 | Open a Google Cloud Account Without a Surprise Bill | [chapters/01-open-an-account-without-a-surprise-bill](chapters/01-open-an-account-without-a-surprise-bill) |
| 2 | Drive Google Cloud From Your Terminal | [chapters/02-drive-google-cloud-from-your-terminal](chapters/02-drive-google-cloud-from-your-terminal) |
| 3 | Give People and Apps Only the Access They Need | [chapters/03-give-people-and-apps-only-the-access-they-need](chapters/03-give-people-and-apps-only-the-access-they-need) |
| 4 | Build a Private Network for the App | [chapters/04-build-a-private-network-for-the-app](chapters/04-build-a-private-network-for-the-app) |
| 5 | Run the First Server on a Free VM | [chapters/05-run-the-first-server-on-a-free-vm](chapters/05-run-the-first-server-on-a-free-vm) |
| 6 | Store User Uploads Safely | [chapters/06-store-user-uploads-safely](chapters/06-store-user-uploads-safely) |
| 7 | Package the App Once, Run It Anywhere | [chapters/07-package-the-app-once-run-it-anywhere](chapters/07-package-the-app-once-run-it-anywhere) |
| 8 | Ship the API Without Managing Servers | [chapters/08-ship-the-api-without-managing-servers](chapters/08-ship-the-api-without-managing-servers) |
| 9 | Save App Data in a Serverless Database | [chapters/09-save-app-data-in-a-serverless-database](chapters/09-save-app-data-in-a-serverless-database) |
| 10 | React to Every Upload Automatically | [chapters/10-react-to-every-upload-automatically](chapters/10-react-to-every-upload-automatically) |
| 11 | Answer Business Questions From App Events | [chapters/11-answer-business-questions-from-app-events](chapters/11-answer-business-questions-from-app-events) |
| 12 | Know When the App Breaks Before Users Do | [chapters/12-know-when-the-app-breaks-before-users-do](chapters/12-know-when-the-app-breaks-before-users-do) |
| 13 | Rebuild the Whole Stack From Code | [chapters/13-rebuild-the-whole-stack-from-code](chapters/13-rebuild-the-whole-stack-from-code) |
| 14 | Deploy on Every Push Without Keys | [chapters/14-deploy-on-every-push-without-keys](chapters/14-deploy-on-every-push-without-keys) |
| 15 | Lock It Down and Leave Nothing Billing | [chapters/15-lock-it-down-and-leave-nothing-billing](chapters/15-lock-it-down-and-leave-nothing-billing) |

## Try it

```bash
python3.12 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
export PROJECT_ID=your-project-id   # then follow the infra/ scripts chapter by chapter
```

Stay inside the Always Free limits shown in the videos (us-central1, e2-micro, standard disk, Cloud Run with
min-instances 0) and delete what you create the same day.

## Versions

Google Cloud CLI 594.0.1, Python 3.12, FastAPI 0.165.0, google-cloud-storage 3.17.1, google-cloud-firestore 2.34.1,
google-cloud-pubsub 2.44.0, Pillow 13.0.0, functions-framework 3.10.2, Terraform 1.17.2.

## License

MIT
