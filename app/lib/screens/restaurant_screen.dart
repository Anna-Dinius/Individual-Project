import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/address_service.dart';
import '../widgets/restaurant_link.dart';

/* Screen displaying detailed information about a specific restaurant */
class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantScreen({super.key, required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  String? address;
  final AddressService _addressService = AddressService();

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  /* Load the restaurant's address from Firestore */
  void _loadAddress() async {
    final result = await _addressService.getRestaurantAddress(
      widget.restaurant.addressId,
    );
    if (mounted) {
      setState(() {
        address = result;
      });
    }
  }

  /* Build the disclaimers section */
  Widget _buildDisclaimers(BuildContext context) {
    final disclaimers = widget.restaurant.disclaimers;
    if (disclaimers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disclaimers:', style: Theme.of(context).textTheme.titleMedium),
          ...disclaimers.map(
            (disclaimer) => Text(
              '- $disclaimer',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(height: 12),
          // Restaurant name
          Text(
            widget.restaurant.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          // Cuisine type
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Cuisine: ${widget.restaurant.cuisine}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          // Today's operating hours
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Hours Today: ${widget.restaurant.todayHours}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // All operating hours
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'All Hours:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...widget.restaurant.hours.map(
            (line) => Text(line, style: Theme.of(context).textTheme.bodySmall),
          ),
          // Address
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Address: ${address ?? 'Loading...'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // Phone number
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Phone: ${widget.restaurant.phone}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // Website link
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('Website: '),
              widget.restaurant.hasWebsite
                  ? RestaurantLink(url: widget.restaurant.website)
                  : const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('none'),
                    ),
            ],
          ),
          // Disclaimer(s)
          if (widget.restaurant.disclaimers.isNotEmpty)
            _buildDisclaimers(context),
        ],
      ),
    );
  }
}
