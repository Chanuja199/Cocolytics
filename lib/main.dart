import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'navigation/app_router.dart';
import 'providers/active_plan_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/forum_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/map_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/scan_provider.dart';
import 'services/connectivity_service.dart';
import 'services/local_storage_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocalStorageService.init();
  runApp(const CocolyticsApp());
}

class CocolyticsApp extends StatelessWidget {
  const CocolyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ActivePlanProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        Provider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp.router(
        title: 'Cocolytics by chanuja',
        debugShowCheckedModeBanner: false,
        routerConfig: createRouter(context),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
