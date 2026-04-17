import 'package:flutter/material.dart';
import 'package:frontend/features/venue/presentation/pages/venue_discovery_page.dart';
import 'package:frontend/features/subscription/presentation/pages/subscription_page.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  List<Widget> get _pages {
    return const [
      VenueDiscoveryPage(),
      ProfilePage(),
    ];
  }

  List<NavigationDestination> get _destinations {
    return const [
      NavigationDestination(
        icon: Icon(Icons.search),
        label: 'Discover',
      ),
      NavigationDestination(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionPage()),
              );
            },
            icon: const Icon(Icons.star),
            label: const Text('Become an Owner'),
          )
        : null,
    );
  }
}
