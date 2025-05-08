import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'search_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final tabs = [const SearchScreen(), const HistoryScreen()];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reverse Lookup'),
        actions: [
          if (auth.isLoggedIn) ...[
            IconButton(icon: const Icon(Icons.logout), onPressed: auth.signOut),
          ] else ...[
            IconButton(icon: const Icon(Icons.login), onPressed: auth.signInWithGoogle),
            IconButton(icon: const Icon(Icons.apple), onPressed: auth.signInWithApple),
          ]
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
