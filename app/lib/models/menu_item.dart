class MenuItem {
  final String id;
  final String name;
  final String description;
  final List<String> allergens;
  final String menuId;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.allergens,
    required this.menuId,
  });

  /* Create a MenuItem object from JSON data */
  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    allergens: List<String>.from(json['allergens']),
    menuId: json['menu_id'],
  );

  /* Convert a MenuItem object to JSON data */
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'allergens': allergens,
    'menu_id': menuId,
  };
}
