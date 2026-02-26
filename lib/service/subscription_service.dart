import 'package:laundry_pos/core/database/app_database.dart';
import 'package:laundry_pos/core/model/subscription_status.dart';
import 'package:laundry_pos/core/model/validation_result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  //Generate unique device ID
  Future<String> getDeviceId() async {
    final db = await AppDatabase.database;
    final result = await db.query('device', limit: 1);

    if (result.isEmpty) {
      String deviceId = _generateDeviceId();
      String trialStart = DateTime.now().toIso8601String();
      String trialEnd = DateTime.now()
          .add(Duration(days: 15))
          .toIso8601String();

      await db.insert('device', {
        'device_id': deviceId,
        'trial_start_date': trialStart,
        'trial_end_date': trialEnd,
        'trial_used': 1,
      });

      return deviceId;
    } else {
      return result.first['device_id'] as String;
    }
  }

  String _generateDeviceId() {
    return 'DEVICE_${DateTime.now().microsecondsSinceEpoch}_${_randomString(8)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(DateTime.now().microsecond % chars.length),
      ),
    );
  }

  //check subscription status
  Future<SubscriptionStatus> checkSubscription() async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'subscription',
      where: 'is_active = 1',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      String expiryStr = result.first['expiry_date'] as String;
      DateTime expiry = DateTime.parse(expiryStr);
      DateTime now = DateTime.now();

      if (now.isBefore(expiry)) {
        return SubscriptionStatus(
          isPremium: true,
          expiryDate: expiry,
          planType: result.first['plan_type'] as String,
          daysLeft: expiry.difference(now).inDays,
        );
      } else {
        return SubscriptionStatus(
          isPremium: false,
          isExpired: true,
          message: 'Subscription expired on $expiryStr',
        );
      }
    }

    // final deviceResult = await db.query('device', limit: 1);
    // if (deviceResult.isNotEmpty) {
    //   String trialEndStr = deviceResult.first['trial_end_date'] as String;
    //   DateTime trialEnd = DateTime.parse(trialEndStr);
    //   DateTime now = DateTime.now();

    //   if (now.isBefore(trialEnd)) {
    //     return SubscriptionStatus(
    //       isPremium: true,
    //       expiryDate: trialEnd,
    //       planType: 'trial',
    //       daysLeft: trialEnd.difference(now).inDays,
    //       message: 'Trial active until $trialEndStr',
    //       isTrial: true,
    //     );
    //   } else {
    //     return SubscriptionStatus(
    //       isPremium: false,
    //       isExpired: true,
    //       message: 'Trial expired on $trialEndStr',
    //     );
    //   }
    // }

    return SubscriptionStatus(
      isPremium: false,
      message: 'No active subscription or trial found',
    );
  }

  //Activate with token
  Future<bool> activateToken(ValidationResult result, String code) async {
    try {
      final db = await AppDatabase.database;

      //deactivate existing subscriptions
      await db.update('subscription', {'is_active': 0}, where: 'is_active = 1');

      await db.insert('subscription', {
        'token': code,
        'plan_type': result.planType,
        'expiry_date': result.expiryDate!.toIso8601String(),
        'activated_date': DateTime.now().toIso8601String(),
        'is_active': 1,
        'device_id': await getDeviceId(),
      });

      //update settings for quick access
      // await db.insert('settings', {
      //   'key': 'subscription_expiry',
      //   'value': expiryDate.toIso8601String(),
      // }, conflictAlgorithm: ConflictAlgorithm.replace);

      return true;
    } catch (e) {
      print('Activation error: $e');
      return false;
    }
  }

  // For testing/admin: Clear subscription (for development)
  Future<void> clearSubscription() async {
    final db = await AppDatabase.database;
    await db.delete('subscription');
    //await db.delete('settings', where: "key = 'subscription_expiry'");
  }
}
