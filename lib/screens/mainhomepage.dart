// mainhomepage.dart - MODIFIED
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextecommerceapp/screens/homepage/favourite_screen.dart';
import 'package:nextecommerceapp/screens/homepage/homepage.dart';
import 'package:nextecommerceapp/screens/profile/profile_screen.dart';
import 'homepage/search_screen.dart';

class MainHomePage extends StatefulWidget {
  final User? user;

  const MainHomePage({super.key, this.user});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  // The _signOut method is moved to ProfileScreen
  // No explicit _signOut method needed here anymore.

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      MyHomePage(user: widget.user),
      SearchFilterPage(onThemeToggle: (_) {}), // Use SearchFilterPage
      const FavoritesScreen(),
      const Center(
        child: Text(
          "Cart",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    ];

    final List<String> _pageTitles = ["Home", "Search", "Favorites", "Cart"];
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 26.0),
          onPressed: () => Scaffold.of(context).openDrawer(),
          color: theme.iconTheme.color, // Use theme's icon color
        ),
        title: Text(
          _pageTitles[_currentIndex],
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ), // Use theme's text style
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            theme.appBarTheme.backgroundColor, // Use theme's background color
        foregroundColor:
            theme.textTheme.bodyLarge?.color, // Use theme's foreground color
        actions: [
          if (widget.user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () {
                  // Navigate to ProfileScreen when avatar is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: widget.user),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      widget.user?.photoURL != null
                          ? NetworkImage(widget.user!.photoURL!)
                          : null,
                  child:
                      widget.user?.photoURL == null
                          ? const Icon(Icons.person_rounded)
                          : null,
                ),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.user?.photoURL != null)
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(widget.user!.photoURL!),
                      onBackgroundImageError:
                          (exception, stackTrace) => const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person_rounded),
                          ),
                    )
                  else
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person_rounded),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user?.displayName ?? "Guest",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.user?.email ?? "example@email.com",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: const Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to about screen
              },
            ),
            // Removed the Sign Out ListTile from MainHomePage's drawer
            // as it's now handled in ProfileScreen
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 250,
        ), // Slightly faster animation
        child: _pages[_currentIndex],
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          ); // Add a subtle fade transition
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Material(
          // Use Material for inkwell effect and background
          elevation: 4.0,
          borderRadius: BorderRadius.circular(24.0),
          color:
              theme
                  .bottomNavigationBarTheme
                  .backgroundColor, // Use theme's color
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor:
                theme.colorScheme.secondary, // Use secondary color for emphasis
            unselectedItemColor: theme.textTheme.bodyMedium?.color?.withOpacity(
              0.6,
            ),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: "Favorites",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_rounded),
                label: "Cart",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
