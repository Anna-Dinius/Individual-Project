/**
 * Upload data from json documents to Firestore db
 * Use: node firestore_uploader/firestore_uploader.js
 */

const admin = require('firebase-admin');
const crypto = require('crypto');
const fs = require('fs');

admin.initializeApp({
	credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();

// Load data
let restaurants = require('./new_data/restaurants.json');
let addresses = require('./new_data/addresses.json');
let menus = require('./new_data/menus.json');
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

// Ensure unique IDs and update references
async function ensureUniqueIds() {
	const idMap = {
		addresses: {},
		menus: {},
		restaurants: {},
		menu_items: {},
	};

	// Addresses
	for (const address of addresses) {
		while (await idExists('addresses', address.id)) {
			const oldId = address.id;
			const newId = generateId('add');
			console.log(
				`⚠️ ID conflict detected in addresses: replacing ${oldId} with ${newId}`
			);
			idMap.addresses[oldId] = newId;
			address.id = newId;
		}
	}

	// Menus
	for (const menu of menus) {
		while (await idExists('menus', menu.id)) {
			const oldId = menu.id;
			const newId = generateId('menu');
			console.log(
				`⚠️ ID conflict detected in menus: replacing ${oldId} with ${newId}`
			);
			idMap.menus[oldId] = newId;
			menu.id = newId;
		}
	}

	// Restaurants
	for (const restaurant of restaurants) {
		while (await idExists('restaurants', restaurant.id)) {
			const oldId = restaurant.id;
			const newId = generateId('rstr');
			console.log(
				`⚠️ ID conflict detected in restaurants: replacing ${oldId} with ${newId}`
			);
			idMap.restaurants[oldId] = newId;
			restaurant.id = newId;
		}

		if (idMap.menus[restaurant.menu_id]) {
			restaurant.menu_id = idMap.menus[restaurant.menu_id];
		}
		if (idMap.addresses[restaurant.address_id]) {
			restaurant.address_id = idMap.addresses[restaurant.address_id];
		}
	}

	// Menu Items
	for (const item of menuItems) {
		while (await idExists('menu_items', item.id)) {
			const oldId = item.id;
			const newId = generateId('item');
			console.log(
				`⚠️ ID conflict detected in menu_items: replacing ${oldId} with ${newId}`
			);
			idMap.menu_items[oldId] = newId;
			item.id = newId;
		}

		if (idMap.menus[item.menu_id]) {
			item.menu_id = idMap.menus[item.menu_id];
		}
	}
}

// Upload data
async function uploadData() {
	await ensureUniqueIds();

	for (const address of addresses) {
		await db.collection('addresses').doc(address.id).set(address);
	}

	for (const menu of menus) {
		await db.collection('menus').doc(menu.id).set(menu);
	}

	for (const restaurant of restaurants) {
		await db.collection('restaurants').doc(restaurant.id).set(restaurant);
	}

	for (const item of menuItems) {
		await db.collection('menu_items').doc(item.id).set(item);
	}

	console.log('✅ Upload complete with unique IDs.');
}

uploadData().catch(console.error);
