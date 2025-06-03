import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextecommerceapp/blocs/bloc_event/favourite_event.dart';
import 'package:nextecommerceapp/blocs/bloc_state/fav_state.dart';
import 'package:nextecommerceapp/blocs/blocs/fav_bloc.dart';
import 'package:nextecommerceapp/widgets/product_grid.dart';
import 'package:nextecommerceapp/routes.dart'; // Import your AppRoutes for navigation

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteProductBloc()..add(LoadFavorites()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Favorites'), centerTitle: true),
        body: BlocBuilder<FavoriteProductBloc, FavouriteProductState>(
          builder: (context, state) {
            if (state is FavoriteError) {
              return Center(child: Text(state.error));
            }

            if (state is FavoriteLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final favoriteProducts = state.favoriteItems;
            if (favoriteProducts.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  // Added SingleChildScrollView for smaller screens
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder for your 3D illustration
                      // Make sure to add your image asset and declare it in pubspec.yaml
                      Image.asset(
                        'assets/images/no_favorites_illustration.png', // Replace with your actual image path
                        height: 220, // Adjust height as needed
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hit the orange button down below to Create an order',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width:
                            double.infinity, // Make the button span full width
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to your main ordering screen/homepage
                            // Make sure NextEcommerceAppRoutes.homepage or NextEcommerceAppRoutes.mainhomepage is defined in your routes.dart
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              NextEcommerceAppRoutes
                                  .homepage, // Or NextEcommerceAppRoutes.mainhomepage
                              (route) => false, // Clears the navigation stack
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blueAccent, // Blue color from the image
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Start ordering',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: ProductGrid(
                  products: favoriteProducts,
                  screenWidth: MediaQuery.of(context).size.width,
                  screenHeight: MediaQuery.of(context).size.height,
                  isFavoritesScreen: true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
