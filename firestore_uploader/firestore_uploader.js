/** Upload data from json documents to Firestore db */

const admin = require('firebase-admin');

admin.initializeApp({
	credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();

// Restaurant data
const restaurant_data = require('./data/restaurants.json');

restaurant_data.forEach((restaurant) => {
	db.collection('restaurants').doc(restaurant.id).set(restaurant);
});

// Address Data
const address_data = require('./data/addresses.json');

address_data.forEach((address) => {
	db.collection('addresses').doc(address.id).set(address);
});

// Menu data
const menu_data = require('./data/menus.json');

menu_data.forEach((menu) => {
	db.collection('menus').doc(menu.id).set(menu);
});

// Menu Item data
const menu_items_data = require('./data/menu_items.json');

menu_items_data.forEach((item) => {
	db.collection('menu_items').doc(item.id).set(item);
});
