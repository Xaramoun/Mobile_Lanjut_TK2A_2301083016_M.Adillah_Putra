import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/all_product.dart';
import 'package:flutter_provider/widgets/product_item.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget{
  const ProductGrid({super.key});


  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final allProduct = productData.allProducts;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: allProduct.length,
      itemBuilder: (ctx, i) => ProductItem(
        allProduct[i].id!,
        allProduct[i].title!,
        allProduct[i].imageUrl!,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
         ),  
         );
  }
}