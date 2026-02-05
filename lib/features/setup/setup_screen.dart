import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/main.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _storeNameController = TextEditingController();
  final _storePhoneController = TextEditingController();

  Future<void> _saveSettings() async {
    final db = await AppDatabase.database;
    await db.insert('settings', {
      'store_name': _storeNameController.text,
      'store_phone': _storePhoneController.text,
    });

    //Navigate to main screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("First-Time Setup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(labelText: 'Store Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _storePhoneController,
              decoration: InputDecoration(labelText: 'Store Phone Number'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text("Save & Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
