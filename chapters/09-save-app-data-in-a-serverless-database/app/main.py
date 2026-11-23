import datetime, json, os, socket, uuid
from fastapi import FastAPI, Header, HTTPException, UploadFile
import google.auth
from google.auth.transport.requests import Request
from google.cloud import storage
from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

app = FastAPI(title="SnapShelf")
API_KEY = os.environ.get("API_KEY", "")
bucket = storage.Client().bucket(os.environ["BUCKET"])
db = firestore.Client()
photos_col = db.collection("photos")

@app.get("/health")
def healthz():
    return {"status": "ok", "version": os.environ.get("APP_VERSION", "dev"),
            "host": socket.gethostname()}

@app.post("/photos", status_code=201)
async def upload(file: UploadFile, owner: str = "anon",
                 x_api_key: str = Header(default="")):
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(401, "missing or wrong API key")
    if not (file.content_type or "").startswith("image/"):
        raise HTTPException(415, "only images")
    data = await file.read()
    photo_id = uuid.uuid4().hex[:12]
    blob = bucket.blob(f"photos/{photo_id}")
    blob.upload_from_string(data, content_type=file.content_type)
    now = datetime.datetime.now(datetime.UTC)
    photo = {"id": photo_id, "owner": owner, "size": len(data),
             "type": file.content_type, "created": now, "likes": 0}
    photos_col.document(photo_id).set(photo)
    return photo

@app.get("/photos")
def list_photos(owner: str | None = None):
    q = photos_col
    if owner:
        q = q.where(filter=FieldFilter("owner", "==", owner))
    q = q.order_by("created", direction="DESCENDING").limit(50)
    return [d.to_dict() for d in q.stream()]

@app.get("/photos/{photo_id}")
def get_photo(photo_id: str):
    snap = photos_col.document(photo_id).get()
    photo = snap.to_dict() if snap.exists else None
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

@app.post("/photos/{photo_id}/likes")
def like(photo_id: str):
    ref = photos_col.document(photo_id)
    if not ref.get().exists:
        raise HTTPException(404, "no such photo")
    ref.update({"likes": firestore.Increment(1)})
    return ref.get().to_dict()
