import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../widgets/dashboard.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// Returns the first word of displayName, or null if unavailable.
  static String? _firstName(UserEntity? user) {
    final String? name = user?.displayName?.trim();
    if (name == null || name.isEmpty) {
      return null;
    }
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;
    final UserEntity? user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Little Archive'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.primary,
        centerTitle: false,
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      user.photoUrl!,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
                          const FaIcon(FontAwesomeIcons.user),
                    ),
                  )
                : const FaIcon(FontAwesomeIcons.user),
            tooltip: 'User Profile',
            onSelected: (String value) {
              if (value == 'settings') {
                context.go('/settings');
              } else if (value == 'logout') {
                ref.read(authControllerProvider.notifier).signOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: FaIcon(FontAwesomeIcons.gear),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: FaIcon(FontAwesomeIcons.rightFromBracket, color: cs.error),
                  title: Text('Sign Out', style: TextStyle(color: cs.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Dashboard(firstName: _firstName(user)),
    );
  }
}
