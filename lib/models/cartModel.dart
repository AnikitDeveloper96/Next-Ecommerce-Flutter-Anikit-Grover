// File: lib/models/cart_model_for_checkout.dart
import 'package:nextecommerceapp/models/product_model.dart';

class CartModelForCheckout {
  final Product product;
  final int productQuantity;

  CartModelForCheckout({required this.product, required this.productQuantity});

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'productQuantity': productQuantity};
  }

  factory CartModelForCheckout.fromMap(Map<String, dynamic> map) {
    return CartModelForCheckout(
      product: Product.fromJson(map['product'] as Map<String, dynamic>),
      productQuantity: map['productQuantity'] as int,
    );
  }
}
