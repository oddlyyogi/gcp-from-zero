import datetime, json, os, socket, uuid
from fastapi import FastAPI, Header, HTTPException, UploadFile
from fastapi import Request as HttpRequest
import google.auth
from google.auth.transport.requests import Request
from google.cloud import storage
from google.cloud import pubsub_v1
from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

app = FastAPI(title="SnapShelf")
API_KEY = os.environ.get("API_KEY", "")
PROJECT = google.auth.default()[1]
bucket = storage.Client().bucket(os.environ["BUCKET"])
db = firestore.Client()
photos_col = db.collection("photos")
def log(severity, message, request=None, **fields):
    entry = {"severity": severity, "message": message, **fields}
    trace = request.headers.get("x-cloud-trace-context") if request else ""
    if trace:
        tid = trace.split("/")[0]
        key = "logging.googleapis.com/trace"
        entry[key] = f"projects/{PROJECT}/traces/{tid}"
    print(json.dumps(entry), flush=True)
publisher = pubsub_v1.PublisherClient()
TOPIC = publisher.topic_path(google.auth.default()[1], "photo-events")

@app.get("/health")
def healthz():
    if os.environ.get("BREAK_HEALTH") == "1":
        raise HTTPException(500, "health check broken for a drill")
    return {"status": "ok", "version": os.environ.get("APP_VERSION", "dev"),
            "host": socket.gethostname()}

@app.post("/photos", status_code=201)
async def upload(request: HttpRequest, file: UploadFile,
                 owner: str = "anon",
                 x_api_key: str = Header(default="")):
    if API_KEY and x_api_key != API_KEY:
        log("WARNING", "upload rejected", request, event="upload_rejected",
            reason="api_key", owner=owner)
        raise HTTPException(401, "missing or wrong API key")
    if not (file.content_type or "").startswith("image/"):
        log("WARNING", "upload rejected", request, event="upload_rejected",
            reason="not_image", owner=owner)
        raise HTTPException(415, "only images")
    data = await file.read()
    photo_id = uuid.uuid4().hex[:12]
    blob = bucket.blob(f"photos/{photo_id}")
    blob.upload_from_string(data, content_type=file.content_type)
    now = datetime.datetime.now(datetime.UTC)
    photo = {"id": photo_id, "owner": owner, "size": len(data),
             "type": file.content_type, "created": now, "likes": 0}
    photos_col.document(photo_id).set(photo)
    event = {"photo_id": photo_id, "owner": owner, "bytes": len(data),
             "content_type": file.content_type}
    data_out = json.dumps(event).encode()
    publisher.publish(TOPIC, data_out, source="api").result()
    log("INFO", "photo uploaded", request, event="upload_ok",
        photo_id=photo_id, owner=owner, bytes=len(data))
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

@app.get("/boom")
def boom():
    return {"result": 1 / 0}
