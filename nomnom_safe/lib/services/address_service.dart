import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entities/address.dart';
import '../models/entities/restaurant.dart';

class AddressService {
  final FirebaseFirestore _firestore;

  AddressService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Address?> getRestaurantAddress(Restaurant restaurant) async {
    final addressId = restaurant.addressId;
    if (addressId.isEmpty) return null;

    final doc = await _firestore.collection('addresses').doc(addressId).get();

    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return Address.fromJson(data);
  }
}
