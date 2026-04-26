import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/admin_service.dart';
import '../utils/app_colors.dart';
import '../providers/localization_provider.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  static final AdminService _adminService = AdminService();

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/community')) return 1;
    if (location.startsWith('/camera')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/support')) return 4;
    return 0;
  }

  bool _isCommunityArea(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return location.startsWith('/community');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';

    return FutureBuilder<bool>(
      future: _adminService.isAdmin(userId),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data == true;

        if (isAdmin && !_isCommunityArea(context)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/community');
          });
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: isAdmin
              ? Container(
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE6E6E6)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: TextButton.icon(
                      onPressed: () => context.go('/community'),
                      icon: const Icon(Icons.forum, color: AppColors.primary),
                      label: Text(
                        context.watch<LocalizationProvider>().translate('community'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              : BottomNavigationBar(
                  currentIndex: _currentIndex(context),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: Colors.grey,
                  backgroundColor: Colors.white,
                  elevation: 8,
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        context.go('/home');
                        break;
                      case 1:
                        context.go('/community');
                        break;
                      case 2:
                        context.go('/camera');
                        break;
                      case 3:
                        context.go('/profile');
                        break;
                      case 4:
                        context.go('/support');
                        break;
                    }
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_outlined),
                      activeIcon: const Icon(Icons.home),
                      label: context.watch<LocalizationProvider>().translate('home'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.forum_outlined),
                      activeIcon: const Icon(Icons.forum),
                      label: context.watch<LocalizationProvider>().translate('community'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.document_scanner_outlined),
                      activeIcon: const Icon(Icons.document_scanner),
                      label: context.watch<LocalizationProvider>().translate('scan'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person_outline),
                      activeIcon: const Icon(Icons.person),
                      label: context.watch<LocalizationProvider>().translate('profile'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.help_outline),
                      activeIcon: const Icon(Icons.help),
                      label: context.watch<LocalizationProvider>().translate('support'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
