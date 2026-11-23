import datetime, json, os, socket, uuid
from fastapi import FastAPI, HTTPException, UploadFile
import google.auth
from google.auth.transport.requests import Request
from google.cloud import storage

app = FastAPI(title="SnapShelf")
DATA = os.environ.get("DATA_DIR", "data")
INDEX = os.path.join(DATA, "photos.json")
os.makedirs(DATA, exist_ok=True)
bucket = storage.Client().bucket(os.environ["BUCKET"])

def load():
    if not os.path.exists(INDEX):
        return {}
    with open(INDEX) as f:
        return json.load(f)

def save(photos):
    with open(INDEX, "w") as f:
        json.dump(photos, f, indent=2)

@app.get("/healthz")
def healthz():
    return {"status": "ok", "host": socket.gethostname()}

@app.post("/photos", status_code=201)
async def upload(file: UploadFile, owner: str = "anon"):
    if not (file.content_type or "").startswith("image/"):
        raise HTTPException(415, "only images")
    data = await file.read()
    photo_id = uuid.uuid4().hex[:12]
    blob = bucket.blob(f"photos/{photo_id}")
    blob.upload_from_string(data, content_type=file.content_type)
    now = datetime.datetime.now(datetime.UTC).isoformat(timespec="seconds")
    photo = {"id": photo_id, "owner": owner, "size": len(data),
             "type": file.content_type, "created": now}
    photos = load()
    photos[photo_id] = photo
    save(photos)
    return photo

@app.get("/photos")
def list_photos():
    return list(load().values())

@app.get("/photos/{photo_id}")
def get_photo(photo_id: str):
    photo = load().get(photo_id)
    if not photo:
        raise HTTPException(404, "no such photo")
    creds, _ = google.auth.default()
    creds.refresh(Request())
    url = bucket.blob(f"photos/{photo_id}").generate_signed_url(
        version="v4", expiration=datetime.timedelta(minutes=15),
        method="GET",
        service_account_email=creds.service_account_email,
        access_token=creds.token)
    return {**photo, "url": url}
