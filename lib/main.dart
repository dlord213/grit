import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services/notification_service.dart';
import 'ui/theme.dart';
import 'ui/main_navigation_host.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/shop_provider.dart';

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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        ref.read(activeWorkoutProvider.notifier).onAppPaused();
        break;
      case AppLifecycleState.resumed:
        ref.read(activeWorkoutProvider.notifier).onAppResumed();
        ref.read(restTimerProvider.notifier).onAppResumed();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final palette = ref.watch(activePaletteProvider);
    return MaterialApp(
      title: 'Grit Gym Tracker',
      debugShowCheckedModeBanner: false,
      theme: GritTheme.buildLightTheme(palette),
      darkTheme: GritTheme.buildDarkTheme(palette),
      themeMode: themeMode,
      home: const MainNavigationHost(),
    );
  }
}
