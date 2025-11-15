import 'package:flutter/material.dart';
import 'package:nomnom_safe/models/allergen.dart';
import '../widgets/multi_select_checkbox_list.dart';

class EditProfileView extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final VoidCallback onSave;
  final VoidCallback onChangePassword;
  final bool isLoading;
  final List<Allergen> allAllergens;
  final List<String> allAllergenLabels;
  final Set<String> selectedAllergenIds;
  final void Function(String id, bool checked) onAllergenChanged;

  const EditProfileView({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.onSave,
    required this.onChangePassword,
    required this.isLoading,
    required this.allAllergens,
    required this.allAllergenLabels,
    required this.selectedAllergenIds,
    required this.onAllergenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(labelText: 'First Name'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(labelText: 'Last Name'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Allergens',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        MultiSelectCheckboxList(
          options: allAllergenLabels,
          selected: selectedAllergenIds,
          onChanged: onAllergenChanged,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isLoading ? null : onSave,
          child: const Text('Save Changes'),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onChangePassword,
          child: const Text('Change Password'),
        ),
      ],
    );
  }
}
