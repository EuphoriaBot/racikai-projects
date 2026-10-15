import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'controllers/meal_planner_controller.dart';
import 'controllers/subscription_controller.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/favorite/presentation/cubit/favorite_cubit.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();

  await setupDependencies();

  await SubscriptionController.instance.loadFromStorage();

  await MealPlannerController.instance.loadFromStorage();

  runApp(const RacikAIApp());
}

class RacikAIApp extends StatelessWidget {
  const RacikAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteCubit()..loadFromStorage(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'RacikAI',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}
