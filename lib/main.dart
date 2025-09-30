import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// Entry point of the app
void main() {
  runApp(const WeatherApp());
}

// Root widget of our app
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title (shown in task switcher)
      title: 'Weather App',
      
      // Remove debug banner in top-right corner
      debugShowCheckedModeBanner: false,
      
      // App theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Use Material 3 design
      ),
      
      // Starting screen
      home: const HomeScreen(),
    );
  }
}