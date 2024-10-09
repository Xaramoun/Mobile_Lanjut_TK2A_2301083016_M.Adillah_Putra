import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/all_product.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String; // mengambil id produk dari argumen route
    final product = Provider.of<Products>(context).allProducts.firstWhere((prodId) => prodId.id == productId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            child: Image.network(
              '${product.imageUrl}',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 30),
          Text(
            '${product.title}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold) ,)
        ],
          ),
    );
  }
}