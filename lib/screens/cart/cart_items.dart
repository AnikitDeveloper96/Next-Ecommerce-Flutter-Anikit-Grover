// lib/screens/cart/cart_items.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nextecommerceapp/routes.dart'; // Import your routes file

import '../../blocs/bloc_event/cart_event.dart';
import '../../blocs/bloc_state/cart_state.dart';
import '../../blocs/blocs/cart_bloc.dart';
import '../../models/cartModel.dart'; // Ensure CartModelForCheckout is accessible

class CartItems extends StatefulWidget {
  const CartItems({super.key});

  @override
  State<CartItems> createState() => _CartItemsState();
}

class _CartItemsState extends State<CartItems> {
  // Declare ScrollControllers for each scrollable widget
  final ScrollController _mainCartScrollController = ScrollController();
  final ScrollController _billItemsScrollController = ScrollController();

  @override
  void dispose() {
    _mainCartScrollController.dispose();
    _billItemsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold from here, as MainHomePage provides it
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartInitialState || state is CartLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CartErrorState) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is CartUpdatedItemsState) {
          final cartItems = state.cartItems;

          if (cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start adding some amazing products.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Calculate bill details
          double itemsTotal = 0.0;
          int totalQuantity = 0;
          const double deliveryFee = 5.00; // Example delivery fee
          const double taxRate = 0.08; // Example 8% tax

          for (var item in cartItems) {
            itemsTotal += (item.product.price ?? 0.0) * item.productQuantity;
            totalQuantity += item.productQuantity;
          }

          final double taxAmount = itemsTotal * taxRate;
          final double grandTotal = itemsTotal + deliveryFee + taxAmount;

          return Column(
            children: [
              Expanded(
                // Scrollbar for the main list of cart items
                child: Scrollbar(
                  controller:
                      _mainCartScrollController, // Assign unique controller
                  thumbVisibility: true, // Always show the scroll thumb
                  interactive: true, // Make the thumb interactive
                  child: ListView.builder(
                    controller:
                        _mainCartScrollController, // Assign unique controller
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: item.product.images?.first ?? '',
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item.product.price?.toStringAsFixed(2) ?? '0.00'}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Quantity controls
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  context.read<CartBloc>().add(
                                                    UpdateCartItemsEvent(
                                                      item.product,
                                                      -1,
                                                    ),
                                                  );
                                                },
                                              ),
                                              Text(
                                                '${item.productQuantity}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  context.read<CartBloc>().add(
                                                    UpdateCartItemsEvent(
                                                      item.product,
                                                      1,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Remove button
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            context.read<CartBloc>().add(
                                              RemoveFromCartItemsEvent(
                                                item.product,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Bill Details Section as ExpansionTile
              _buildBillDetailsExpansionTile(
                itemsTotal: itemsTotal,
                deliveryFee: deliveryFee,
                taxAmount: taxAmount,
                grandTotal: grandTotal,
                totalQuantity: totalQuantity,
                cartItems: cartItems, // Pass cartItems to show in bill details
                billItemsScrollController:
                    _billItemsScrollController, // Pass unique controller
              ),
              // Checkout Button
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        NextEcommerceAppRoutes.checkoutscreen,
                        arguments: {
                          'cartItems': cartItems,
                          'totalQuantity': totalQuantity,
                          'totalPrice': grandTotal,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 16.0,
                      ),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink(); // Fallback for other states not handled explicitly
      },
    );
  }

  // Widget to build the bill details as an ExpansionTile
  Widget _buildBillDetailsExpansionTile({
    required double itemsTotal,
    required double deliveryFee,
    required double taxAmount,
    required double grandTotal,
    required int totalQuantity,
    required List<CartModelForCheckout> cartItems, // Added cartItems parameter
    required ScrollController
    billItemsScrollController, // Added controller parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isExpanded = false; // Initial state for the icon

            return ExpansionTile(
              initiallyExpanded: false, // Collapsed by default to save space
              title: Text(
                'Bill Details ($totalQuantity items)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.black, // You can customize the color
              ),
              onExpansionChanged: (bool expanded) {
                setState(() {
                  isExpanded = expanded;
                });
              },
              childrenPadding: const EdgeInsets.all(16.0),
              children: [
                // List of items within bill details with its own scrollbar
                const Text(
                  'Items in this order:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        cartItems.length > 3 ? 150.0 : cartItems.length * 50.0,
                  ), // Dynamic height for list
                  child: Scrollbar(
                    controller:
                        billItemsScrollController, // Assign unique controller
                    thumbVisibility: true,
                    interactive: true,
                    child: ListView.builder(
                      controller:
                          billItemsScrollController, // Assign unique controller
                      shrinkWrap: true, // Important for nested ListView
                      physics:
                          const ClampingScrollPhysics(), // Important for nested ListView
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productQuantity} x ${item.product.title ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '\$${((item.product.price ?? 0.0) * item.productQuantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(height: 20, thickness: 1),
                _buildBillRow('Items Total', itemsTotal),
                const SizedBox(height: 8),
                _buildBillRow('Delivery Fee', deliveryFee),
                const SizedBox(height: 8),
                _buildBillRow('Taxes', taxAmount),
                const Divider(height: 20, thickness: 1),
                _buildBillRow(
                  'Grand Total',
                  grandTotal,
                  isBold: true,
                  valueColor: Colors.green,
                  valueSize: 20,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper widget for bill rows
  Widget _buildBillRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? valueColor,
    double valueSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 17 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.black87,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? (isBold ? Colors.black : Colors.black87),
          ),
        ),
      ],
    );
  }

  // Confirmation dialog for clearing the cart
  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear Cart?'),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(ClearCartItemsEvent());
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Cart cleared!')));
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
