import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../screens/restaurant_screen.dart';

/* A card widget that displays basic information about a restaurant.
   Used on the main restaurant list screen. */
class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        // Animated scaling effect on hover
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scaleByDouble(
              _isHovered ? 1.02 : 1.0,
              _isHovered ? 1.02 : 1.0,
              1.0,
              1.0,
            ),
          transformAlignment: Alignment.center,
          // Main restaurant card
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(8),
            elevation: _isHovered ? 8 : 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // Clickable area to navigate to restaurant details screen
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantScreen(restaurant: widget.restaurant),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name
                    Text(
                      widget.restaurant.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    // Cuisine type
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Cuisine: ${widget.restaurant.cuisine}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    // Today's operating hours
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Today: ${widget.restaurant.todayHours}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
