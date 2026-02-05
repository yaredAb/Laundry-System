import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

// In main.dart
void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const LaundryApp());
}

class LaundryApp extends StatelessWidget {
  const LaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laundry System',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _testDB();
  }

  Future<void> _testDB() async {
    try {
      print("we are here");
      final db = await AppDatabase.database;
      print('Database opened: ${db.isOpen}');
    } catch (e) {
      print('DB ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Initializing database...')),
    );
  }
}
