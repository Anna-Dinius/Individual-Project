/**
 * Rename "item-type" to "item_type" in all menu_items documents
 * Use: node firestore_uploader/rename_item_type_field.js
 */

const admin = require('firebase-admin');

admin.initializeApp({
	credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();

async function renameItemTypeField() {
	const snapshot = await db.collection('menu_items').get();

	if (snapshot.empty) {
		console.log('⚠️ No documents found in menu_items.');
		return;
	}

	let updatedCount = 0;

	for (const doc of snapshot.docs) {
		const data = doc.data();

		if ('item-type' in data) {
			const value = data['item-type'];

			// Update with new field and delete old one
			await doc.ref.update({
				item_type: value,
				'item-type': admin.firestore.FieldValue.delete(),
			});

			updatedCount++;
		}
	}

	console.log(
		`✅ Renamed "item-type" to "item_type" in ${updatedCount} documents.`
	);
}

renameItemTypeField().catch(console.error);
