class Menu {
  final String id;
  final String restaurant_id;

  Menu({required this.id, required this.restaurant_id});

  factory Menu.fromJson(Map<String, dynamic> json) =>
      Menu(id: json['id'], restaurant_id: json['restaurant_id']);

  Map<String, dynamic> toJson() => {'id': id, 'restaurant_id': restaurant_id};

  String get full => '$restaurant_id';
}
