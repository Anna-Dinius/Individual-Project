import 'package:flutter/material.dart';
import '../models/entities/restaurant.dart';
import '../models/entities/address.dart';
import '../services/address_service.dart';

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
      appBar: AppBar(title: Text(widget.restaurant.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.restaurant.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuisine: ${widget.restaurant.cuisine}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Hours Today: ${widget.restaurant.todayHours}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('All Hours:', style: Theme.of(context).textTheme.titleMedium),
            ...widget.restaurant.hours.map(
              (line) =>
                  Text(line, style: Theme.of(context).textTheme.bodySmall),
            ),
            const SizedBox(height: 16),
            Text(
              'Address: ${address?.full ?? 'Loading...'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${widget.restaurant.phone}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Website: ${widget.restaurant.website}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.blue),
            ),
            const SizedBox(height: 16),
            if (widget.restaurant.disclaimers.isNotEmpty) ...[
              Text(
                'Disclaimers:',
                style: Theme.of(context).textTheme.titleMedium,
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
