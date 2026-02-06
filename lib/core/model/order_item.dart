class OrderItem {
  int itemId;
  String itemName;
  int quantity;
  double price;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.price,
    this.quantity = 1,
  });

  double get subtotal => quantity * price;
}
