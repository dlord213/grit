import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services/notification_service.dart';
import 'ui/theme.dart';
import 'ui/main_navigation_host.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone database for local notifications
  tz.initializeTimeZones();
  
  // Initialize notifications
  await NotificationService().init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grit Gym Tracker',
      debugShowCheckedModeBanner: false,
      theme: GritTheme.darkTheme,
      home: const MainNavigationHost(),
    );
  }
}
