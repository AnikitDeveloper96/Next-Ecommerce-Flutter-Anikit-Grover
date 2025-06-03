import '../../models/cartModel.dart';

abstract class CartState {
  // Added for equatable if using, otherwise remove
  List<Object> get props => [];
}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {} // New state for explicit loading

class CartUpdatedItemsState extends CartState {
  final List<CartModelForCheckout> cartItems;

  CartUpdatedItemsState(this.cartItems);

  @override
  List<Object> get props => [cartItems]; // Added for equatable if using
}

class CartErrorState extends CartState {
  final String message;
  CartErrorState(this.message);

  @override
  List<Object> get props => [message]; // Added for equatable if using
}
