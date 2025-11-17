import 'package:flutter/material.dart';
import 'package:nomnom_safe/models/allergen.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/widgets/multi_select_checkbox_list.dart';

class SignUpAllergenView extends StatefulWidget {
  final bool isLoading;
  final List<String> selectedAllergenIds;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const SignUpAllergenView({
    super.key,
    required this.isLoading,
    required this.selectedAllergenIds,
    required this.onChanged,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<SignUpAllergenView> createState() => _SignUpAllergenViewState();
}

class _SignUpAllergenViewState extends State<SignUpAllergenView> {
  List<Allergen> availableAllergens = [];

  @override
  void initState() {
    super.initState();
    _loadAllergens();
  }

  Future<void> _loadAllergens() async {
    final allergens = await AllergenService().getAllergens();
    if (mounted) {
      setState(() => availableAllergens = allergens);
    }
  }

  @override
  Widget build(BuildContext context) {
    return availableAllergens.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              MultiSelectCheckboxList(
                options: availableAllergens.map((a) => a.label).toList(),
                selected: availableAllergens
                    .where((a) => widget.selectedAllergenIds.contains(a.id))
                    .map((a) => a.label)
                    .toSet(),
                onChanged: (label, checked) {
                  final matchingAllergen = availableAllergens.firstWhere(
                    (a) => a.label == label,
                  );
                  final updated = [...widget.selectedAllergenIds];
                  checked
                      ? updated.add(matchingAllergen.id)
                      : updated.remove(matchingAllergen.id);
                  widget.onChanged(updated);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onSubmit,
                child: widget.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Text('Create Account'),
              ),
              TextButton(onPressed: widget.onBack, child: const Text('Back')),
            ],
          );
  }
}
