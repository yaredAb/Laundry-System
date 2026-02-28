import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:laundry_pos/core/model/validation_result.dart';

class CodeValidator {
  static ValidationResult validateCode(String code) {
    if (code.length != 10) {
      return ValidationResult.invalid(
        'Code must be exactly 10 characters long',
      );
    }

    if (code[5] != '-') {
      return ValidationResult.invalid('Invalid format');
    }

    String planCode = code[0];
    String yearStr = code.substring(1, 3);
    String monthStr = code.substring(3, 5);
    String checkSumStr = code.substring(6);

    // validate plan code
    if (!['M', 'S', 'Y'].contains(planCode)) {
      return ValidationResult.invalid('Invalid plan code');
    }

    //validate yesr
    int? year = int.tryParse(yearStr);
    if (year == null || year < 26 || year > 40) {
      return ValidationResult.invalid('Invalid year');
    }

    //validate month
    int? month = int.tryParse(monthStr);
    if (month == null || month < 1 || month > 12) {
      return ValidationResult.invalid('Invalid month');
    }

    //validate check sum
    String base = planCode + yearStr + monthStr;
    String expectedChecksum = _calculateChecksum(base);

    if (checkSumStr != expectedChecksum) {
      return ValidationResult.invalid(
        'Invalid activation code. expected checksum: $expectedChecksum',
      );
    }

    DateTime expiry = _calculateExpiry(planCode, year, month);

    if (DateTime.now().isAfter(expiry)) {
      return ValidationResult.expired(expiry);
    }

    return ValidationResult.valid(
      planType: _getPlanName(planCode),
      expiryDate: expiry,
      daysLeft: expiry.difference(DateTime.now()).inDays,
    );
  }

  static String _calculateChecksum(String input) {
    String encryptionKey = 'MAYA2026';

    final hmacSha256 = Hmac(sha256, utf8.encode(encryptionKey));
    final digest = hmacSha256.convert(utf8.encode(input));

    print("BASE: '$input'");
    print("DART CHECKSUM: ${digest.toString().substring(0, 4).toUpperCase()}");
    return digest.toString().substring(0, 4).toUpperCase();
  }

  static DateTime _calculateExpiry(String planCode, int year, int month) {
    DateTime now = DateTime.now();
    int fullYear = 2000 + year;

    if (planCode == 'M') {
      return DateTime(fullYear, month + 1, now.day).subtract(Duration(days: 1));
    } else if (planCode == 'S') {
      return DateTime(fullYear, month + 6, now.day).subtract(Duration(days: 1));
    } else if (planCode == 'Y') {
      return DateTime(fullYear + 1, month, now.day).subtract(Duration(days: 1));
    }

    throw Exception('Invalid plan code');
  }

  static String _getPlanName(String planCode) {
    switch (planCode) {
      case 'M':
        return 'Monthly';
      case 'S':
        return '6 Months';
      case 'Y':
        return 'Yearly';
      default:
        return 'Unknown';
    }
  }
}
