class PaymentHelper {
  static String calculatePaymentStatus({
    required double paid,
    required double total,
  }) {
    if (paid <= 0) return 'Pending';
    if (paid < total) return 'Partial';
    return 'Paid';
  }
}
