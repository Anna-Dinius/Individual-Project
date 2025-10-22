import 'package:flutter/material.dart';
import '../widgets/nomnom_safe_appbar.dart';
import '../models/restaurant.dart';
import '../models/allergen.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/allergen_filter.dart';
import '../services/allergen_service.dart';
import '../services/restaurant_service.dart';
import '../utils/allergen_utils.dart';
import '../widgets/filter.dart';
import '../utils/restaurant_utils.dart';

/* Main screen displaying allergen filters and a list of restaurants */
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Service classes
  final AllergenService _allergenService = AllergenService();
  final RestaurantService _restaurantService = RestaurantService();

  // State variables
  bool isLoadingRestaurants = true; // controls loading spinner visibility
  List<Allergen> availableAllergens = []; // allergen options from Firestore
  List<Allergen> selectedAllergens = []; // currently selected allergens
  List<Restaurant> unfilteredRestaurants = []; // all restaurants from Firestore
  List<Restaurant> restaurantList = []; // restaurants to be displayed
  List<String> selectedCuisines = [];
  List<String> availableCuisines = [];

  @override
  void initState() {
    super.initState();

    // Load allergens when the widget is first built
    _fetchAllergens(); // triggers the async fetch
    _fetchUnfilteredRestaurants();
  }

  /* Fetch allergen labels and update the state if the widget is still mounted */
  void _fetchAllergens() async {
    final allergens = await _allergenService.getAllergens();
    if (mounted) {
      setState(() {
        availableAllergens = allergens;
      });
    }
  }

  /* Fetch all restaurants without any filters */
  void _fetchUnfilteredRestaurants() async {
    setState(() {
      isLoadingRestaurants = true;
    });

    final allRestaurants = await _restaurantService.getAllRestaurants();
    if (mounted) {
      setState(() {
        unfilteredRestaurants = allRestaurants;
        restaurantList = allRestaurants;
        _extractAvailableCuisines();
        isLoadingRestaurants = false;
      });
    }
  }

  void _extractAvailableCuisines() {
    setState(() {
      availableCuisines = extractAvailableCuisines(restaurantList);
    });
  }

  void _filterRestaurantsByCuisine(List<String> cuisines) {
    setState(() {
      selectedCuisines = cuisines;
      restaurantList = filterRestaurantsByCuisine(
        unfilteredRestaurants,
        cuisines,
      );
    });
  }

  /* Toggle selection of an allergen and apply the filter */
  void _toggleAllergen(Allergen allergen) async {
    setState(() {
      selectedAllergens = selectedAllergens.contains(allergen)
          ? selectedAllergens
                .where((selectedAllergen) => selectedAllergen != allergen)
                .toList()
          : [...selectedAllergens, allergen];
    });
    await _applyAllergenFilter();
  }

  /* Clear all selected allergens and reset the restaurant list */
  void _clearAllergens() async {
    setState(() {
      selectedAllergens.clear();
    });
    restaurantList = unfilteredRestaurants;
  }

  /* Apply the allergen filter to the restaurant list */
  Future<void> _applyAllergenFilter() async {
    setState(() {
      isLoadingRestaurants = true;
    });

    final selectedAllergenIds = selectedAllergens.map((a) => a.id).toList();
    final filteredRestaurants = await _restaurantService
        .filterRestaurantsFromList(unfilteredRestaurants, selectedAllergenIds);

    if (mounted) {
      setState(() {
        restaurantList = filteredRestaurants;
        _extractAvailableCuisines();
        isLoadingRestaurants = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NomnomSafeAppBar(),
      // Start a vertical layout for the screen content
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: availableAllergens.isEmpty
                ? // Show a loading spinner if allergens haven’t loaded yet
                  Center(child: CircularProgressIndicator())
                : // Show the allergen filter widget once allergens are loaded
                  AllergenFilter(
                    availableAllergens: availableAllergens,
                    selectedAllergens: selectedAllergens,
                    onToggle: _toggleAllergen,
                    onClear: _clearAllergens,
                    showClearButton: selectedAllergens.isNotEmpty,
                  ),
          ),
          if (!(selectedAllergens.isNotEmpty && restaurantList.isEmpty) &&
              availableCuisines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Filter(
                label: 'Filter by Cuisine',
                options: availableCuisines,
                selectedOptions: selectedCuisines,
                onChanged: _filterRestaurantsByCuisine,
              ),
            ),
          if (selectedAllergens.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Text(
                "The following restaurants offer at least one menu item that doesn't contain ${formatAllergenList(extractAllergenLabels(selectedAllergens), "or")}:",
              ),
            ),
          // Make the restaurant list take up remaining space
          Expanded(
            child: isLoadingRestaurants
                ? // Show a loading spinner while restaurants are loading
                  const Center(child: CircularProgressIndicator())
                : restaurantList.isEmpty
                ? // No restaurants match the filters
                  const Center(child: Text('No restaurants match your filters'))
                : // Restaurant list
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: restaurantList.length,
                    itemBuilder: (context, index) {
                      return RestaurantCard(restaurant: restaurantList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
