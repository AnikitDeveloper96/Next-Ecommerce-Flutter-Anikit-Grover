import 'dart:async'; // Import for StreamSubscription
import 'package:firebase_auth/firebase_auth.dart'; // Still needed if you use Firebase Auth elsewhere
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextecommerceapp/blocs/blocs/search_bloc.dart';
import 'package:nextecommerceapp/screens/onboardingscreens/onboarding_screen.dart';
import 'package:nextecommerceapp/widgets/no_internet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'blocs/bloc_event/product_homepage.dart';
import 'blocs/blocs/bloc_homepage.dart'; // Assuming this is ProductBloc
import 'blocs/blocs/cart_bloc.dart';
import 'blocs/blocs/fav_bloc.dart'; // Assuming this is FavoriteProductBloc
import 'routes.dart';

// REMOVED: import 'package:nextecommerceapp/screens/my_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _isConnected = result.any((r) => r != ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) {
            final productBloc = ProductBloc();
            if (_isConnected) {
              productBloc.add(FetchProducts());
            }
            return productBloc;
          },
        ),
        BlocProvider<FavoriteProductBloc>(
          create: (context) => FavoriteProductBloc(),
        ),
        BlocProvider<CartBloc>(create: (context) => CartBloc()),
        // BlocProvider<ProductSearchBloc>(
        //   create: (context) => ProductSearchBloc(),
        // ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: NextEcommerceAppRoutes.routes,
        home: _InitialRouter(isConnected: _isConnected),
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

// A widget to handle the initial routing decision based on connectivity
class _InitialRouter extends StatefulWidget {
  final bool isConnected;
  const _InitialRouter({Key? key, required this.isConnected}) : super(key: key);

  @override
  State<_InitialRouter> createState() => _InitialRouterState();
}

class _InitialRouterState extends State<_InitialRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToAppropriateScreen();
    });
  }

  @override
  void didUpdateWidget(covariant _InitialRouter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected) {
      _navigateToAppropriateScreen();
    }
  }

  Future<void> _navigateToAppropriateScreen() async {
    if (!mounted) return;

    if (!widget.isConnected) {
      // If not connected, always show NoInternetScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NoInternetScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      // If connected, always navigate to OnboardingScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ), // Always go to Onboarding
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget acts as a temporary loading screen or splash screen
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Show a spinner during the initial decision
      ),
    );
  }
}
