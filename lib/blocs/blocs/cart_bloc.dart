import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextecommerceapp/blocs/bloc_event/cart_event.dart';
import 'package:nextecommerceapp/blocs/bloc_state/cart_state.dart';
import 'package:nextecommerceapp/screens/db_firestore/ecommerce_db_firestore.dart';
import '../../models/cartModel.dart';
import '../../models/product_model.dart'; // Ensure Product is imported if needed for type hints

class CartBloc extends Bloc<NextEcommerceCartsEvent, CartState> {
  final NextEcommerceDatabase _database = NextEcommerceDatabase();
  List<CartModelForCheckout> cartItems =
      []; // This now represents the synced cart

  CartBloc() : super(CartInitialState()) {
    // Initial load happens here. The state starts as CartInitialState
    // and then transitions to CartLoadingState, then CartUpdatedItemsState or CartErrorState.
    _loadInitialCart();

    on<CartInitialEvent>(_onCartInitial);
    on<AddtoCartItemsEvent>(_onAddToCartItems);
    on<RemoveFromCartItemsEvent>(_onRemoveFromCartItems);
    on<UpdateCartItemsEvent>(_onUpdateCartItems);
    on<ClearCartItemsEvent>(_onClearCartItems);
  }

  /// Loads the initial cart items from the database when the BLoC is created.
  /// Emits `CartLoadingState` and then `CartUpdatedItemsState` or `CartErrorState`.
  Future<void> _loadInitialCart() async {
    try {
      emit(CartLoadingState()); // Indicate loading
      final fetchedCartItems = await _database.getCartItems();
      cartItems = fetchedCartItems;
      emit(CartUpdatedItemsState(List.from(cartItems)));
    } catch (e) {
      print('Error loading initial cart: $e');
      emit(
        CartErrorState('Failed to load cart items: $e'),
      ); // Emit an error state
    }
  }

  /// Handles the `CartInitialEvent` by re-loading the cart.
  /// This is typically used for a manual refresh or after a severe error.
  Future<void> _onCartInitial(
    CartInitialEvent event,
    Emitter<CartState> emit,
  ) async {
    await _loadInitialCart();
  }

  /// Handles adding a product to the cart.
  /// Optimistically updates the UI and then syncs with Firebase.
  /// If Firebase sync fails, it reverts the UI by re-loading the cart.
  Future<void> _onAddToCartItems(
    AddtoCartItemsEvent event,
    Emitter<CartState> emit,
  ) async {
    // Store current state for potential rollback
    final List<CartModelForCheckout> previousCartItems = List.from(cartItems);

    try {
      // Optimistically update UI
      final existingProductIndex = cartItems.indexWhere(
        (item) => item.product.id == event.product.id,
      );

      if (existingProductIndex == -1) {
        cartItems.add(
          CartModelForCheckout(product: event.product, productQuantity: 1),
        );
      } else {
        // Create a new instance to ensure state immutability
        final updatedItem = CartModelForCheckout(
          product: cartItems[existingProductIndex].product,
          productQuantity: cartItems[existingProductIndex].productQuantity + 1,
        );
        cartItems[existingProductIndex] = updatedItem;
      }
      emit(
        CartUpdatedItemsState(List.from(cartItems)),
      ); // Emit the updated state

      // Sync with Firebase
      await _database.addToCart(event.product, 1);
    } catch (e) {
      print('Failed to add to cart in Firebase: $e');
      // Revert UI to previous state and then try to reload from Firebase
      cartItems = previousCartItems;
      emit(CartErrorState('Failed to add item to cart: $e'));
      await _loadInitialCart(); // Revert UI by re-loading from Firebase
    }
  }

  /// Handles removing a product from the cart.
  /// Optimistically updates the UI and then syncs with Firebase.
  /// If Firebase sync fails, it reverts the UI by re-loading the cart.
  Future<void> _onRemoveFromCartItems(
    RemoveFromCartItemsEvent event,
    Emitter<CartState> emit,
  ) async {
    final List<CartModelForCheckout> previousCartItems = List.from(cartItems);

    try {
      // Optimistically update UI
      cartItems.removeWhere((item) => item.product.id == event.product.id);
      emit(CartUpdatedItemsState(List.from(cartItems)));

      // Sync with Firebase
      await _database.removeFromCart(event.product);
    } catch (e) {
      print('Failed to remove from cart in Firebase: $e');
      cartItems = previousCartItems; // Revert
      emit(CartErrorState('Failed to remove item from cart: $e'));
      await _loadInitialCart(); // Revert on error
    }
  }

  /// Handles updating the quantity of a product in the cart.
  /// Optimistically updates the UI and then syncs with Firebase.
  /// If Firebase sync fails, it reverts the UI by re-loading the cart.
  Future<void> _onUpdateCartItems(
    UpdateCartItemsEvent event,
    Emitter<CartState> emit,
  ) async {
    final List<CartModelForCheckout> previousCartItems = List.from(cartItems);

    try {
      // Optimistically update UI
      final existingProductIndex = cartItems.indexWhere(
        (item) => item.product.id == event.product.id,
      );

      if (existingProductIndex != -1) {
        final newQuantity =
            cartItems[existingProductIndex].productQuantity +
            event.quantityChange;

        if (newQuantity <= 0) {
          cartItems.removeAt(existingProductIndex);
        } else {
          // Create a new instance for immutability
          final updatedItem = CartModelForCheckout(
            product: cartItems[existingProductIndex].product,
            productQuantity: newQuantity,
          );
          cartItems[existingProductIndex] = updatedItem;
        }
      } else if (event.quantityChange > 0) {
        // If product didn't exist in local list but we are adding, add it
        cartItems.add(
          CartModelForCheckout(
            product: event.product,
            productQuantity: event.quantityChange,
          ),
        );
      }
      emit(CartUpdatedItemsState(List.from(cartItems)));

      // Sync with Firebase
      await _database.updateCartItemQuantity(
        event.product,
        event.quantityChange,
      );
    } catch (e) {
      print('Failed to update cart item quantity in Firebase: $e');
      cartItems = previousCartItems; // Revert
      emit(CartErrorState('Failed to update cart item quantity: $e'));
      await _loadInitialCart(); // Revert on error
    }
  }

  /// Handles clearing all items from the cart.
  /// Optimistically updates the UI.
  /// Then attempts to clear from Firebase.
  Future<void> _onClearCartItems(
    ClearCartItemsEvent event,
    Emitter<CartState> emit,
  ) async {
    final List<CartModelForCheckout> previousCartItems = List.from(cartItems);

    try {
      // Optimistically update UI
      cartItems.clear();
      emit(CartUpdatedItemsState(List.from(cartItems)));

      // Implement actual clearing of all items in Firebase
      final userId = _database.getCurrentUser()?.uid;
      if (userId != null) {
        final cartCollection = _database
            .getFirebaseFirestoreInstance()
            .collection('users')
            .doc(userId)
            .collection('cart');

        final snapshot = await cartCollection.get();
        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }
        print('All cart items cleared from Firebase for user $userId.');
      } else {
        print('User not logged in. Cannot clear cart in Firebase.');
      }
    } catch (e) {
      print('Failed to clear cart in Firebase: $e');
      cartItems = previousCartItems; // Revert
      emit(CartErrorState('Failed to clear cart: $e'));
      await _loadInitialCart(); // Revert on error
    }
  }
}
