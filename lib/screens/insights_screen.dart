// import 'package:flutter/material.dart';
// import 'package:hydramind/providers/streak_provider.dart';
// import 'package:hydramind/screens/achievement_screen.dart';
// import 'package:hydramind/screens/report_screen.dart';
// import 'package:hydramind/services/firestore_services.dart';
// import 'package:provider/provider.dart';
// import '../core/constants/app_colors.dart';
// import '../providers/water_provider.dart';
// import '../providers/mood_provider.dart';
// import '../providers/insights_provider.dart';

// class InsightsScreen extends StatefulWidget {
//   const InsightsScreen({super.key});

//   @override
//   State<InsightsScreen> createState() => _InsightsScreenState();
// }

// class _InsightsScreenState extends State<InsightsScreen> {
//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() async {
//       final data = await FirestoreService().fetchTodayLog();

//       if (data != null) {
//         context.read<MoodProvider>().loadFromFirestore(data);
//       }

//       context.read<StreakProvider>().loadStreak();
//     });
//   }
//   // @override
//   // void initState() {
//   //   super.initState();

//   //   Future.microtask(() {
//   //     context.read<StreakProvider>().loadStreak();
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final water = context.watch<WaterProvider>();
//     final mood = context.watch<MoodProvider>();
//     final insights = context.watch<InsightsProvider>();
//     final streak = context.watch<StreakProvider>().streak;
//     final insightsList = insights.generateInsights(
//       water: water,
//       mood: mood,
//     );

//     final int waterPercent = water.dailyGoal == 0
//         ? 0
//         : ((water.currentIntake / water.dailyGoal) * 100).round();

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
//         title: const Text('Insights'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Today Summary
//             Text(
//               'Today’s Summary',
//               style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                   //color: AppColors.textPrimary,
//                   color: Theme.of(context).textTheme.bodyLarge?.color),
//             ),

//             const SizedBox(height: 20),

//             /// Summary Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 //color: Colors.white,
//                 color: Theme.of(context).cardColor,

//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   /// Water
//                   _summaryRow(
//                     context,
//                     title: 'Hydration',
//                     value: '$waterPercent%',
//                   ),

//                   const SizedBox(height: 12),

//                   /// Mood
//                   _summaryRow(
//                     context,
//                     title: 'Mood',
//                     value: mood.mood ?? 'Not logged',
//                   ),

//                   const SizedBox(height: 12),

//                   /// Energy
//                   _summaryRow(
//                     context,
//                     title: 'Energy',
//                     value: '${mood.energyLevel}/5',
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             /// ================= STREAK CARD =================
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const AchievementScreen(),
//                   ),
//                 );
//               },
//               child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 18,
//                         backgroundColor: Theme.of(context)
//                             .textTheme
//                             .bodyMedium
//                             ?.color
//                             ?.withOpacity(0.1),
//                         child: Text("🔥"),
//                       ),
//                       SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("$streak Day Streak",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Theme.of(context)
//                                     .textTheme
//                                     .bodyLarge
//                                     ?.color,
//                               )),
//                           Text(
//                             streak == 0
//                                 ? "Start your streak today 💧"
//                                 : "Keep it going! 💪",
//                             style: TextStyle(
//                               color: Theme.of(context)
//                                   .textTheme
//                                   .bodyMedium
//                                   ?.color
//                                   ?.withOpacity(0.7),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       Icon(
//                         Icons.arrow_forward_ios,
//                         size: 16,
//                         color: Theme.of(context)
//                             .textTheme
//                             .bodyMedium
//                             ?.color
//                             ?.withOpacity(0.6),
//                       ),
//                     ],
//                   )),
//             ),

//             const SizedBox(height: 16),

//             /// Insight message
//             /// ///MULTIPLE INSIGHT CARDS
//             ...insightsList.map((text) {
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 10),
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         text,
//                         style: TextStyle(
//                           fontSize: 14,
//                           height: 1.4,
//                           color: Theme.of(context).textTheme.bodyLarge?.color,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),

