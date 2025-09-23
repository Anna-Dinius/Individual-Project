class MenuItem {
  final String id;
  final String name;
  final String description;
  final List<String> allergens;
  final String menu_id;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.allergens,
    required this.menu_id,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    allergens: List<String>.from(json['hours']),
    menu_id: json['menu_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'allergens': allergens,
    'menu_id': menu_id,
  };

  // TODO: remove if not necessary or add id & menu_id
  String get full => '$name, $description $allergens';
}
