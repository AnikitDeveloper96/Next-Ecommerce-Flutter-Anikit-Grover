import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../blocs/bloc_event/favourite_event.dart';
import '../blocs/bloc_state/fav_state.dart';
import '../blocs/blocs/fav_bloc.dart';
import '../constant/colors.dart';
import '../constant/textstyle.dart';
import '../models/product_model.dart';
import '../routes.dart';

class ProductGrid extends StatefulWidget {
  final List<Product> products;
  final double screenWidth;
  final double screenHeight;
  final bool isFavoritesScreen;
  final bool isSearchScreen;
  final bool isHomeScreen;

  const ProductGrid({
    super.key,
    required this.products,
    required this.screenWidth,
    required this.screenHeight,
    this.isFavoritesScreen = false,
    this.isSearchScreen = false,
    this.isHomeScreen = false,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  @override
  Widget build(BuildContext context) {
    // Calculate an appropriate mainAxisExtent based on content
    double calculateMainAxisExtent() {
      // These values are fine-tuned for better spacing and visibility.
      // Adjust these multipliers based on your device and desired visual outcome.
      if (widget.isHomeScreen) {
        // Increased this slightly to account for more spacing and ensure visibility.
        return widget.screenHeight * 0.39; // Slightly increased
      } else if (widget.isSearchScreen || widget.isFavoritesScreen) {
        // Increased this slightly to account for more spacing and ensure visibility.
        return widget.screenHeight * 0.39; // Slightly increased
      }
      return widget.screenHeight *
          0.36; // Default fallback, also slightly increased
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.screenWidth > 600 ? 3 : 2,
        mainAxisSpacing: widget.screenHeight * 0.02,
        crossAxisSpacing: widget.screenWidth * 0.02,
        mainAxisExtent: calculateMainAxisExtent(),
      ),
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        var product = widget.products[index];
        return _buildProductCard(
          context,
          product,
          widget.screenWidth,
          widget.screenHeight,
          isSearchScreen: widget.isSearchScreen,
          isFavoritesScreen: widget.isFavoritesScreen,
          isHomeScreen: widget.isHomeScreen,
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    double screenWidth,
    double screenHeight, {
    bool isSearchScreen = false,
    bool isFavoritesScreen = false,
    bool isHomeScreen = false,
  }) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            NextEcommerceAppRoutes.productDetailScreen,
            arguments: product,
          );
        },
        child: Card(
          color: greyColor,
          clipBehavior: Clip.antiAlias,
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProductImage(
                    product,
                    screenHeight,
                    isSearchScreen,
                    isFavoritesScreen,
                    isHomeScreen,
                  ),
                  Expanded(
                    child: _buildProductDetails(
                      context,
                      product,
                      screenWidth,
                      screenHeight,
                      isSearchScreen: isSearchScreen,
                      isFavoritesScreen: isFavoritesScreen,
                      isHomeScreen: isHomeScreen,
                    ),
                  ),
                ],
              ),
              if (!isSearchScreen)
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: _buildFavoriteButton(product),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(
    Product product,
    double screenHeight,
    bool isSearchScreen,
    bool isFavoritesScreen,
    bool isHomeScreen,
  ) {
    // Proportions for image height, adjusted to ensure enough space for text.
    return SizedBox(
      height:
          isHomeScreen
              ? screenHeight * 0.17
              : screenHeight *
                  0.20, // Slightly reduced image height to give more to text
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: CachedNetworkImage(
          imageUrl: product.images?.first ?? "",
          fit: BoxFit.cover,
          placeholder: (_, __) => const ShimmerProductImage(),
          errorWidget: (_, __, ___) => const ImageErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(Product product) {
    return BlocBuilder<FavoriteProductBloc, FavouriteProductState>(
      builder: (context, favState) {
        bool isFavorite = favState.favoriteItems.any(
          (item) => item.id == product.id,
        );
        return GestureDetector(
          onTap: () {
            context.read<FavoriteProductBloc>().add(
              isFavorite
                  ? RemoveFromFavorites(product)
                  : AddToFavorites(product),
            );
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.8),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.grey : Colors.black,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    Product product,
    double screenWidth,
    double screenHeight, {
    bool isSearchScreen = false,
    bool isFavoritesScreen = false,
    bool isHomeScreen = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.end, // Let Spacer handle distribution
        children: [
          // Product Name
          Expanded(
            flex: 2, // Gives more flexible space to the product name
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                product.title ?? "Product Name",
                style: NextEcommerceAppTextStyles.producttitle.copyWith(
                  fontSize: 16, // Increased font size for clarity
                  fontWeight:
                      isSearchScreen || isFavoritesScreen
                          ? FontWeight.w600
                          : FontWeight.w500,
                ),
                maxLines: 2, // Explicitly set to 2 lines
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Increased spacing between name and price
          const SizedBox(height: 12), // Increased from 8 to 12
          // Price
          Text(
            '\$${product.price?.toStringAsFixed(2) ?? "0.00"}',
            style: const TextStyle(
              fontSize: 18, // Increased price font size
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (isHomeScreen) ...[
            const Spacer(flex: 1), // Flexible spacing to push SHOP NOW
            Text(
              "SHOP NOW",
              style: NextEcommerceAppTextStyles.shopNowButton.copyWith(
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4), // Small spacing before divider
            Divider(
              color: Colors.black,
              thickness: 1,
              indent: screenWidth * 0.15,
              endIndent: screenWidth * 0.15,
            ),
          ],
        ],
      ),
    );
  }
}

// Shimmer for product image
class ShimmerProductImage extends StatelessWidget {
  const ShimmerProductImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }
}

// Error widget for product image
class ImageErrorWidget extends StatelessWidget {
  const ImageErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.error_outline, size: 40, color: Colors.red),
      ),
    );
  }
}
