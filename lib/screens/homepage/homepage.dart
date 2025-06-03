import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextecommerceapp/blocs/bloc_event/favourite_event.dart';
import 'package:nextecommerceapp/models/product_model.dart' show Product;
import 'package:nextecommerceapp/widgets/product_grid.dart';
import '../../blocs/bloc_state/product_state.dart';
import '../../blocs/blocs/bloc_homepage.dart';
import '../../constant/assets_images.dart';
import '../../constant/textstyle.dart';
import '../../routes.dart' show NextEcommerceAppRoutes;
import '../../widgets/animation.dart';
import '../../blocs/blocs/fav_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../blocs/bloc_state/fav_state.dart';

class MyHomePage extends StatefulWidget {
  final User? user;
  const MyHomePage({super.key, this.user});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NextEcommerceAppTextStyles textStyles = NextEcommerceAppTextStyles();
  final List<String> bannerImages = [
    NextEcommerceAssetImages().bannerOneHomepage,
    NextEcommerceAssetImages().bannertwoHomepage,
  ];
  int _currentImageIndex = 0;

  void _goToNextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % bannerImages.length;
    });
  }

  void _goToPreviousImage() {
    setState(() {
      if (_currentImageIndex > 0) _currentImageIndex--;
    });
  }

  String capitalizeFirstLetter(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) => FavoriteProductBloc()..add(LoadFavorites()),
      child: Scaffold(
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return _buildShimmerLoading(screenWidth, screenHeight);
            } else if (state is ProductLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBannerSection(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.02),
                      _buildSectionTitle("Shop by Categories"),
                      SizedBox(height: screenHeight * 0.02),
                      _buildCategoryGrid(
                        state.products,
                        screenWidth,
                        screenHeight,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildSectionTitle("New Arrivals"),
                      SizedBox(height: screenHeight * 0.02),
                      state.products.isEmpty
                          ? const Center(
                            child: Text(
                              'No products found.',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                          : ProductGrid(
                            products: state.products,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            isFavoritesScreen: false,
                            isHomeScreen: true,
                            isSearchScreen: false,
                          ),
                    ],
                  ),
                ),
              );
            } else if (state is ProductError) {
              return const Center(child: Text("Failed to load products"));
            } else {
              return const Center(child: Text('No products found.'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(double screenWidth, double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBanner(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: screenWidth * 0.4,
                height: 20,
                color: Colors.white,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildShimmerCategoryGrid(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: screenWidth * 0.4,
                height: 20,
                color: Colors.white,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildShimmerProductGrid(screenWidth, screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBanner(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth,
      height: screenHeight * 0.25,
      color: Colors.white,
    );
  }

  Widget _buildShimmerCategoryGrid(double screenWidth, double screenHeight) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 600 ? 3 : 2,
        mainAxisSpacing: screenHeight * 0.02,
        crossAxisSpacing: screenWidth * 0.02,
        childAspectRatio: 1.5,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildShimmerProductGrid(double screenWidth, double screenHeight) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: screenHeight * 0.02,
        crossAxisSpacing: screenWidth * 0.02,
        childAspectRatio: 0.7,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(color: Colors.white);
      },
    );
  }

  Widget _buildBannerSection(double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.25,
      child: Stack(
        children: [
          BannerAnimation(
            imagePath: bannerImages[_currentImageIndex],
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: Container(
              color: Colors.white.withOpacity(0.5),
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Text(
                "This\nseason’s\nlatest",
                style: NextEcommerceAppTextStyles.bannerText,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          if (_currentImageIndex > 0)
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.1,
              child: GestureDetector(
                onTap: _goToPreviousImage,
                child: _buildArrowIcon(Icons.arrow_back, screenWidth),
              ),
            ),
          Positioned(
            right: screenWidth * 0.05,
            top: screenHeight * 0.1,
            child: GestureDetector(
              onTap: _goToNextImage,
              child: _buildArrowIcon(Icons.arrow_forward, screenWidth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowIcon(IconData icon, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.6),
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Icon(icon, color: Colors.white, size: screenWidth * 0.08),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: NextEcommerceAppTextStyles.headerText);
  }

  final List<String> categoryImages = [
    NextEcommerceAssetImages().categoryOne,
    NextEcommerceAssetImages().categoryTwo,
    NextEcommerceAssetImages().categoryThree,
    NextEcommerceAssetImages().categoryFour,
  ];

  Widget _buildCategoryGrid(
    List<Product> products,
    double screenWidth,
    double screenHeight,
  ) {
    final categories =
        products
            .map((product) => product.category)
            .whereType<String>()
            .toSet()
            .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 600 ? 3 : 2,
        mainAxisSpacing: screenHeight * 0.02,
        crossAxisSpacing: screenWidth * 0.02,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final categoryProducts =
            products
                .where((product) => product.category == categories[index])
                .toList();

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
              categoryProducts.isEmpty
                  ? Container()
                  : Navigator.pushNamed(
                    context,
                    NextEcommerceAppRoutes.categoryProductDetailScreen,
                    arguments: {
                      'categoryName': categories[index],
                      'categoryProducts': [categoryProducts],
                    },
                  );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                image: DecorationImage(
                  image: AssetImage(
                    categoryImages[index % categoryImages.length],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  color: Colors.black54,
                ),
                child: Center(
                  child: Text(
                    capitalizeFirstLetter(categories[index]),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// class _ProductGridInternal extends StatelessWidget {
//   final List<Product> products;
//   final double screenWidth;
//   final double screenHeight;
//   final bool isFavoritesScreen;
//   final bool isSearchScreen;
//   final bool isHomeScreen;

//   const _ProductGridInternal({
//     Key? key,
//     required this.products,
//     required this.screenWidth,
//     required this.screenHeight,
//     this.isFavoritesScreen = false,
//     this.isSearchScreen = false,
//     this.isHomeScreen = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: screenWidth > 600 ? 3 : 2,
//         mainAxisSpacing: screenHeight * 0.02,
//         crossAxisSpacing: screenWidth * 0.02,
//         childAspectRatio: isHomeScreen ? 0.6 : (screenWidth > 600 ? 0.75 : 0.7),
//       ),
//       itemCount: products.length,
//       itemBuilder: (context, index) {
//         var product = products[index];
//         return _buildProductCard(
//           context,
//           product,
//           screenWidth,
//           screenHeight,
//           isSearchScreen: isSearchScreen,
//           isFavoritesScreen: isFavoritesScreen,
//           isHomeScreen: isHomeScreen,
//         );
//       },
//     );
//   }

//   Widget _buildProductCard(
//     BuildContext context,
//     Product product,
//     double screenWidth,
//     double screenHeight, {
//     bool isSearchScreen = false,
//     bool isFavoritesScreen = false,
//     bool isHomeScreen = false,
//   }) {
//     return TweenAnimationBuilder(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: const Duration(milliseconds: 300),
//       builder: (context, double value, child) {
//         return Transform.scale(
//           scale: value,
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: GestureDetector(
//         onTap: () {
//           Navigator.pushNamed(
//             context,
//             NextEcommerceAppRoutes.productDetailScreen,
//             arguments: product,
//           );
//         },
//         child: Card(
//           color: Colors.grey[200],
//           clipBehavior: Clip.antiAlias,
//           elevation: 6.0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Stack(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildProductImage(
//                     product,
//                     screenHeight,
//                     isSearchScreen,
//                     isFavoritesScreen,
//                   ),
//                   _buildProductDetails(
//                     context,
//                     product,
//                     screenWidth,
//                     screenHeight,
//                     isSearchScreen: isSearchScreen,
//                     isFavoritesScreen: isFavoritesScreen,
//                     isHomeScreen: isHomeScreen,
//                   ),
//                 ],
//               ),
//               if (!isSearchScreen)
//                 Positioned(
//                   top: 10.0,
//                   right: 10.0,
//                   child: _buildFavoriteButton(product),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductImage(
//     Product product,
//     double screenHeight,
//     bool isSearchScreen,
//     bool isFavoritesScreen,
//   ) {
//     double imageHeight =
//         screenHeight * (isSearchScreen || isFavoritesScreen ? 0.25 : 0.2);
//     return SizedBox(
//       height: imageHeight,
//       child: ClipRRect(
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//         child: CachedNetworkImage(
//           imageUrl: product.images?.first ?? "",
//           fit: BoxFit.cover,
//           placeholder: (_, __) => const ShimmerProductImage(),
//           errorWidget: (_, __, ___) => const ImageErrorWidget(),
//         ),
//       ),
//     );
//   }

//   // >>>>>> THIS IS THE CRITICAL PART FOR THE FIX <<<<<<
//   Widget _buildFavoriteButton(Product product) {
//     return BlocBuilder<FavoriteProductBloc, FavouriteProductState>(
//       builder: (context, favState) {
//         // Now favState is correctly typed as FavouriteProductState
//         bool isFavorite = favState.favoriteItems.any(
//           (item) => item.id == product.id,
//         );

//         return GestureDetector(
//           onTap: () {
//             context.read<FavoriteProductBloc>().add(
//               isFavorite
//                   ? RemoveFromFavorites(product)
//                   : AddToFavorites(product),
//             );
//           },
//           child: CircleAvatar(
//             radius: 20,
//             backgroundColor: Colors.white.withOpacity(0.8),
//             child: Icon(
//               isFavorite ? Icons.favorite : Icons.favorite_border,
//               color: isFavorite ? Colors.red : Colors.grey[600],
//               size: 24,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProductDetails(
//     BuildContext context,
//     Product product,
//     double screenWidth,
//     double screenHeight, {
//     bool isSearchScreen = false,
//     bool isFavoritesScreen = false,
//     bool isHomeScreen = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           return ConstrainedBox(
//             constraints: BoxConstraints(maxHeight: constraints.maxHeight),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Flexible(
//                   child: Text(
//                     product.title ?? "Product Name",
//                     style: NextEcommerceAppTextStyles.producttitle.copyWith(
//                       fontSize: 14,
//                       fontWeight:
//                           isSearchScreen || isFavoritesScreen
//                               ? FontWeight.w600
//                               : FontWeight.w500,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '\$${product.price?.toStringAsFixed(2) ?? "0.00"}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 if (isHomeScreen) ...[
//                   const SizedBox(height: 40),
//                   Text(
//                     "SHOP NOW",
//                     style: NextEcommerceAppTextStyles.shopnow.copyWith(
//                       fontSize: 12,
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.01),
//                   Divider(
//                     color: Colors.black,
//                     thickness: 1,
//                     indent: screenWidth * 0.15,
//                     endIndent: screenWidth * 0.15,
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

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
