import 'package:flutter/material.dart';
import '../widgets/nomnom_safe_appbar.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../widgets/allergen_filter.dart';
import '../widgets/filter.dart';
import '../models/allergen.dart';
import '../services/allergen_service.dart';
import '../services/menu_service.dart';
import '../models/menu.dart';

class MenuScreen extends StatefulWidget {
  final Restaurant restaurant;

  const MenuScreen({super.key, required this.restaurant});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final AllergenService _allergenService = AllergenService();
  final MenuService _menuService = MenuService();

  List<Allergen> availableAllergens = [];
  List<Allergen> selectedAllergens = [];
  List<MenuItem> filteredMenuItems = [];
  List<MenuItem> allMenuItems = [];
  // Item type filter state
  static const List<String> availableItemTypes = [
    'Sides',
    'Entrees',
    'Desserts',
    'Drinks',
    'Appetizers',
  ];
  List<String> selectedItemTypes = [];
  Menu? restaurantMenu;

  bool isLoadingAllergens = true;
  bool isLoadingMenu = true;

  @override
  void initState() {
    super.initState();
    _fetchAllergens();
    _fetchMenuItems();
  }

  /* Fetch menu and menu items for the restaurant */
  Future<void> _fetchMenuItems() async {
    setState(() {
      isLoadingMenu = true;
    });

    try {
      // First get the menu for this restaurant
      restaurantMenu = await _menuService.getMenuByRestaurantId(
        widget.restaurant.id,
      );

      if (restaurantMenu != null) {
        // Then get all menu items for that menu
        allMenuItems = await _menuService.getMenuItems(restaurantMenu!.id);
        _updateFilteredMenuItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading menu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingMenu = false;
        });
      }
    }
  }

  void _fetchAllergens() async {
    final allergens = await _allergenService.getAllergens();
    if (mounted) {
      setState(() {
        availableAllergens = allergens;
        isLoadingAllergens = false;
      });
      // Recompute filtered items now that we have allergen labels available
      _updateFilteredMenuItems();
    }
  }

  void _updateFilteredMenuItems() {
    final selectedAllergenIds = selectedAllergens.map((a) => a.id).toList();

    setState(() {
      // Start from all items
      var results = List<MenuItem>.from(allMenuItems);

      // Apply allergen filtering (exclude items containing any selected allergen)
      if (selectedAllergenIds.isNotEmpty) {
        results = results.where((item) {
          return !item.allergens.any(
            (allergen) => selectedAllergenIds.contains(allergen),
          );
        }).toList();
      }

      // Apply item type filtering (include only items whose itemType is selected)
      if (selectedItemTypes.isNotEmpty) {
        results = results.where((item) {
          // Convert plural capitalized display names to singular lowercase for comparison
          return selectedItemTypes
              .map((type) => type.toLowerCase().replaceAll(RegExp('s\$'), ''))
              .contains(item.itemType.toLowerCase());
        }).toList();
      }

      filteredMenuItems = results;
    });
  }

  void _toggleAllergen(Allergen allergen) {
    setState(() {
      if (selectedAllergens.contains(allergen)) {
        selectedAllergens.remove(allergen);
      } else {
        selectedAllergens.add(allergen);
      }
      _updateFilteredMenuItems();
    });
  }

  void _clearAllergens() {
    setState(() {
      selectedAllergens.clear();
      _updateFilteredMenuItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NomnomSafeAppBar(),
      body: Column(
        children: [
          // Restaurant name and navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back to Home',
                ),
                Expanded(
                  child: Text(
                    widget.restaurant.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.restaurant),
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/restaurant',
                      arguments: widget.restaurant,
                    );
                  },
                  tooltip: 'Restaurant Details',
                ),
              ],
            ),
          ),
          // Allergen filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: isLoadingAllergens
                ? const Center(child: CircularProgressIndicator())
                : AllergenFilter(
                    availableAllergens: availableAllergens,
                    selectedAllergens: selectedAllergens,
                    onToggle: _toggleAllergen,
                    onClear: _clearAllergens,
                    showClearButton: selectedAllergens.isNotEmpty,
                  ),
          ),
          // Item type filter (uses reusable Filter widget)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Filter(
              label: 'Item types',
              options: availableItemTypes,
              selectedOptions: selectedItemTypes,
              onChanged: (selected) {
                setState(() {
                  // Keep original capitalization for display
                  selectedItemTypes = selected.toList();
                  _updateFilteredMenuItems();
                });
              },
            ),
          ),
          // Filter description text
          if (selectedAllergens.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Showing menu items that do not contain your selected allergens:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          // Menu items list
          Expanded(
            child: isLoadingAllergens
                ? const Center(child: CircularProgressIndicator())
                : isLoadingMenu
                ? const Center(child: CircularProgressIndicator())
                : filteredMenuItems.isEmpty
                ? const Center(
                    child: Text('No menu items match your allergen filters'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    itemCount: filteredMenuItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredMenuItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(item.description),
                                ),
                              if (item.allergens.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Contains: ${item.allergens.map((id) => availableAllergens.firstWhere(
                                      (a) => a.id == id,
                                      orElse: () => Allergen(id: id, label: id),
                                    ).label).join(", ").toLowerCase()}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
