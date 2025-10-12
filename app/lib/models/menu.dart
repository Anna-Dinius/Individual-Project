class Menu {
  final String id;
  final String restaurantId;

  Menu({required this.id, required this.restaurantId});

  /* Create a Menu object from JSON data */
  factory Menu.fromJson(Map<String, dynamic> json) =>
      Menu(id: json['id'], restaurantId: json['restaurant_id']);

  /* Convert a Menu object to JSON data */
  Map<String, dynamic> toJson() => {'id': id, 'restaurant_id': restaurantId};
}
