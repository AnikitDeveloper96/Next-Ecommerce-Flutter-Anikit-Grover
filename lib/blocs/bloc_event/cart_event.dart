import '../../models/product_model.dart'; // Corrected import for Product

abstract class NextEcommerceCartsEvent {}

class CartInitialEvent extends NextEcommerceCartsEvent {}

class AddtoCartItemsEvent extends NextEcommerceCartsEvent {
  final Product product; // Renamed from cartItem to product for clarity
  AddtoCartItemsEvent(this.product);
}

class RemoveFromCartItemsEvent extends NextEcommerceCartsEvent {
  final Product product; // Renamed from cartItem to product for clarity
  RemoveFromCartItemsEvent(this.product);
}

class ClearCartItemsEvent extends NextEcommerceCartsEvent {}

class UpdateCartItemsEvent extends NextEcommerceCartsEvent {
  final Product product;
  final int
  quantityChange; // Renamed from quantity to quantityChange for clarity
  UpdateCartItemsEvent(this.product, this.quantityChange);
}

// Consider if this event is still necessary, as AddtoCartItemsEvent might cover it.
// If not needed, you can remove it.
class ItemProductAlreadyInCart extends NextEcommerceCartsEvent {
  final Product product;
  ItemProductAlreadyInCart(this.product);
}
