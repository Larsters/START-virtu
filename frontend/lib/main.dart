import 'package:flutter/material.dart';
import 'package:frontend/controllers/farm_data_controller.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/preferences_manager.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/view/home/home_view.dart';
import 'package:frontend/view/welcome_survey/welcome_survey_view.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FarmDataController(),
      child: MaterialApp(
        title: 'Syngenta',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AppStartupRouter(),
      ),
    );
  }
}

class AppStartupRouter extends StatelessWidget {
  const AppStartupRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}
