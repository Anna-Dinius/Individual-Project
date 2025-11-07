import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase app (only once in your app)
cred = credentials.Certificate('../serviceAccountKey.json')
firebase_admin.initialize_app(cred)

# Firestore client
db = firestore.client()

# Function to fetch and print menu IDs
def print_all_menu_ids():
    try:
        menus_ref = db.collection('menus')
        docs = menus_ref.stream()

        for doc in docs:
            print(doc.id)
    except Exception as e:
        print(f"Error fetching menu IDs: {e}")

# Example usage
print_all_menu_ids()