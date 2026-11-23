import os
from unittest import mock

import pytest
from fastapi.testclient import TestClient

os.environ.setdefault("BUCKET", "test-bucket")
os.environ["API_KEY"] = "test-key"


@pytest.fixture(scope="module")
def client():
    creds = mock.MagicMock()
    auth = mock.patch("google.auth.default",
                      return_value=(creds, "test-project"))
    with auth, mock.patch("google.cloud.storage.Client"), \
            mock.patch("google.cloud.firestore.Client"), \
            mock.patch("google.cloud.pubsub_v1.PublisherClient"):
        from app import main
        yield TestClient(main.app)


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_upload_needs_key(client):
    files = {"file": ("a.png", b"x", "image/png")}
    assert client.post("/photos", files=files).status_code == 401


def test_upload_rejects_text(client):
    files = {"file": ("a.txt", b"hello", "text/plain")}
    headers = {"X-API-Key": "test-key"}
    r = client.post("/photos", files=files, headers=headers)
    assert r.status_code == 415


def test_upload_ok(client):
    files = {"file": ("a.png", b"\x89PNG photo", "image/png")}
    headers = {"X-API-Key": "test-key"}
    r = client.post("/photos?owner=ana", files=files, headers=headers)
    assert r.status_code == 201
    assert r.json()["owner"] == "ana"
    assert r.json()["size"] == 10
