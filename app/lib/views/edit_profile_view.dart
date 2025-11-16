import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/text_form_field_with_controller.dart';
import '../widgets/multi_select_checkbox_list.dart';

class EditProfileView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final VoidCallback onSave;
  final VoidCallback onChangePassword;
  final bool isLoading;
  final List<String> allAllergenLabels;
  final Set<String> selectedAllergenLabels;
  final void Function(String id, bool checked) onAllergenChanged;

  const EditProfileView({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.onSave,
    required this.onChangePassword,
    required this.isLoading,
    required this.allAllergenLabels,
    required this.selectedAllergenLabels,
    required this.onAllergenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextFormFieldWithController(
            controller: firstNameController,
            label: 'First Name',
            isRequired: false,
          ),
          const SizedBox(height: 16),
          TextFormFieldWithController(
            controller: lastNameController,
            label: 'Last Name',
            isRequired: false,
          ),
          const SizedBox(height: 16),
          TextFormFieldWithController(
            controller: emailController,
            label: 'Email',
            isRequired: false,
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
            selected: selectedAllergenLabels,
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
      ),
    );
  }
}
