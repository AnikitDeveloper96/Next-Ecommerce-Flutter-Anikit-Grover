import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure you have firebase_auth in your pubspec.yaml

import 'package:nextecommerceapp/models/product_model.dart';
import 'package:nextecommerceapp/screens/cart/cart_items.dart';
import 'package:nextecommerceapp/screens/homepage/orderhistory.dart';
import 'package:nextecommerceapp/screens/homepage/product_detail_screen.dart';
import 'package:nextecommerceapp/screens/homepage/category_product_details.dart';
import 'package:nextecommerceapp/screens/cart/checkout_page.dart';
import 'package:nextecommerceapp/screens/homepage/favourite_screen.dart';
import 'package:nextecommerceapp/screens/mainhomepage.dart';
import 'package:nextecommerceapp/screens/onboardingscreens/onboarding_screen.dart';
import 'package:nextecommerceapp/screens/onboardingscreens/welcome_screen.dart';
import 'package:nextecommerceapp/screens/homepage/homepage.dart'; // lib/routes.dart - MODIFIED
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure you have firebase_auth in your pubspec.yaml

import 'package:nextecommerceapp/models/product_model.dart';
import 'package:nextecommerceapp/screens/cart/cart_items.dart';
import 'package:nextecommerceapp/screens/homepage/product_detail_screen.dart';
import 'package:nextecommerceapp/screens/homepage/category_product_details.dart';
import 'package:nextecommerceapp/screens/cart/checkout_page.dart';
import 'package:nextecommerceapp/screens/homepage/favourite_screen.dart';
import 'package:nextecommerceapp/screens/mainhomepage.dart';
import 'package:nextecommerceapp/screens/onboardingscreens/onboarding_screen.dart';
import 'package:nextecommerceapp/screens/onboardingscreens/welcome_screen.dart';
import 'package:nextecommerceapp/screens/homepage/homepage.dart';
import 'package:nextecommerceapp/screens/profile/pofile_shipping.dart';
import 'package:nextecommerceapp/screens/profile/profile_screen.dart';
import 'package:nextecommerceapp/widgets/no_internet.dart';

class NextEcommerceAppRoutes {
  static const String onboarding = "/onboardingscreen";
  static const String splashscreen =
      '/splashscreen'; // Defined but not used in routes map
  static const String mainhomepage = '/mainhomepage';
  static const String homepage = '/homepage';
  static const String welcomeScreen = "/welcomescreen";
  static const String signupScreen = '/signupscreen';
  static const String categoryProductDetailScreen =
      '/categoryProductDetailScreen';
  static const String productDetailScreen = '/productDetailScreen';
  static const String favouriteScreen = '/favouritescreen';
  static const String cartPage = '/cartpage';
  static const String searchScreen =
      '/searchScreen'; // Defined but not used in routes map
  static const String checkoutscreen =
      "/checkoutscreen"; // Route for checkout page

  // New routes added
  static const String profileScreen = '/profileScreen';
  static const String editProfileScreen = '/editProfileScreen';
  static const String shippingAddressScreen = '/shippingAddressScreen';
  static const String orderHistoryScreen = '/orderHistoryScreen';
  static const String noInternetScreen = '/noInternetScreen';

  static Map<String, WidgetBuilder> get routes => {
    onboarding: (context) => const OnboardingScreen(),
    welcomeScreen: (context) => const WelcomeScreen(),
    signupScreen:
        (context) => const Text(
          'Signup Screen Placeholder',
        ), // Assuming you have a SignupScreen
    mainhomepage:
        (context) => MainHomePage(
          // Correctly receives User argument, can be null
          user: ModalRoute.of(context)?.settings.arguments as User?,
        ),
    homepage:
        (context) => MyHomePage(
          // Correctly receives User argument, can be null
          user: ModalRoute.of(context)?.settings.arguments as User?,
        ),
    categoryProductDetailScreen: (context) => const CategoryProductsScreen(),
    productDetailScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Product) {
        return ProductDetailsScreen(product: args);
      }
      // Handle cases where product is not passed or is of wrong type
      return const Scaffold(
        body: Center(child: Text("Error: Product not found.")),
      );
    },
    favouriteScreen: (context) => const FavoritesScreen(),
    cartPage: (context) => const CartItems(),
    checkoutscreen:
        (context) =>
            const CheckoutScreen(), // The CheckoutScreen route definition
    // New routes added here
    profileScreen:
        (context) => ProfileScreen(
          user: ModalRoute.of(context)?.settings.arguments as User?,
        ),
    editProfileScreen: (context) => const EditProfileScreen(),
    shippingAddressScreen:
        (context) => ShippingAddressScreen(
          initialAddress: ModalRoute.of(context)?.settings.arguments as String?,
        ),
    orderHistoryScreen: (context) => const OrderHistoryScreen(),
    noInternetScreen: (context) => const NoInternetScreen(),
  };
}
