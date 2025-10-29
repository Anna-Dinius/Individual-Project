import 'menu_item.dart';

class Menu {
  final String id;
  final String restaurantId;
  final List<MenuItem> items;

  Menu({required this.id, required this.restaurantId, required this.items});

  /* Create a Menu object from JSON data */
  factory Menu.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] ?? [];
    return Menu(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      items: itemsJson.map((item) => MenuItem.fromJson(item)).toList(),
    );
  }

  /* Convert a Menu object to JSON data */
  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurant_id': restaurantId,
    'items': items.map((item) => item.toJson()).toList(),
  };
}
