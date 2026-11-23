from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

db = firestore.Client()
q = (db.collection("tour_photos")
     .where(filter=FieldFilter("owner", "==", "ana"))
     .order_by("created", direction=firestore.Query.DESCENDING))
print([d.id for d in q.stream()])
