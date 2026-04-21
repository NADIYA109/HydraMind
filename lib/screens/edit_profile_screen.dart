import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hydramind/providers/water_provider.dart';
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

  @override
  void initState() {
    super.initState();

    final profile = context.read<ProfileProvider>();

    _nameController.text = profile.name ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _weightController.text = profile.weight?.toString() ?? '';
    _selectedActivity = profile.activity ?? "Moderate";
  }

  ///  Camera / Gallery
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _newPhotoPath = pickedFile.path;
      });
    }
  }

  ///  Options Bottom Sheet
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Change Profile Photo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ///  Image Preview
  void _showImagePreview() {
    final imagePath =
        _newPhotoPath ?? context.read<ProfileProvider>().photoPath;

    if (imagePath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Hero(
              tag: "profile_image",
              child: InteractiveViewer(
                child: Image.file(File(imagePath)),
              ),
            ),
          ),
        ),
      ),
    );
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ///  PROFILE IMAGE + EDIT
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _showImagePreview,
                            child: Hero(
                              tag: "profile_image",
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: theme.cardColor,
                                backgroundImage: _newPhotoPath != null
                                    ? FileImage(File(_newPhotoPath!))
                                    : profile.photoPath != null
                                        ? FileImage(File(profile.photoPath!))
                                        : null,
                                child: _newPhotoPath == null &&
                                        profile.photoPath == null
                                    ? Icon(Icons.person,
                                        size: 30, color: theme.iconTheme.color)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showImageOptions,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit,
                                    size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      /// FORM CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Name",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Enter your name"
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Age",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Weight (kg)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
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

                      //const Spacer(),
                      const SizedBox(height: 30),

                      /// SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await profile.saveProfile(
                                name: _nameController.text.trim(),
                                age: int.tryParse(_ageController.text) ?? 0,
                                weight:
                                    int.tryParse(_weightController.text) ?? 0,
                                activity: _selectedActivity,
                                photoPath: _newPhotoPath ?? profile.photoPath,
                              );

                              // Recalculate water goal based on updated profile details
                              final water = context.read<WaterProvider>();
                              water.calculateDailyGoal(
                                weight:
                                    int.tryParse(_weightController.text) ?? 0,
                                age: int.tryParse(_ageController.text) ?? 0,
                                activity: _selectedActivity,
                              );
                              // Save the updated goal to Firestore
                              await water.updateDailyGoal(water.dailyGoal);

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
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
            ),
    );
  }
}
