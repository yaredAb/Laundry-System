import 'package:flutter/material.dart';
import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/features/orders/main_order_screen.dart';
import 'package:laundry_pos/service/subscription_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    //wait a bit for splash
    await Future.delayed(Duration(seconds: 2));

    //check if settings exist
    final hasSetting = await AppDatabase.hasSettings();

    if (!hasSetting) {
      Navigator.pushReplacementNamed(context, '/setup');
      return;
    }

    //check for subscription
    final subStatus = await SubscriptionService().checkSubscription();

    if (subStatus.isPremium) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/upgrade');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_laundry_service, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Maya Laundry',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
