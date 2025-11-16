import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/allergen.dart';
import '../widgets/restaurant_card.dart';
import '../services/allergen_service.dart';
import '../services/restaurant_service.dart';
import '../utils/allergen_utils.dart';
import '../widgets/filter_modal.dart';
import '../utils/restaurant_utils.dart';
import '../services/auth_service.dart';
import '../navigation/route_tracker.dart';

/* Main screen displaying allergen filters and a list of restaurants */
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void initState() {
    super.initState();

    // Load allergens when the widget is first built
    _fetchAllergens(); // triggers the async fetch
    _fetchUnfilteredRestaurants();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // User returned from EditProfileScreen
    _fetchAllergens(); // refresh selection
  }

  /* Fetch allergen labels and update the state if the widget is still mounted */
  void _fetchAllergens() async {
    final allergens = await _allergenService.getAllergens();
    if (mounted) {
      setState(() {
        availableAllergens = allergens;
      });
      _applyUserAllergensIfLoggedIn(); // apply user's allergens
    }
  }

  void _applyUserAllergensIfLoggedIn() {
    final user = AuthService().currentUser;
    if (user == null) {
      return;
    }

    final userAllergenIds = user.allergies;

    final matchedAllergens = availableAllergens
        .where((a) => userAllergenIds.contains(a.id))
        .toList();

    if (matchedAllergens.isNotEmpty) {
      setState(() {
        selectedAllergens = matchedAllergens;
      });
      _applyAllergenFilter();
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

  /* Apply the allergen filter to the restaurant list */
  Future<void> _applyAllergenFilter() async {
    if (selectedAllergens.isEmpty) {
      setState(() {
        restaurantList = unfilteredRestaurants;
        _extractAvailableCuisines();
      });
      return;
    }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Allergen Filter
              Expanded(
                child: availableAllergens.isEmpty
                    ? // Show a loading spinner if allergens haven’t loaded yet
                      Center(child: CircularProgressIndicator())
                    : // Show the allergen filter widget once allergens are loaded
                      FilterModal(
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
                          });
                          _applyAllergenFilter();
                        },
                      ),
              ),
              const SizedBox(width: 12), // spacing between filters
              // Cuisine Filter
              if (!(selectedAllergens.isNotEmpty && restaurantList.isEmpty) &&
                  availableCuisines.isNotEmpty)
                Expanded(
                  child: FilterModal(
                    buttonLabel: 'Cuisines',
                    title: 'Filter by Cuisine',
                    options: availableCuisines,
                    selectedOptions: selectedCuisines,
                    onChanged: _filterRestaurantsByCuisine,
                  ),
                ),
            ],
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
    );
  }
}
