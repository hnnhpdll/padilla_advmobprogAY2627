import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'product_screen.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_text.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    this.username = '',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();
  final UserService _userService = UserService();

  String _firstName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ENHANCEMENT 3:
  // Retrieves the logged-in user's saved information
  // to display the user's first name in the Profile tab.
  Future<void> _loadUser() async {
    try {
      final userData = await _userService.getUserData();

      if (!mounted) return;

      setState(() {
        _firstName = userData['firstName'] ?? '';
      });
    } catch (e) {
      // Keep the default title if user data cannot be loaded.
      debugPrint('Failed to load user data: $e');
    }
  }

  // Logout
  Future<void> _logout() async {
    await _userService.logout();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/signin',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,

          title: (_selectedIndex == 0)
              ? Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  scale: 11.sp,
                )
              : CustomText(
                  text: (_selectedIndex == 1)
                      ? 'Cart'
                      : _firstName.isNotEmpty
                          ? _firstName
                          : 'Profile',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),

          actions: [
  IconButton(
    icon: Icon(
      Icons.logout,
      size: 24.sp,
    ),
    tooltip: 'Logout',
    onPressed: _logout,
  ),

  IconButton(
    icon: Icon(
      Icons.settings,
      size: 24.sp,
    ),
    onPressed: () =>
        Navigator.pushNamed(context, '/settings'),
  ),
],
        ),

        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,

          children: const [
            ProductScreen(),
            CartScreen(),
            ProfileScreen(),
          ],

          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),

        // Chat Floating Action Button
        // Hidden when Cart is selected.
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ChatScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.chat),
              ),

        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBar,
          currentIndex: _selectedIndex,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shop_2),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });

    _pageController.jumpToPage(value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}