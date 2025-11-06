/**
 * Add "item_type" attribute to all documents in menu_items collection
 * Use: node firestore_uploader/add_item_type_attribute_to_menu_items.js
 */

const admin = require('firebase-admin');

admin.initializeApp({
	credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();

// Keyword maps for each item_type
const typeKeywords = {
	entree: [
		'burger',
		'sandwich',
		'pasta',
		'steak',
		'chicken',
		'bowl',
		'wrap',
		'curry',
		'taco',
		'pizza',
		'stir fry',
		'pancake',
		'omelet',
		'waffle',
		'grilled cheese',
		'noodles',
	],
	side: [
		'fries',
		'chips',
		'salad',
		'soup',
		'rice',
		'bread',
		'coleslaw',
		'vegetables',
		'mashed',
		'beans',
		'toast',
		'onion rings',
	],
	appetizer: [
		'appetizer',
		'starter',
		'wings',
		'dip',
		'nachos',
		'spring roll',
		'dumpling',
	],
	drink: [
		'coffee',
		'tea',
		'soda',
		'juice',
		'smoothie',
		'beer',
		'wine',
		'cocktail',
		'latte',
		'milkshake',
	],
	dessert: [
		'cake',
		'cookie',
		'ice cream',
		'brownie',
		'pie',
		'pudding',
		'donut',
		'tart',
		'mousse',
	],
};

// Simple keyword matcher
function inferItemType(name = '', description = '') {
	const text = `${name} ${description}`.toLowerCase();

	for (const [type, keywords] of Object.entries(typeKeywords)) {
		if (keywords.some((keyword) => text.includes(keyword))) {
			return type;
		}
	}

	return 'entree'; // default fallback
}

async function addItemTypeToMenuItems() {
	const snapshot = await db.collection('menu_items').get();

	if (snapshot.empty) {
		console.log('⚠️ No documents found in menu_items.');
		return;
	}

	let updatedCount = 0;

	for (const doc of snapshot.docs) {
		const data = doc.data();
		const itemType = inferItemType(data.name, data.description);

		await doc.ref.update({ item_type: itemType });
		updatedCount++;
	}

	console.log(
		`✅ Updated ${updatedCount} menu_items with inferred "item_type".`
	);
}

addItemTypeToMenuItems().catch(console.error);
