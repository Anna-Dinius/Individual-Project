import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entities/restaurant.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/allergen_filter.dart';
import '../services/allergen_service.dart';
import '../services/restaurant_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instantiate service classes
  final AllergenService _allergenService = AllergenService();
  final RestaurantService _restaurantService = RestaurantService();

  // Initialize state variables for allergen selection and available allergen options
  List<String> selectedAllergens = [];
  List<String> selectedAllergenIds = [];
  List<String> availableAllergens = [];
  Map<String, String> labelToIdMap = {};
  List<Restaurant> filteredRestaurants = [];

  @override
  void initState() {
    super.initState();

    // Load allergens when the widget is first built
    _loadAllergens(); // triggers the async fetch
  }

  void _loadAllergens() async {
    // Fetch allergen labels and update the state if the widget is still mounted
    labelToIdMap = await _allergenService.getAllergenLabelToIdMap();
    final labels = labelToIdMap.keys.toList();
    if (mounted) {
      setState(() {
        availableAllergens = labels;
      });
    }
    await _filterRestaurants();
  }

  void _toggleAllergen(String allergen) async {
    setState(() {
      if (selectedAllergens.contains(allergen)) {
        selectedAllergens.remove(allergen);
      } else {
        selectedAllergens.add(allergen);
      }
      selectedAllergenIds = selectedAllergens
          .map((label) => labelToIdMap[label])
          .whereType<String>()
          .toList();
    });
    await _filterRestaurants();
  }

  void _clearAllergens() async {
    setState(() {
      selectedAllergens.clear();
      selectedAllergenIds.clear();
    });
    await _filterRestaurants();
  }

  Future<void> _filterRestaurants() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .get();
    final allRestaurants = snapshot.docs.map((doc) {
      final data = doc.data();
      return Restaurant.fromJson(data);
    }).toList();

    final filtered = await _restaurantService.getFilteredRestaurants(
      selectedAllergenIds,
      allRestaurants,
    );

    if (mounted) {
      setState(() {
        filteredRestaurants = filtered;
      });
    }
  }

  /* Build the main UI scaffold with an app bar */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NomNom Safe')),
      // Start a vertical layout for the screen content
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          availableAllergens.isEmpty
              ? const Padding(
                  // Show a loading spinner if allergens haven’t loaded yet
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  // Show the allergen filter widget once allergens are loaded
                  padding: const EdgeInsets.all(12),
                  child: AllergenFilter(
                    allergens: availableAllergens,
                    selectedAllergens: selectedAllergens,
                    onToggle: _toggleAllergen,
                    onClear: _clearAllergens,
                    showClearButton: selectedAllergens.isNotEmpty,
                  ),
                ),
          Expanded(
            child: filteredRestaurants.isEmpty
                ? const Center(child: Text('No restaurants match your filters'))
                : ListView.builder(
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      return RestaurantCard(
                        restaurant: filteredRestaurants[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
