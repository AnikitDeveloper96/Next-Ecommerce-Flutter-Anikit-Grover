// lib/models/user_profile_model.dart
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  String? shippingAddress; // Made mutable for easy updates

  UserProfileModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.shippingAddress,
  });

  // Factory constructor for creating a UserProfileModel from a map (e.g., from Firestore)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoURL: json['photoURL'] as String?,
      shippingAddress: json['shippingAddress'] as String?,
    );
  }

  // Method for converting a UserProfileModel to a map (e.g., for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'shippingAddress': shippingAddress,
    };
  }

  // Helper to create a default profile from a Firebase User object
  factory UserProfileModel.fromFirebaseUser(User user) {
    return UserProfileModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      shippingAddress: "Not set yet", // Default address for new profiles
    );
  }

  // Helper to update shipping address
  UserProfileModel copyWith({String? shippingAddress}) {
    return UserProfileModel(
      uid: uid,
      displayName: displayName,
      email: email,
      photoURL: photoURL,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }
}
