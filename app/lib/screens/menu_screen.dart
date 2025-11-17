import 'package:flutter/material.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/menu_item.dart';
import 'package:nomnom_safe/widgets/filter_modal.dart';
import 'package:nomnom_safe/models/allergen.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/services/menu_service.dart';
import 'package:nomnom_safe/models/menu.dart';
import 'package:nomnom_safe/navigation/route_constants.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    AppRoutes.restaurant,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Allergen Filter
              Expanded(
                child: isLoadingAllergens
                    ? const Center(child: CircularProgressIndicator())
                    : FilterModal(
                        buttonLabel: 'Allergens',
                        title: 'Filter by Allergen',
                        options: availableAllergens
                            .map((a) => a.label)
                            .toList(),
                        selectedOptions: selectedAllergens
                            .map((a) => a.label)
                            .toList(),
                        onChanged: (selectedLabels) {
                          final matched = availableAllergens
                              .where((a) => selectedLabels.contains(a.label))
                              .toList();
                          setState(() {
                            selectedAllergens = matched;
                            _updateFilteredMenuItems();
                          });
                        },
                      ),
              ),
              const SizedBox(width: 12),
              // Item type filter (uses reusable Filter widget)
              Expanded(
                child: FilterModal(
                  buttonLabel: 'Item Types',
                  title: 'Filter by item type',
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
            ],
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
                                    color: Theme.of(context).colorScheme.error,
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
    );
  }
}
