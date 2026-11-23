#!/bin/bash
set -euxo pipefail

apt-get update
apt-get install -y python3-venv

MD=http://metadata.google.internal/computeMetadata/v1/instance/attributes
get() { curl -sf -H "Metadata-Flavor: Google" "$MD/$1"; }

mkdir -p /opt/snapshelf/app
get app-main > /opt/snapshelf/app/main.py
touch /opt/snapshelf/app/__init__.py
get app-reqs > /opt/snapshelf/requirements.txt

python3 -m venv /opt/snapshelf/.venv
/opt/snapshelf/.venv/bin/pip install -q -r /opt/snapshelf/requirements.txt

cat > /etc/systemd/system/snapshelf.service <<'EOF'
[Unit]
Description=SnapShelf API
After=network-online.target
[Service]
ExecStart=/opt/snapshelf/.venv/bin/uvicorn app.main:app \
  --host 0.0.0.0 --port 8080 --app-dir /opt/snapshelf
DynamicUser=yes
StateDirectory=snapshelf
WorkingDirectory=/var/lib/snapshelf
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable snapshelf
systemctl restart snapshelf
