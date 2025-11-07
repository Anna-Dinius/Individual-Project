import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase app (only once in your app)
cred = credentials.Certificate('../serviceAccountKey.json')
firebase_admin.initialize_app(cred)

# Firestore client
db = firestore.client()

# Define Restaurant model (simplified)
class Restaurant:
    def __init__(self, name, id=None):
        self.name = name
        self.id = id

    @staticmethod
    def from_dict(data):
        return Restaurant(name=data.get('name'), id=data.get('id'))

# Function to fetch and print restaurant names
def print_all_restaurant_names():
    try:
        restaurants_ref = db.collection('restaurants')
        docs = restaurants_ref.stream()

        for doc in docs:
            data = doc.to_dict()
            restaurant = Restaurant.from_dict(data)
            print(restaurant.name)
    except Exception as e:
        print(f"Error fetching restaurant names: {e}")

# Example usage
print_all_restaurant_names()