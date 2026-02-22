class SubscriptionStatus {
  final bool isPremium;
  final DateTime? expiryDate;
  final String planType;
  final int daysLeft;
  final String message;
  final bool isExpired;
  final bool isTrial;

  SubscriptionStatus({
    required this.isPremium,
    this.expiryDate,
    this.planType = 'free',
    this.daysLeft = 0,
    this.message = '',
    this.isExpired = false,
    this.isTrial = false,
  });
}
