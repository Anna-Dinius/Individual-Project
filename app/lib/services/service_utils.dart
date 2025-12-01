import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';

AllergenService getAllergenService(BuildContext context) =>
    Provider.of<AllergenService>(context, listen: false);

T getService<T>(BuildContext context) => Provider.of<T>(context, listen: false);
