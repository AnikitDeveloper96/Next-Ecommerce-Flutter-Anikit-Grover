import 'dart:ui';

import 'package:flutter/material.dart';

class NextEcommerceAppTextStyles {
  // Styles for general headings and important text
  static TextStyle headerText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle subHeaderText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // Styles potentially for banners or prominent sections
  static TextStyle bannerText = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 22.0,
  );

  // Styles for product titles in listings, cart, etc.
  static TextStyle producttitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  // Styles for call-to-action buttons like "Shop Now"
  static TextStyle shopNowButton = TextStyle(
    color: Colors.black,
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
  );

  // A specific style, possibly for a large header or brand text
  static TextStyle capitalizeFirstLetter = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
  );

  // Add more specific styles as needed for your app screens (e.g., cart page)
  // static  TextStyle cartItemName = TextStyle(
  //   fontSize: 16,
  //   fontWeight: FontWeight.w500,
  //   color: Colors.black,
  // );
  // static  TextStyle cartItemPrice = TextStyle(
  //   fontSize: 15,
  //   fontWeight: FontWeight.bold,
  //   color: AppColors.firebaseOrange, // Example of using an app-specific color
  // );
  // static  TextStyle totalAmountText = TextStyle(
  //   fontSize: 20,
  //   fontWeight: FontWeight.bold,
  //   color: Colors.black,
  // );
}
