/**
 * Upload menu_items to Firestore db
 * Use: node firestore_uploader/upload_menu_items.js
 */

const admin = require('firebase-admin');
const fs = require('fs');

admin.initializeApp({
	credential: admin.credential.cert(require('../serviceAccountKey.json')),
});

const db = admin.firestore();

// Load menu_items
let menuItems = require('./new_data/menu_items.json');

// Utility to generate a new ID with prefix
function generateId(prefix) {
	const chars =
		'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	let randomPart = '';
	for (let i = 0; i < 12; i++) {
		randomPart += chars.charAt(Math.floor(Math.random() * chars.length));
	}
	return `${prefix}_${randomPart}`;
}

// Check if a document exists
async function idExists(collection, id) {
	const doc = await db.collection(collection).doc(id).get();
	return doc.exists;
}

// Ensure unique menu_item IDs
async function ensureUniqueMenuItemIds() {
	const idMap = {};

	for (const item of menuItems) {
		while (await idExists('menu_items', item.id)) {
			const oldId = item.id;
			const newId = generateId('item');
			console.log(
				`⚠️ ID conflict in menu_items: replacing ${oldId} with ${newId}`
			);
			idMap[oldId] = newId;
			item.id = newId;
		}
	}
}

// Upload menu_items
async function uploadMenuItems() {
	await ensureUniqueMenuItemIds();

	for (const item of menuItems) {
		await db.collection('menu_items').doc(item.id).set(item);
	}

	console.log('✅ Menu items upload complete.');
}

uploadMenuItems().catch(console.error);
