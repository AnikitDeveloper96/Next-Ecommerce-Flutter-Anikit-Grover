import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc_event/cart_event.dart';
import '../../blocs/bloc_event/favourite_event.dart';
import '../../blocs/bloc_state/cart_state.dart';
import '../../blocs/bloc_state/fav_state.dart';
import '../../blocs/blocs/cart_bloc.dart';
import '../../blocs/blocs/fav_bloc.dart';
import '../../models/cartModel.dart';
import '../../models/product_model.dart';
import '../../widgets/rating_review.dart' show RatingReviewsSection;
import '../../routes.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;

  String capitalizeFirstLetter(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final Product product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      NextEcommerceAppRoutes.cartPage,
                    ),
              ),
              BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  int totalItemsInCart = 0;
                  if (cartState is CartUpdatedItemsState) {
                    totalItemsInCart = cartState.cartItems.fold(
                      0,
                      (sum, item) => sum + item.productQuantity,
                    );
                  }
                  return totalItemsInCart > 0
                      ? Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$totalItemsInCart',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 80.0,
            ), // Space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.4,
                  child:
                      product.images != null && product.images!.isNotEmpty
                          ? CarouselSlider.builder(
                            itemCount: product.images!.length,
                            itemBuilder:
                                (context, index, realIndex) => Hero(
                                  tag:
                                      'productImage${product.id}', // Unique tag for Hero animation
                                  child: CachedNetworkImage(
                                    imageUrl: product.images![index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder:
                                        (_, __) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                    errorWidget:
                                        (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                  ),
                                ),
                            options: CarouselOptions(
                              viewportFraction: 1.0,
                              autoPlay: (product.images?.length ?? 0) > 1,
                              enlargeCenterPage: false,
                              onPageChanged: (index, reason) {
                                if (mounted) {
                                  setState(() => _currentImageIndex = index);
                                }
                              },
                            ),
                          )
                          : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                ),
                if ((product.images?.length ?? 0) > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          product.images!.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentImageIndex == entry.key
                                        ? Colors.black
                                        : Colors.grey[300],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.title ?? "Unknown Product",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              capitalizeFirstLetter(
                                product.category ?? "Uncategorized",
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.description ??
                            "No description available for this product.",
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RatingReviewsSection(
                        reviews: product.reviews ?? [],
                        maxWidth: screenWidth * 0.9,
                      ),
                      const SizedBox(height: 80), // spacing for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, -3), // changes position of shadow
                  ),
                ],
              ),
              child: Row(
                children: [
                  BlocBuilder<FavoriteProductBloc, FavouriteProductState>(
                    builder: (context, favState) {
                      bool isFavorite = favState.favoriteItems.any(
                        (favProduct) => favProduct.id == product.id,
                      );
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: IconButton(
                          onPressed: () {
                            if (isFavorite) {
                              context.read<FavoriteProductBloc>().add(
                                RemoveFromFavorites(product),
                              );
                            } else {
                              context.read<FavoriteProductBloc>().add(
                                AddToFavorites(product),
                              );
                            }
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.black : Colors.grey,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        final cartItems =
                            cartState is CartUpdatedItemsState
                                ? cartState.cartItems
                                : <CartModelForCheckout>[];
                        final productInCart = cartItems.firstWhere(
                          (item) => item.product.id == product.id,
                          orElse:
                              () => CartModelForCheckout(
                                product: product,
                                productQuantity: 0,
                              ),
                        );
                        return _buildAddToCartButton(
                          cartProductInCart: productInCart,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton({
    required CartModelForCheckout cartProductInCart,
  }) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        if (cartProductInCart.productQuantity > 0) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed:
                      () => context.read<CartBloc>().add(
                        UpdateCartItemsEvent(cartProductInCart.product, -1),
                      ),
                ),
                Text(
                  '${cartProductInCart.productQuantity}',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed:
                      () => context.read<CartBloc>().add(
                        UpdateCartItemsEvent(cartProductInCart.product, 1),
                      ),
                ),
              ],
            ),
          );
        } else {
          return ElevatedButton(
            onPressed:
                () => context.read<CartBloc>().add(
                  AddtoCartItemsEvent(cartProductInCart.product),
                ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 24.0,
              ),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Add to Cart",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          );
        }
      },
    );
  }
}
