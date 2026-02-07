import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_navigation.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/boards/board_bloc.dart';
import '../../bloc/cards/card_bloc.dart';
import '../../bloc/notes/note_bloc.dart';
import '../../bloc/pages/page_bloc.dart';
import '../../bloc/search/search_bloc.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/api/api_service.dart';
import '../../../core/services/storage/storage_service.dart';
import 'home_screen.dart';
import 'projects_screen.dart';
import 'cards_screen.dart';
import 'notes_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'pages_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int currentIndex;
  final Widget? child;

  const DashboardScreen({
    super.key,
    this.currentIndex = 0,
    this.child,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _screens = [
      const HomeScreen(),
      const ProjectsScreen(),
      const CardsScreen(),
      const NotesScreen(),
      const SearchScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // Navigate to the selected tab
      switch (index) {
        case 0:
          context.go('/dashboard');
          break;
        case 1:
          context.go('/projects');
          break;
        case 2:
          context.go('/cards');
          break;
        case 3:
          context.go('/notes');
          break;
        case 4:
          context.go('/search');
          break;
        case 5:
          context.go('/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            // If a child widget is provided (for nested navigation), show it
            if (widget.child != null) {
              return widget.child!;
            }

            // Otherwise show the current tab screen
            return IndexedStack(
              index: _currentIndex,
              children: _screens,
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}