import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hydramind/core/constants/app_theme.dart';
import 'package:hydramind/providers/insights_provider.dart';
import 'package:hydramind/providers/mood_provider.dart';
import 'package:hydramind/providers/profile_provider.dart';
import 'package:hydramind/providers/theme_provider.dart';
import 'package:hydramind/providers/water_provider.dart';
import 'package:hydramind/screens/spalsh_screen.dart';
import 'package:hydramind/services/notification_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotificationHelper.instance.initNotifications();
  await NotificationHelper.instance.requestPermission();
  //await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'HydraMind',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: SplashScreen(),
    );
  }
}
