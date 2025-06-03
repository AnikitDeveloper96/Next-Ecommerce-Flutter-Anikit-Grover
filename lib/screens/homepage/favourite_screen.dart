// lib/screens/homepage/favourite_screen.dart
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
      // Removed Scaffold from here, as MainHomePage provides it
      child: BlocBuilder<FavoriteProductBloc, FavouriteProductState>(
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/no_favorites_illustration.png', // Replace with your actual image path
                      height: 220,
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
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            NextEcommerceAppRoutes
                                .homepage, // Or NextEcommerceAppRoutes.mainhomepage
                            (route) => false, // Clears the navigation stack
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
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
    );
  }
}
