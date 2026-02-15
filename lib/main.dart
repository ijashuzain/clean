import 'package:flutter/material.dart';
import 'package:clean_sample/features/splash/presentation/views/splash_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Clean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily:
            'Roboto', // Assuming default system font, but specifying for clarity
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashView(),
    );
  }
}
