import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final dynamic product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              product['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text('Category: ${product['category']}'),
            Text('Price: \$${product['price']}'),
            Text('Stock: ${product['stock']}'),
            const SizedBox(height: 20),
            Text(
              'Reviews',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...product['reviews'].map<Widget>((review) {
              return ListTile(
                title: Text(review['reviewerName']),
                subtitle: Text(review['comment']),
                trailing: Text('${review['rating']} ★'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
