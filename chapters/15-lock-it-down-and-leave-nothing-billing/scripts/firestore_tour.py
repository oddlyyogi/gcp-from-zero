from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

db = firestore.Client()
photos = db.collection("tour_photos")

photos.document("p1").set({"owner": "ana", "size": 2094, "likes": 0,
                           "created": firestore.SERVER_TIMESTAMP})
photos.document("p2").set({"owner": "bo", "size": 5120, "likes": 0,
                           "created": firestore.SERVER_TIMESTAMP})
photos.document("p3").set({"owner": "ana", "size": 777, "likes": 0,
                           "created": firestore.SERVER_TIMESTAMP})

photos.document("p1").update({"likes": firestore.Increment(1)})
print("p1:", photos.document("p1").get().to_dict())

for doc in photos.where(filter=FieldFilter("owner", "==", "ana")).stream():
    print("ana has", doc.id, doc.get("size"))

big = photos.order_by("size", direction=firestore.Query.DESCENDING).limit(2)
print("largest:", [d.id for d in big.stream()])

p1_comments = photos.document("p1").collection("comments")
p1_comments.add({"by": "bo", "text": "nice"})
p1_comments.add({"by": "chen", "text": "wow"})
p2_comments = photos.document("p2").collection("comments")
p2_comments.add({"by": "ana", "text": "great"})
print("p1 comments:", [c.get("text") for c in p1_comments.stream()])
everyone = db.collection_group("comments").stream()
print("all comments:", sorted(c.get("text") for c in everyone))

from google.cloud.firestore_v1.query_profile import ExplainOptions
res = photos.where(filter=FieldFilter("owner", "==", "ana")).stream(
    explain_options=ExplainOptions(analyze=True))
list(res)
stats = res.get_explain_metrics().execution_stats
print("reads billed:", stats.read_operations)
