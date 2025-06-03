import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import for BlocProvider.of
import 'package:shimmer/shimmer.dart'; // Add shimmer import
import 'package:nextecommerceapp/blocs/bloc_event/favourite_event.dart'; // Import favorite events
import 'package:nextecommerceapp/blocs/bloc_state/fav_state.dart';
import 'package:nextecommerceapp/blocs/blocs/fav_bloc.dart'; // Import your FavoriteProductBloc
import 'package:nextecommerceapp/routes.dart';
import '../../constant/colors.dart';
import '../../constant/textstyle.dart';
import '../../models/product_model.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String categoryName = args['categoryName'] as String;
    final List<List<Product>> categoryProducts =
        args['categoryProducts'] as List<List<Product>>;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          capitalizeFirstLetter(categoryName),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body:
          categoryProducts.isEmpty
              ? const Center(
                child: Text(
                  'No products found.',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: categoryProducts.length,
                itemBuilder: (context, index) {
                  final products = categoryProducts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: screenWidth > 600 ? 3 : 2,
                                mainAxisSpacing: screenHeight * 0.03,
                                crossAxisSpacing: screenWidth * 0.04,
                                childAspectRatio:
                                    screenWidth > 600
                                        ? 0.75
                                        : 0.7, // Adjusted aspect ratio
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCardForCategory(
                              // Renamed to avoid confusion
                              context,
                              products[index],
                              screenWidth,
                              screenHeight,
                            );
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  // Moved _buildProductCardForCategory from ProductGrid and modified for category screen
  Widget _buildProductCardForCategory(
    BuildContext context,
    Product product,
    double screenWidth,
    double screenHeight,
  ) {
    return Card(
      color: greyColor,
      clipBehavior: Clip.antiAlias,
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            NextEcommerceAppRoutes.productDetailScreen,
            arguments: product, // Pass Product directly
          );
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProductImageForCategory(
                  // Helper for image
                  product,
                  screenHeight,
                ),
                _buildProductDetailsForCategory(
                  // Helper for details
                  context,
                  product,
                  screenWidth,
                  screenHeight,
                ),
              ],
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: GestureDetector(
                onTap: () {
                  final favoriteBloc = BlocProvider.of<FavoriteProductBloc>(
                    context,
                  );
                  final isFavorite = favoriteBloc.state.favoriteItems.contains(
                    product,
                  );
                  favoriteBloc.add(
                    isFavorite
                        ? RemoveFromFavorites(product)
                        : AddToFavorites(product),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white70,
                  child:
                      BlocBuilder<FavoriteProductBloc, FavouriteProductState>(
                        builder: (context, favState) {
                          final isFavorite = favState.favoriteItems.contains(
                            product,
                          );
                          return Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.black : Colors.grey[600],
                            size: 22,
                          );
                        },
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for product image in category screen
  Widget _buildProductImageForCategory(Product product, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.2,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        child: CachedNetworkImage(
          imageUrl: product.images?.first ?? "",
          fit: BoxFit.cover,
          placeholder:
              (_, __) => const ShimmerProductImage(), // Re-use Shimmer widget
          errorWidget:
              (_, __, ___) => const ImageErrorWidget(), // Re-use Error widget
        ),
      ),
    );
  }

  // Helper function for product details in category screen
  Widget _buildProductDetailsForCategory(
    BuildContext context,
    Product product,
    double screenWidth,
    double screenHeight,
  ) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            child: Text(
              product.title ?? "Product Name",
              style: NextEcommerceAppTextStyles.producttitle.copyWith(
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price?.toStringAsFixed(2) ?? "0.00"}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // "SHOP NOW" and Divider are intentionally hidden here for category products
          // as per the requirement for non-home screens.
          // You can add SizedBox for spacing if needed to maintain layout consistency.
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

// Re-using ShimmerProductImage and ImageErrorWidget from ProductGrid
// Make sure these are accessible (e.g., in a common widgets file, or copy-pasted here)
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
