import datetime, json, os, socket, uuid
from fastapi import FastAPI, HTTPException, UploadFile

app = FastAPI(title="SnapShelf")
DATA = os.environ.get("DATA_DIR", "data")
INDEX = os.path.join(DATA, "photos.json")
os.makedirs(os.path.join(DATA, "photos"), exist_ok=True)

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
    with open(os.path.join(DATA, "photos", photo_id), "wb") as f:
        f.write(data)
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
