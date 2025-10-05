/**
 * Upload data from json documents to Firestore db
 * Use: node firestore_uploader/firestore_uploader.js
 * */

const admin = require('firebase-admin');

admin.initializeApp({
	credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();

// Restaurant data
const restaurant_data = require('./new_data/restaurants.json');

restaurant_data.forEach((restaurant) => {
	db.collection('restaurants').doc(restaurant.id).set(restaurant);
});

// Address Data
const address_data = require('./new_data/addresses.json');

address_data.forEach((address) => {
	db.collection('addresses').doc(address.id).set(address);
});

// Menu data
const menu_data = require('./new_data/menus.json');

menu_data.forEach((menu) => {
	db.collection('menus').doc(menu.id).set(menu);
});

// Menu Item data
const menu_items_data = require('./new_data/menu_items.json');

menu_items_data.forEach((item) => {
	db.collection('menu_items').doc(item.id).set(item);
});