//             const SizedBox(height: 20),

//             ///  Weekly Report Card
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ReportScreen(),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).cardColor,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     )
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     /// Icon
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.bar_chart, size: 20),
//                     ),

//                     const SizedBox(width: 12),

//                     /// Text
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Weekly Report",
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               color:
//                                   Theme.of(context).textTheme.bodyLarge?.color,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             "Track your hydration trends",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Theme.of(context)
//                                   .textTheme
//                                   .bodyMedium
//                                   ?.color
//                                   ?.withOpacity(0.6),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     /// Arrow
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.color
//                           ?.withOpacity(0.6),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const Spacer(),

//             /// Footer
//             Center(
//               child: Text(
//                 'Insights update daily based on your habits 💧',
//                 style: TextStyle(
//                     fontSize: 13,
//                     color: Theme.of(context)
//                         .textTheme
//                         .bodyMedium
//                         ?.color
//                         ?.withOpacity(0.7)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Reusable row widget
//   Widget _summaryRow(
//     BuildContext context, {
//     required String title,
//     required String value,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 15,
//             color:
//                 Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Theme.of(context).textTheme.bodyLarge?.color,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:hydramind/providers/streak_provider.dart';
import 'package:hydramind/screens/achievement_screen.dart';
import 'package:hydramind/screens/report_screen.dart';
import 'package:hydramind/services/firestore_services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/water_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/insights_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final data = await FirestoreService().fetchTodayLog();

      if (data != null) {
        context.read<MoodProvider>().loadFromFirestore(data);
      }

      context.read<StreakProvider>().loadStreak();
    });
  }
  // @override
  // void initState() {
  //   super.initState();

  //   Future.microtask(() {
  //     context.read<StreakProvider>().loadStreak();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();
    final mood = context.watch<MoodProvider>();
    final insights = context.watch<InsightsProvider>();
    final streak = context.watch<StreakProvider>().streak;
    final insightsList = insights.generateInsights(
      water: water,
      mood: mood,
    );

    final int waterPercent = water.dailyGoal == 0
        ? 0
        : ((water.currentIntake / water.dailyGoal) * 100).round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        title: const Text('Insights'),
      ),
      body: SafeArea(
        //padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Today Summary
                Text(
                  'Today’s Summary',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      //color: AppColors.textPrimary,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),

                const SizedBox(height: 20),

                /// Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    //color: Colors.white,
                    color: Theme.of(context).cardColor,

                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      /// Water
                      _summaryRow(
                        context,
                        title: 'Hydration',
                        value: '$waterPercent%',
                      ),

                      const SizedBox(height: 12),

                      /// Mood
                      _summaryRow(
                        context,
                        title: 'Mood',
                        value: mood.mood ?? 'Not logged',
                      ),

                      const SizedBox(height: 12),

                      /// Energy
                      _summaryRow(
                        context,
                        title: 'Energy',
                        value: '${mood.energyLevel}/5',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ================= STREAK CARD =================
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AchievementScreen(),
                      ),
                    );
                  },
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.1),
                            child: Text("🔥"),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$streak Day Streak",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  )),
                              Text(
                                streak == 0
                                    ? "Start your streak today 💧"
                                    : "Keep it going! 💪",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                        ],
                      )),
                ),

                const SizedBox(height: 16),

                /// Insight message
                /// ///MULTIPLE INSIGHT CARDS
                ...insightsList.map((text) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                ///  Weekly Report Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        /// Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bar_chart, size: 20),
                        ),

                        const SizedBox(width: 12),

                        /// Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Weekly Report",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Track your hydration trends",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Arrow
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),

                //  const Spacer(),

                const SizedBox(height: 20),

                /// Footer
                Center(
                  child: Text(
                    'Insights update daily based on your habits 💧',
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable row widget
  Widget _summaryRow(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
