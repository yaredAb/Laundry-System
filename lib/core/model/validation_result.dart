class ValidationResult {
  final bool isValid;
  final bool isExpired;
  final String? planType;
  final DateTime? expiryDate;
  final int? daysLeft;
  final String message;

  ValidationResult._({
    required this.isValid,
    this.isExpired = false,
    this.planType,
    this.expiryDate,
    this.daysLeft,
    required this.message,
  });

  factory ValidationResult.valid({
    required String planType,
    required DateTime expiryDate,
    required int daysLeft,
  }) {
    return ValidationResult._(
      isValid: true,
      message: 'Valid until ${_formatDate(expiryDate)}',
      planType: planType,
      expiryDate: expiryDate,
      daysLeft: daysLeft,
    );
  }

  factory ValidationResult.expired(DateTime expiryDate) {
    return ValidationResult._(
      isValid: false,
      isExpired: true,
      message: 'Expired on ${_formatDate(expiryDate)}',
      expiryDate: expiryDate,
    );
  }

  factory ValidationResult.invalid(String reason) {
    return ValidationResult._(isValid: false, message: reason);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
