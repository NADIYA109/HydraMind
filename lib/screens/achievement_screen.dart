import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/streak_provider.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievement = context.watch<AchievementProvider>();
    final streak = context.watch<StreakProvider>().streak;
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

    List<String> newBadges = achievement.unlockedBadges
        .where((b) => !achievement.shownBadges.contains(b))
        .toList();

    String? badge = newBadges.isNotEmpty ? newBadges.first : null;

    if (badge != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => _buildBadgePopup(context, badge!),
        );

        achievement.shownBadges.add(badge!);
      });
    }
    if (achievement.lastCheckedStreak != streak) {
      achievement.checkAchievements(streak);
      achievement.lastCheckedStreak = streak;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: Padding(
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
                    Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🔥 $streak Day Streak",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                                : "You're on fire 🔥",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
              remaining > 0 ? "$remaining days to go 🚀" : "Badge unlocked! 🎉",
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
              ),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final badge = allBadges[index];
                    final isUnlocked =
                        achievement.unlockedBadges.contains(badge);

                    return Container(
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Theme.of(context).cardColor
                            : Theme.of(context).cardColor.withOpacity(0.5),
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
                                  ? Theme.of(context).textTheme.bodyLarge?.color
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
                    );
                  }),
            ),
          ],
        ),
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
              onPressed: () => Navigator.pop(context),
              child: const Text("Awesome! 🚀"),
            )
          ],
        ),
      ),
    );
  }
}
