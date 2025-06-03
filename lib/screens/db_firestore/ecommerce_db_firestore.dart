import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextecommerceapp/models/product_model.dart';
import '../../models/cartModel.dart';

class NextEcommerceDatabase {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Add this getter
  FirebaseFirestore getFirebaseFirestoreInstance() {
    return _firebaseFirestore;
  }

  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>> _getUserCartCollection(
    String userId,
  ) {
    return _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection("cart");
  }

  CollectionReference<Map<String, dynamic>> _getUserFavoritesCollection(
    String userId,
  ) {
    return _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection("favourites");
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  // --- User Profile Data Handling ---

  Future<Map<String, dynamic>> getUserProfileData(String userId) async {
    try {
      final docSnapshot =
          await _firebaseFirestore.collection('users').doc(userId).get();
      return docSnapshot.data() ?? {};
    } catch (e) {
      print('Error getting user profile data: $e');
      return {};
    }
  }

  Future<void> updateShippingAddress(
    String userId,
    String newShippingAddress,
  ) async {
    try {
      await _firebaseFirestore.collection('users').doc(userId).set(
        {'shippingAddress': newShippingAddress},
        SetOptions(merge: true), // Use merge to update specific fields
      );
      print('Shipping address updated for user $userId.');
    } catch (e) {
      print('Error updating shipping address: $e');
      rethrow;
    }
  }

  Future<void> saveUserProfileInitialData(User user) async {
    try {
      final userDocRef = _firebaseFirestore.collection('users').doc(user.uid);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        await userDocRef.set({
          'userName': user.displayName,
          'email': user.email,
          'uid': user.uid,
          'shippingAddress': null, // Initialize with null or empty string
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Initial user profile data saved for ${user.uid}');
      } else {
        // Optionally update existing profile with current Firebase user data if needed
        await userDocRef.update({
          'userName': user.displayName,
          'email': user.email,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('User profile data updated for existing user ${user.uid}');
      }
    } catch (e) {
      print('Error saving initial user profile data: $e');
      rethrow;
    }
  }

  // --- Existing Methods ---

  Future<void> addToCart(Product product, int quantity) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User not logged in. Cannot add to cart.');
    }

    try {
      final productDocRef = _getUserCartCollection(
        userId,
      ).doc(product.id.toString());
      final existingProduct = await productDocRef.get();

      if (existingProduct.exists) {
        await productDocRef.update({
          'productQuantity': FieldValue.increment(quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print(
          'Product quantity updated in cart: ${product.id}. New quantity added: $quantity.',
        );
      } else {
        await productDocRef.set({
          'product': product.toJson(),
          'productQuantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Product added to cart: ${product.id} with quantity: $quantity.');
      }
    } catch (e) {
      print('Failed to add product to cart: $e');
      rethrow;
    }
  }

  Future<void> updateCartItemQuantity(
    Product product,
    int quantityChange,
  ) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User not logged in. Cannot update cart.');
    }

    try {
      final productDocRef = _getUserCartCollection(
        userId,
      ).doc(product.id.toString());
      final existingProduct = await productDocRef.get();

      if (existingProduct.exists) {
        int currentQuantity =
            (existingProduct.data()?['productQuantity'] as int?) ?? 0;
        int newQuantity = currentQuantity + quantityChange;

        if (newQuantity <= 0) {
          await productDocRef.delete();
          print(
            'Product removed from cart: ${product.id} due to quantity becoming zero or less.',
          );
        } else {
          await productDocRef.update({
            'productQuantity': newQuantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print(
            'Product quantity updated in cart: ${product.id} to $newQuantity.',
          );
        }
      } else {
        if (quantityChange > 0) {
          await productDocRef.set({
            'product': product.toJson(),
            'productQuantity': quantityChange,
            'addedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print(
            'Product added to cart with initial quantity $quantityChange: ${product.id}',
          );
        } else {
          print(
            'Attempted to update a non-existent product in cart with a non-positive quantity change: ${product.id}. No action taken.',
          );
        }
      }
    } catch (e) {
      print('Failed to update cart item quantity: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(Product product) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User not logged in. Cannot remove from cart.');
    }

    try {
      await _getUserCartCollection(userId).doc(product.id.toString()).delete();
      print('Product removed from cart: ${product.id}.');
    } catch (e) {
      print('Failed to remove product from cart: $e');
      rethrow;
    }
  }

  Future<List<CartModelForCheckout>> getCartItems() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      print('User not logged in. Returning empty cart items.');
      return [];
    }

    try {
      final querySnapshot = await _getUserCartCollection(userId).get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final productData = data['product'] as Map<String, dynamic>?;
            final quantity = data['productQuantity'] as int? ?? 0;

            if (productData == null) {
              print(
                'Warning: Cart item document ${doc.id} is missing product data. Skipping.',
              );
              return null;
            }

            try {
              final product = Product.fromJson(productData);
              return CartModelForCheckout(
                product: product,
                productQuantity: quantity,
              );
            } catch (e) {
              print(
                'Warning: Failed to parse Product from cart item ${doc.id}: $e. Skipping.',
              );
              return null;
            }
          })
          .whereType<CartModelForCheckout>()
          .where((item) => item.productQuantity > 0)
          .toList();
    } catch (e) {
      print('Failed to get cart items: $e');
      rethrow;
    }
  }

  Future<void> addToFavorites(Product product) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User not logged in. Cannot add to favorites.');
    }

    try {
      final productDocRef = _getUserFavoritesCollection(
        userId,
      ).doc(product.id.toString());
      final existingProduct = await productDocRef.get();

      if (existingProduct.exists) {
        print('Product ${product.id} is already in favorites.');
        return;
      }
      await productDocRef.set(product.toJson());
      print('Product added to favorites: ${product.id}.');
    } catch (e) {
      print('Failed to add product to favorites: $e');
      rethrow;
    }
  }

  Future<void> removeFromFavorites(Product product) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User not logged in. Cannot remove from favorites.');
    }

    try {
      await _getUserFavoritesCollection(
        userId,
      ).doc(product.id.toString()).delete();
      print('Product removed from favorites: ${product.id}.');
    } catch (e) {
      print('Failed to remove product from favorites: $e');
      rethrow;
    }
  }

  Future<List<Product>> getFavoriteProducts() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      print('User not logged in. Returning empty favorites.');
      return [];
    }

    try {
      final querySnapshot = await _getUserFavoritesCollection(userId).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      print('Failed to load favorite products: $e');
      rethrow;
    }
  }
}
