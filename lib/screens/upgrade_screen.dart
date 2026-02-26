import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_pos/core/model/validation_result.dart';
import 'package:laundry_pos/features/orders/main_order_screen.dart';
import 'package:laundry_pos/service/code_validator.dart';
import 'package:laundry_pos/service/subscription_service.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final _tokenController = TextEditingController();
  bool isActivating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upgrade to Premium')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Upgrade to Premium',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Choose a plan to continue using the app with all features.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),

            //plan cards
            _buildPlanCard('Monthly', '1000 Birr', '30 days'),
            _buildPlanCard('6-Months', '5500 Birr', '120 days'),
            _buildPlanCard('Yearly', '10000 Birr', '365 days'),

            SizedBox(height: 30),
            Divider(),
            Text('Already have a code?'),
            SizedBox(height: 10),

            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Enter activation code',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _pasteToken,
                  icon: Icon(Icons.paste),
                ),
              ),
            ),

            SizedBox(height: 10),

            if (isActivating)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _activateToken,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: const Text('Activate'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, String duration) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(duration),

        trailing: Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => _showPaymentInstructionS(),
      ),
    );
  }

  Future<void> _activateToken() async {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter activation code')));
      return;
    }

    setState(() => isActivating = true);
    String code = _tokenController.text.trim().toUpperCase();

    ValidationResult result = CodeValidator.validateCode(code);

    setState(() => isActivating = false);

    if (result.isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      //navigate to main screen
      Navigator.pushReplacementNamed(context, '/home');

      await SubscriptionService().activateToken(result, code);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  void _pasteToken() {
    Clipboard.getData('text/plain').then((clipboardContent) {
      if (clipboardContent != null && clipboardContent.text != null) {
        _tokenController.text = clipboardContent.text!;
      }
    });
  }

  void _showPaymentInstructionS() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('How to Pay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Pay via:'),
            Text('   Bank: 1234567890'),
            Text('   PayPal: laundry@yourapp.com'),
            SizedBox(height: 10),
            Text('2. Send transaction ID to:'),
            Text('   Telegram: @LaundryBot'),
            SizedBox(height: 10),
            Text('3. You\'ll receive code within 24h'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
