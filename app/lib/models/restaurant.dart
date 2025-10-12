class Restaurant {
  final String id;
  final String name;
  final String addressId;
  final String website;
  final List<String> hours;
  final String phone;
  final String cuisine;
  final List<String> disclaimers;
  final String? logoUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.addressId,
    required this.website,
    required this.hours,
    required this.phone,
    required this.cuisine,
    required this.disclaimers,
    required this.logoUrl,
  });

  /* Create a Restaurant object from JSON data */
  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'],
    name: json['name'],
    addressId: json['address_id'],
    website: json['website'] ?? '',
    hours: List<String>.from(json['hours']),
    phone: json['phone'],
    cuisine: json['cuisine'],
    disclaimers: List<String>.from(json['disclaimers']),
    logoUrl: json['logoUrl'] ?? 'None',
  );

  /* Convert a Restaurant object to JSON data */
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': addressId,
    'website': website,
    'hours': hours,
    'phone': phone,
    'cuisine': cuisine,
    'disclaimers': disclaimers,
    'logoUrl': logoUrl,
  };

  /* Check if the restaurant has a website */
  bool get hasWebsite => website.trim().isNotEmpty;

  /* Get today's operating hours based on the current weekday */
  String get todayHours {
    final weekday = DateTime.now().weekday;
    return hours[weekday - 1]; // Dart: 1 = Monday, 7 = Sunday
  }
}
