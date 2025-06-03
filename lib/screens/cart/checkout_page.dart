import 'package:flutter/material.dart';
import 'package:nextecommerceapp/models/cartModel.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedPaymentMethod;

  String shippingName = "Rosina Doe";
  String shippingAddress = "43 Oxford Road M13 4GR\nManchester, UK";
  String shippingPhone = "+234 9011039271";

  List<Map<String, String>> paymentCards = [
    {"number": "**** **** **** 1234", "bank": "VISA"},
    {"number": "**** **** **** 1456", "bank": "Mastercard"},
    {"number": "**** **** **** 4875", "bank": "Bank"},
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final List<CartModelForCheckout> cartItems = args['cartItems'];
    final int totalQuantity = args['totalQuantity'];
    final double totalPrice = args['totalPrice'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Checkout'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shipping information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'change',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShippingInfoRow(Icons.person, shippingName),
                    const SizedBox(height: 8),
                    _buildShippingInfoRow(Icons.location_on, shippingAddress),
                    const SizedBox(height: 8),
                    _buildShippingInfoRow(Icons.phone, shippingPhone),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paymentCards.length,
                    separatorBuilder:
                        (context, index) =>
                            const Divider(indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            _buildPaymentLogo(paymentCards[index]["bank"]!),
                            const SizedBox(width: 10),
                            Text(
                              paymentCards[index]["number"]!,
                              // Increased font size for better visibility
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        value: paymentCards[index]["number"]!,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        activeColor: Colors.deepPurple,
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: Colors.deepPurple),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmAndPayBottomSheet(
                    context,
                    totalPrice,
                    totalQuantity,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Changed to black
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirm and pay',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ), // Text color remains white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey.shade800)),
        ),
      ],
    );
  }

  Widget _buildPaymentLogo(String bankName) {
    Color logoColor;
    String logoText;

    switch (bankName) {
      case "VISA":
        logoColor = Colors.indigo.shade700;
        logoText = 'VISA';
        break;
      case "Mastercard":
        logoColor = Colors.red.shade700;
        logoText = 'Mastercard';
        break;
      case "Bank":
        logoColor = Colors.blueGrey.shade700;
        logoText = 'BANK';
        break;
      default:
        logoColor = Colors.grey;
        logoText = 'CARD';
    }

    return Container(
      width: 60, // Increased width
      height: 35, // Increased height
      decoration: BoxDecoration(
        color: logoColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(5.0), // Adjusted padding
          child: Text(
            logoText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14, // Increased font size
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmAndPayBottomSheet(
    BuildContext context,
    double totalPrice,
    int totalQuantity,
  ) {
    Map<String, String>? selectedCardDetails;
    if (_selectedPaymentMethod != null) {
      selectedCardDetails = paymentCards.firstWhere(
        (card) => card["number"] == _selectedPaymentMethod,
        orElse: () => {"number": "N/A", "bank": "N/A"},
      );
    } else {
      selectedCardDetails = {"number": "**** **** **** N/A", "bank": "N/A"};
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm and pay',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Products: $totalQuantity',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My credit card',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (selectedCardDetails != null)
                            _buildPaymentLogo(selectedCardDetails["bank"]!),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedCardDetails?["number"] ?? "No card selected",
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shippingName,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Text(
                            '04/25',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: Colors.deepPurple),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Further payment logic can be placed here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Changed to black
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Pay now',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ), // Text color remains white
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
