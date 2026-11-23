import datetime
import google.auth
from google.auth.transport.requests import AuthorizedSession

creds, project = google.auth.default()
now = datetime.datetime.now(datetime.UTC)
start = now - datetime.timedelta(minutes=15)
url = f"https://monitoring.googleapis.com/v3/projects/{project}/timeSeries"
params = {"filter": 'metric.type="monitoring.googleapis.com/uptime_check/check_passed"',
          "interval.startTime": start.isoformat(), "interval.endTime": now.isoformat()}
for ts in AuthorizedSession(creds).get(url, params=params).json().get("timeSeries", []):
    ok = ts["points"][0]["value"]["boolValue"]
    print(ts["metric"]["labels"]["checker_location"], "passed" if ok else "FAILED")
