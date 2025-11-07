/**
 * Delete menu_items from Firestore db
 * Use: node firestore_uploader/delete_menu_items.js
 */

const admin = require('firebase-admin');
const fs = require('fs');

admin.initializeApp({
	credential: admin.credential.cert(require('../serviceAccountKey.json')),
});

const db = admin.firestore();

// Load menu_items
let menuItems = require('./new_data/menu_items.json');

// Delete matching menu_items
async function deleteMenuItems() {
	for (const item of menuItems) {
		const ref = db.collection('menu_items').doc(item.id);
		const doc = await ref.get();

		if (doc.exists) {
			await ref.delete();
			console.log(`🗑️ Deleted menu_item with ID: ${item.id}`);
		} else {
			console.log(`⚠️ No document found for ID: ${item.id}`);
		}
	}

	console.log('✅ Deletion complete.');
}

deleteMenuItems().catch(console.error);
/**
 * Delete menu_items from Firestore db
 * Use: node firestore_uploader/delete_menu_items.js
 */

const admin = require('firebase-admin');
const fs = require('fs');

admin.initializeApp({
	credential: admin.credential.cert(require('../serviceAccountKey.json')),
});

// Load menu_items
let menuItems = require('./new_data/menu_items.json');

// Delete matching menu_items
async function deleteMenuItems() {
	for (const item of menuItems) {
		const ref = db.collection('menu_items').doc(item.id);
		const doc = await ref.get();

		if (doc.exists) {
			await ref.delete();
			console.log(`🗑️ Deleted menu_item with ID: ${item.id}`);
		} else {
			console.log(`⚠️ No document found for ID: ${item.id}`);
		}
	}

	console.log('✅ Deletion complete.');
}
