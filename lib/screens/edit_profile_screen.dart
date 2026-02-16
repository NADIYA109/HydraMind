import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  String? _newPhotoPath;

  String _selectedActivity = "Moderate";
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newPhotoPath = pickedFile.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final profile = context.read<ProfileProvider>();

    _nameController.text = profile.name ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _weightController.text = profile.weight?.toString() ?? '';
    _selectedActivity = profile.activity ?? "Moderate";
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// Profile Image
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.cardColor,
                        backgroundImage: _newPhotoPath != null
                            ? FileImage(File(_newPhotoPath!))
                            : profile.photoPath != null
                                ? FileImage(File(profile.photoPath!))
                                : null,
                        child:
                            _newPhotoPath == null && profile.photoPath == null
                                ? Icon(Icons.camera_alt,
                                    size: 30, color: theme.iconTheme.color)
                                : null,
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// Card Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          /// Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Name",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Enter your name"
                                : null,
                          ),

                          const SizedBox(height: 16),

                          /// Age
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Age",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// Weight
                          TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Weight (kg)",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// Activity Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedActivity,
                            decoration: const InputDecoration(
                              labelText: "Activity Level",
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: "Low", child: Text("Low")),
                              DropdownMenuItem(
                                  value: "Moderate", child: Text("Moderate")),
                              DropdownMenuItem(
                                  value: "High", child: Text("High")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedActivity = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await profile.saveProfile(
                              name: _nameController.text.trim(),
                              age: int.tryParse(_ageController.text) ?? 0,
                              weight: int.tryParse(_weightController.text) ?? 0,
                              activity: _selectedActivity,
                              photoPath: _newPhotoPath ?? profile.photoPath,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
