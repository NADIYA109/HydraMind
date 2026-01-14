import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hydramind/providers/insights_provider.dart';
import 'package:hydramind/providers/mood_provider.dart';
import 'package:hydramind/providers/profile_provider.dart';
import 'package:hydramind/providers/water_provider.dart';
import 'package:hydramind/screens/spalsh_screen.dart';
import 'package:hydramind/services/notification_service.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 await NotificationService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),

      ],
      child: const  MyApp(),
      ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydraMind',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
    