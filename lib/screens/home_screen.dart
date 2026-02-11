import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hydramind/widgets/animated_mood_card.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/water_provider.dart';
import '../providers/profile_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      context.read<ProfileProvider>().loadProfile();
      context.read<WaterProvider>().loadWaterData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, profile, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: profile.photoPath != null
                      ? FileImage(File(profile.photoPath!))
                      : null,
                  child: profile.photoPath == null
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text(
          'HydraMind',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, profile, _) {
                  if (profile.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return Text(
                    profile.name != null && profile.name!.isNotEmpty
                        ? 'Welcome, ${profile.name}'
                        : 'Welcome',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),
              const Text(
                'Let’s track your water intake today',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Water progress card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Today’s Water Intake',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 140,
                              width: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: water.progress,
                                    strokeWidth: 10,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.primary,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${water.currentIntake} ml',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'of ${water.dailyGoal} ml',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// Add Water buttons
                      const Text(
                        'Add Water',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _waterButton(context, '+250 ml', 250),
                          const SizedBox(width: 16),
                          _waterButton(context, '+500 ml', 500),
                        ],
                      ),

                      const SizedBox(height: 32),

                      ///  Mood Card
                      const AnimatedMoodCard(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              /// Footer text
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Stay hydrated 💧',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Water button
  Widget _waterButton(BuildContext context, String text, int amount) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            context.read<WaterProvider>().addWater(amount);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
