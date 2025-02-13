import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/sleep_service.dart';
import 'screens/home_screen.dart';
import 'screens/era_creation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final sleepService = SleepService();
        sleepService.initialize();
        return sleepService;
      },
      child: MaterialApp(
        title: '司辰',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.orange,
          ),
          useMaterial3: true,
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepService>(
      builder: (context, sleepService, child) {
        if (sleepService.isFirstLaunch) {
          return const EraCreationScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
