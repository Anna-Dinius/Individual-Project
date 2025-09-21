import 'address.dart';

class Restaurant {
  final String id;
  final String name;
  final Address address;
  final String website;
  final List<String> hours;
  final String phone;
  final String cuisine;
  final List<String> disclaimers;
  final String logoUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.website,
    required this.hours,
    required this.phone,
    required this.cuisine,
    required this.disclaimers,
    required this.logoUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'],
    name: json['name'],
    address: Address.fromJson(json['address']),
    website: json['website'],
    hours: List<String>.from(json['hours']),
    phone: json['phone'],
    cuisine: json['cuisine'],
    disclaimers: List<String>.from(json['disclaimers']),
    logoUrl: json['logoUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address.toJson(),
    'website': website,
    'hours': hours,
    'phone': phone,
    'cuisine': cuisine,
    'disclaimers': disclaimers,
    'logoUrl': logoUrl,
  };
}
