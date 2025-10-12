import 'package:flutter/material.dart';
import '../../screens/common/home.dart';
import '../../screens/common/search.dart';
import '../../screens/common/cart.dart';
import '../../screens/common/orders.dart';
import '../../screens/common/profile.dart';

class NavFooter extends StatefulWidget {
  final int initialIndex;
  const NavFooter({super.key, this.initialIndex = 0});

  @override
  State<NavFooter> createState() => _NavFooterState();
}

class _NavFooterState extends State<NavFooter> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (_selectedIndex == index) return;

        setState(() {
          _selectedIndex = index;
        });

        Widget destination;
        switch (index) {
          case 0:
            destination = Home(key: UniqueKey());
            break;
          case 1:
            destination = SearchScreen(key: UniqueKey());
            break;
          case 2:
            destination = CartScreen(key: UniqueKey());
            break;
          case 3:
            destination = OrdersScreen(key: UniqueKey());
            break;
          case 4:
            destination = ProfileScreen(key: UniqueKey());
            break;
          default:
            return;
        }

        // Defer navigation to next frame to avoid layout conflicts
        final navigator = Navigator.of(context);
        Future.microtask(() {
          if (!mounted) return;
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (_) => destination,
            ),
          );
        });
      },
    );
  }
}