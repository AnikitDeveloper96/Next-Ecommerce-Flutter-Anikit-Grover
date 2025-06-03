import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nextecommerceapp/screens/authentication/authentication.dart';
import 'package:nextecommerceapp/screens/db_firestore/ecommerce_db_firestore.dart';
import 'package:nextecommerceapp/screens/homepage/orderhistory.dart';
import 'package:nextecommerceapp/screens/onboardingscreens/onboarding_screen.dart';
import 'package:nextecommerceapp/screens/profile/pofile_shipping.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _shippingAddress;
  String? _userName;
  String? _userEmail;
  final NextEcommerceDatabase _database = NextEcommerceDatabase();

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  Future<void> _loadUserProfileData() async {
    final currentUser = widget.user ?? _database.getCurrentUser();
    if (currentUser != null) {
      final userProfile = await _database.getUserProfileData(currentUser.uid);
      setState(() {
        _userName = userProfile['userName'] ?? currentUser.displayName;
        _userEmail = userProfile['email'] ?? currentUser.email;
        _shippingAddress = userProfile['shippingAddress'];
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      if (!kIsWeb && await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(content: 'Signed out successfully.'),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Error signing out. Try again.',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback to widget.user if _userProfile is not yet loaded
    final displayUser = widget.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body:
          _userName == null || _userEmail == null
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    displayUser?.photoURL != null
                                        ? NetworkImage(
                                          displayUser!.photoURL.toString(),
                                        )
                                        : null,
                                child:
                                    displayUser?.photoURL == null
                                        ? const Icon(
                                          Icons.person_rounded,
                                          size: 40,
                                        )
                                        : null,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _userName ?? "Guest User",
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _userEmail ?? "No email",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      _shippingAddress ??
                                          "Address not set", // Display from state variable
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      _buildProfileOption(
                        context,
                        icon: Icons.local_shipping_outlined,
                        title: 'Shopping address',
                        onTap: () async {
                          final newAddress = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ShippingAddressScreen(
                                    initialAddress: _shippingAddress,
                                  ),
                            ),
                          );
                          if (newAddress != null && newAddress is String) {
                            setState(() {
                              _shippingAddress = newAddress;
                            });
                            final currentUser =
                                widget.user ?? _database.getCurrentUser();
                            if (currentUser != null) {
                              await _database.updateShippingAddress(
                                currentUser.uid,
                                newAddress,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Address updated successfully!',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildProfileOption(
                        context,
                        icon: Icons.history,
                        title: 'Order history',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      if (displayUser != null)
                        _buildProfileOption(
                          context,
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          onTap: () {
                            _signOut(context);
                          },
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A minimal placeholder for EditProfileScreen (kept as in previous turns)
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
