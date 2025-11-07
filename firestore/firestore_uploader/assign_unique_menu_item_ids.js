const fs = require('fs');
const path = require('path');

// Load menu_items
const filePath = path.join(__dirname, 'new_data', 'menu_items.json');
let menuItems = require(filePath);

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

// Assign unique IDs
function assignUniqueIds(items) {
	const seen = new Set();

	for (const item of items) {
		let newId;
		do {
			newId = generateId('item');
		} while (seen.has(newId));

		item.id = newId;
		seen.add(newId);
	}
}

// Run and save
assignUniqueIds(menuItems);

fs.writeFileSync(filePath, JSON.stringify(menuItems, null, 2));
console.log('✅ Unique IDs assigned and saved to menu_items.json');
