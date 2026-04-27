import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/profile_provider.dart';
import '../providers/water_provider.dart';
import 'main_navigation_screen.dart';

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
  bool isLoading = false;
  File? selectedImage;

  /// IMAGE PICKER
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();

      final newPath =
          '${directory.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final savedImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        selectedImage = savedImage;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    super.dispose();
  }

  /// SAVE PROFILE
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final name = nameController.text.trim();
      final age = int.parse(ageController.text);
      final weight = int.parse(weightController.text);

      // Save profile via Provider (Firestore handled inside provider)

      await context.read<ProfileProvider>().saveProfile(
            name: name,
            age: age,
            weight: weight,
            activity: selectedActivity,
            photoPath: selectedImage?.path,
          );

      //  Calculate water goal
      context.read<WaterProvider>().calculateDailyGoal(
            weight: weight,
            age: age,
            activity: selectedActivity,
          );
      //  Reset water data
      await context.read<WaterProvider>().resetDailyWater(context);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      /// TITLE
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
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// PROFILE IMAGE
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: ClipOval(
                                  child: selectedImage != null
                                      ? Image.file(selectedImage!,
                                          fit: BoxFit.cover)
                                      : const Icon(Icons.person, size: 40),
                                ),
                              ),

                              /// CAMERA ICON
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      /// NAME
                      TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration('Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                            return 'Only letters allowed';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// AGE
                      TextFormField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Age'),
                        validator: (value) {
                          final age = int.tryParse(value ?? '');
                          if (age == null || age < 8 || age > 99) {
                            return 'Enter valid age';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// WEIGHT
                      TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Weight (kg)'),
                        validator: (value) {
                          final weight = int.tryParse(value ?? '');
                          if (weight == null || weight < 20 || weight > 200) {
                            return 'Enter valid weight';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      /// ACTIVITY
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
                        decoration: _inputDecoration(null),
                        dropdownColor: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        items: const [
                          DropdownMenuItem(value: 'Low', child: Text('Low')),
                          DropdownMenuItem(
                              value: 'Moderate', child: Text('Moderate')),
                          DropdownMenuItem(value: 'High', child: Text('High')),
                        ],
                        onChanged: (value) {
                          setState(() => selectedActivity = value!);
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            /// BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 6,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INPUT STYLE
  InputDecoration _inputDecoration(String? label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
