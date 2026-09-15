import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/subscription_controller.dart';
import 'controllers/usage_controller.dart';
import 'services/local_storage_service.dart';
import 'controllers/meal_planner_controller.dart';
import 'core/theme/app_theme.dart';
import 'controllers/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();

  await ThemeController.instance.loadFromStorage();

  await SubscriptionController.instance.loadFromStorage();

  await FavoriteController.instance.loadFromStorage();

  await UsageController.instance.loadFromStorage();

  await MealPlannerController.instance.loadFromStorage();

  runApp(const RacikAIApp());
}

class RacikAIApp extends StatelessWidget {
  const RacikAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RacikAI',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
