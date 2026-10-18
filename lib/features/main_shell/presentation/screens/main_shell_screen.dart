import 'package:flutter/material.dart';

import '../../../auth/data/auth_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../user_profile/presentation/controllers/profile_controller.dart';
import '../../../user_profile/presentation/screens/profile_screen.dart';
import '../controllers/main_shell_controller.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Giriş sonrası ana iskelet: üstte seçili sekme, altta menü.
/// Sekmeler IndexedStack'te durur; sekme değişince durumları kaybolmaz.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.authService,
    required this.user,
  });

  final AuthService authService;
  final AuthUser user;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final MainShellController _shell = MainShellController();
  final HomeController _home = HomeController();
  late final ProfileController _profile = ProfileController(
    username: widget.user.username,
    onSignOut: widget.authService.signOut,
  );

  @override
  void dispose() {
    _shell.dispose();
    _home.dispose();
    _profile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _shell,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _shell.currentIndex,
            children: [
              HomeScreen(controller: _home, username: widget.user.username),
              ProfileScreen(controller: _profile),
            ],
          ),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: _shell.currentIndex,
            onTabSelected: _shell.onTabSelected,
            onScanPressed: () => _shell.onScanPressed(context),
          ),
        );
      },
    );
  }
}
