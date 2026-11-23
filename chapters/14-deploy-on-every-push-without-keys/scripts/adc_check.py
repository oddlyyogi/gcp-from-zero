import google.auth
from google.cloud import storage

creds, project = google.auth.default()
print("credentials:", type(creds).__name__)
print("project:", project)
client = storage.Client(project=project)
print("buckets:", len(list(client.list_buckets())))
