import 'package:flutter/material.dart';

class ReceiptContent extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ReceiptContent({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(i['item_name'])),
                  Text('${i['quantity']}'),
                  SizedBox(width: 10),
                  Text('${i['price']}'),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
