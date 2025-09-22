import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entities/restaurant.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/allergen_filter.dart';
import '../services/allergen_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AllergenService _allergenService = AllergenService();

  List<String> selectedAllergens = [];
  List<String> availableAllergens = [];

  @override
  void initState() {
    super.initState();
    _loadAllergens(); // triggers the async fetch
  }

  void _loadAllergens() async {
    final labels = await _allergenService.getAllergenLabels();
    if (mounted) {
      setState(() {
        availableAllergens = labels;
      });
    }
  }

  void _onAllergenSelectionChanged(List<String> allergens) {
    setState(() {
      selectedAllergens = allergens;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NomNom Safe')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          availableAllergens.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: AllergenFilter(
                    allergens: availableAllergens,
                    onSelectionChanged: _onAllergenSelectionChanged,
                  ),
                ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restaurants')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final restaurants = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Restaurant.fromJson(data);
                }).toList();

                // Optional: filter restaurants based on selected allergens here

                return ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    return RestaurantCard(restaurant: restaurants[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
