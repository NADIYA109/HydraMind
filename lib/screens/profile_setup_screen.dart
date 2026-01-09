import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String selectedActivity = 'Moderate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Profile Setup'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        'Tell us about yourself',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'This helps us calculate your daily water goal',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// Name
                      TextFormField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration('Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                            return 'Only letters allowed';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// Age
                      TextFormField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration('Age'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Age is required';
                          }
                          if (!RegExp(r'^\d{1,2}$').hasMatch(value)) {
                            return 'Enter valid age';
                          }
                          final age = int.parse(value);
                          if (age < 1 || age > 150) {
                            return 'Enter valid age';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// Weight
                      TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: _inputDecoration('Weight (kg)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Weight is required';
                          }
                          final weight = int.tryParse(value);
                          if (weight == null) {
                            return 'Enter valid number';
                          }
                          if (weight < 1 || weight > 200) {
                            return 'Enter valid weight';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      /// Activity Level
                      const Text(
                        'Activity Level',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: selectedActivity,
                        isDense: true,
                        decoration: _inputDecoration(null).copyWith(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          )
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Low', child: Text('Low')),
                          DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                          DropdownMenuItem(value: 'High', child: Text('High')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedActivity = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            ///bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ////
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16 , color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textSecondary),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Colors.black54, 
        width: 1,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: AppColors.primary, 
        width: 2,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.2,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 2,
      ),
    ),
  );
}

}
