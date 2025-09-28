class Menu {
  final String id;
  final String restaurantId;

  Menu({required this.id, required this.restaurantId});

  factory Menu.fromJson(Map<String, dynamic> json) =>
      Menu(id: json['id'], restaurantId: json['restaurant_id']);

  Map<String, dynamic> toJson() => {'id': id, 'restaurant_id': restaurantId};

  // TODO: remove
  String get full => '$restaurantId';
}
