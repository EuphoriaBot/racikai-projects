import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/subscription_controller.dart';
import 'controllers/usage_controller.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();

  await SubscriptionController.instance.loadFromStorage();

  await FavoriteController.instance.loadFromStorage();

  await UsageController.instance.loadFromStorage();

  runApp(const RacikAIApp());
}

class RacikAIApp extends StatelessWidget {
  const RacikAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RacikAI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8752E),
          brightness: Brightness.light,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
