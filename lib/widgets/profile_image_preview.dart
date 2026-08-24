import 'dart:io';
import 'package:flutter/material.dart';

class ProfileImagePreview extends StatelessWidget {
  final String? imagePath;
  final String heroTag;

  const ProfileImagePreview({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidImage = imagePath != null &&
        imagePath!.trim().isNotEmpty &&
        File(imagePath!).existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: hasValidImage
            ? Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.account_circle,
                    size: 140,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Profile Photo",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
