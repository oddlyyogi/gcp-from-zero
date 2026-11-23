import base64, io, json, os

import functions_framework
from google.api_core.exceptions import PreconditionFailed
from google.cloud import storage
from PIL import Image, UnidentifiedImageError

client = storage.Client()
UPLOADS = os.environ["UPLOADS_BUCKET"]
THUMBS = os.environ["THUMBS_BUCKET"]
SIZE = (256, 256)

@functions_framework.cloud_event
def make_thumbnail(event):
    info = event.data
    if not isinstance(info, dict):
        info = json.loads(info)
    msg = json.loads(base64.b64decode(info["message"]["data"]))
    name = f"photos/{msg['photo_id']}"
    data = client.bucket(UPLOADS).blob(name).download_as_bytes()
    try:
        img = Image.open(io.BytesIO(data)).convert("RGB")
    except UnidentifiedImageError:
        print(f"not an image: {name}")
        return
    img.thumbnail(SIZE)
    out = io.BytesIO()
    img.save(out, "JPEG", quality=85)
    target = client.bucket(THUMBS).blob(name + ".jpg")
    try:
        target.upload_from_string(out.getvalue(), content_type="image/jpeg",
                                  if_generation_match=0)
    except PreconditionFailed:
        print(f"already done: {name}")
        return
    print(f"thumbnail for {name}: {img.size[0]}x{img.size[1]}")
