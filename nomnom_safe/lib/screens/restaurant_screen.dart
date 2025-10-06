import 'package:flutter/material.dart';
import '../models/entities/restaurant.dart';
import '../models/entities/address.dart';
import '../services/address_service.dart';
import '../widgets/restaurant_link.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantScreen({super.key, required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  Address? address;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  void _loadAddress() async {
    final result = await AddressService().getRestaurantAddress(
      widget.restaurant,
    );
    if (mounted) {
      setState(() {
        address = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NomNom Safe")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.restaurant.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Cuisine: ${widget.restaurant.cuisine}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Hours Today: ${widget.restaurant.todayHours}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'All Hours:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...widget.restaurant.hours.map(
              (line) =>
                  Text(line, style: Theme.of(context).textTheme.bodySmall),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Address: ${address?.full ?? 'Loading...'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Phone: ${widget.restaurant.phone}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            RestaurantLink(url: widget.restaurant.website),
            if (widget.restaurant.disclaimers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Disclaimers:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...widget.restaurant.disclaimers.map(
                (disclaimer) => Text(
                  '- $disclaimer',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
