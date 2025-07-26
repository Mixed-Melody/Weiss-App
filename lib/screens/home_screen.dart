import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'card_list_screen.dart';
import 'trial_deck_list_screen.dart';
import 'wishlist_screen.dart';

/// The top-level navigation screen containing tabs for dashboard, cards,
/// trial decks and wishlist.  Uses a [BottomNavigationBar] for simple
/// navigation on desktop.  For more sophisticated layouts consider using
/// [NavigationRail] when wider screens are detected.  TODO: Research
/// modern desktop navigation paradigms and adjust accordingly.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static final List<Widget> _screens = [
    const DashboardScreen(),
    const CardListScreen(),
    const TrialDeckListScreen(),
    const WishlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Cards'),
          BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark), label: 'Decks'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
        ],
      ),
    );
  }
}