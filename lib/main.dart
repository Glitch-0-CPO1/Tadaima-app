import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/contacts_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/rides_provider.dart';
import 'screens/contacts_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/rides_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TadaimaApp());
}

/// The root of the Tadaima app: sets the app name and the shared light theme.
class TadaimaApp extends StatelessWidget {
  const TadaimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Contacts, the student profile and the ride log are loaded once when the
    // app starts and shared with every screen through Provider. `..load()`
    // kicks off reading them from storage; all providers handle missing/bad
    // data safely.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactsProvider>(
          create: (_) => ContactsProvider()..load(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider()..load(),
        ),
        ChangeNotifierProvider<RidesProvider>(
          create: (_) => RidesProvider()..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Tadaima',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _StartupRouter(),
      ),
    );
  }
}

/// Routes to onboarding or the main app based on saved state.
class _StartupRouter extends StatelessWidget {
  const _StartupRouter();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    if (!profile.isLoaded) {
      // Plain background-colored screen while loading, no timed splash.
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: SizedBox.shrink(),
      );
    }

    if (!profile.onboardingDone) {
      return const OnboardingScreen();
    }

    return const AppShell();
  }
}

/// Holds the four main tabs and the bottom navigation bar.
///
/// An [IndexedStack] keeps each tab alive so scroll position and state are not
/// lost when switching between tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  /// Index of the Contacts tab in the bottom navigation.
  static const int _contactsTabIndex = 2;
  static const int _ridesTabIndex = 1;

  static const List<NavigationDestination> _destinations =
      <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
      tooltip: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.directions_car_outlined),
      selectedIcon: Icon(Icons.directions_car),
      label: 'Rides',
      tooltip: 'Rides',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Contacts',
      tooltip: 'Contacts',
    ),
    NavigationDestination(
      icon: Icon(Icons.more_horiz),
      selectedIcon: Icon(Icons.more_horiz),
      label: 'More',
      tooltip: 'More',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Home needs a way to jump to the Contacts/Rides tabs.
    final tabs = <Widget>[
      HomeScreen(
        onOpenContacts: () => _onDestinationSelected(_contactsTabIndex),
        onOpenRides: () => _onDestinationSelected(_ridesTabIndex),
      ),
      const RidesScreen(),
      const ContactsScreen(),
      const MoreScreen(),
    ];

    final isHome = _selectedIndex == 0;
    return Scaffold(
      appBar: isHome
          ? null
          : AppBar(
              title: Text(_destinations[_selectedIndex].label),
            ),
      body: isHome
          ? IndexedStack(
              index: _selectedIndex,
              children: tabs,
            )
          : SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: tabs,
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }
}
