import 'package:flutter/material.dart';

class Filter extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onChanged;

  const Filter({
    required this.label,
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
    super.key,
  });

  void _showMultiSelectDialog(BuildContext context) async {
    final tempSelections = Set<String>.from(selectedOptions);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.only(
                top: 8,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              titlePadding: const EdgeInsets.only(left: 24, right: 8, top: 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: options.map((option) {
                    final isSelected = tempSelections.contains(option);
                    return CheckboxListTile(
                      title: Text(option),
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            tempSelections.add(option);
                          } else {
                            tempSelections.remove(option);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: tempSelections.isNotEmpty
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                    children: [
                      if (tempSelections.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              tempSelections.clear();
                            });
                          },
                          child: const Text('Clear Selection'),
                        ), // placeholder to maintain spacing
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onChanged(tempSelections.toList());
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Cuisines'),
        onPressed: () => _showMultiSelectDialog(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
