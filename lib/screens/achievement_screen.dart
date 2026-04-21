import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/streak_provider.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  bool _popupShownInSession = false;
  late ConfettiController _confettiController;

  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    Future.microtask(() {
      final achievement = context.read<AchievementProvider>();
      final streak = context.read<StreakProvider>().streak;

      achievement.checkAchievements(streak);
      achievement.lastCheckedStreak = streak;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = context.watch<AchievementProvider>();
    final streak = context.watch<StreakProvider>().streak;
    if (achievement.lastCheckedStreak != streak) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        achievement.checkAchievements(streak);
        achievement.lastCheckedStreak = streak;
      });
    }
    final milestones = [1, 3, 7, 14, 30];

    final nextGoal = milestones.firstWhere(
      (m) => streak < m,
      orElse: () => milestones.last,
    );

    final progress = streak / nextGoal;
    final remaining = nextGoal - streak;
    final allBadges = [
      "Starter 💧",
      "Consistent 👍",
      "Strong 🔥",
      "Pro 💪",
      "Master 💎",
    ];

    // if (achievement.isLoaded && achievement.lastCheckedStreak != streak) {
    //   achievement.checkAchievements(streak);
    //   achievement.lastCheckedStreak = streak;
    // }

    List<String> newBadges = achievement.unlockedBadges
        .where((b) => !achievement.shownBadges.contains(b))
        .toList();

    String? badge = newBadges.isNotEmpty ? newBadges.first : null;

    if (achievement.isLoaded &&
        badge != null &&
        !_popupShownInSession &&
        !achievement.shownBadges.contains(badge)) {
      _popupShownInSession = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();

        showDialog(
          context: context,
          builder: (_) => _buildBadgePopup(context, badge),
        );
        achievement.shownBadges.add(badge);
        achievement.saveShownBadges();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.9),
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          "🔥 $streak Day Streak",
                          key: ValueKey(streak),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        streak == 0
                            ? "Start your journey today 💧"
                            : streak < 3
                                ? "Good start! Keep going 💪"
                                : streak < 7
                                    ? "You're building a habit 💧"
                                    : streak < 30
                                        ? "You're on fire 🔥"
                                        : "You're unstoppable 🚀",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (streak < 30)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Progress to next badge 🚀",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).cardColor.withOpacity(0.5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress > 1 ? 1 : progress,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$streak / $nextGoal days",
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        remaining > 0
                            ? (remaining == 1
                                ? "Just 1 more day! 🔥"
                                : "$remaining days to go 🚀")
                            : "Badge unlocked! 🎉",
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "🏆 All badges unlocked 🎉",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                Text(
                  "Your Badges",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),

                const SizedBox(height: 10),

                //  Badge Grid
                Expanded(
                  child: GridView.builder(
                      itemCount: allBadges.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        final badge = allBadges[index];
                        final isUnlocked =
                            achievement.unlockedBadges.contains(badge);

                        return AnimatedScale(
                          scale: isUnlocked ? 1.0 : 0.9,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? Theme.of(context).cardColor
                                  : Theme.of(context)
                                      .cardColor
                                      .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isUnlocked
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  badge,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                    color: isUnlocked
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.5),
                                  ),
                                ),
                                if (!isUnlocked) ...[
                                  const SizedBox(height: 6),
                                  Icon(
                                    Icons.lock_outline,
                                    size: 26,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.4),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // top to bottom
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePopup(BuildContext context, String badge) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🎉 New Badge Unlocked!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.emoji_events,
              size: 60,
              color: Colors.amber,
            ),
            const SizedBox(height: 10),
            Text(
              badge,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Awesome! 🚀"),
            )
          ],
        ),
      ),
    );
  }
}
