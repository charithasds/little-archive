import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_section.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    ref.listen(settingsControllerProvider, (AsyncValue<void>? previous, AsyncValue<void> next) {
      next.whenOrNull(
        data: (_) =>
            SnackBars.showSuccess('All application data cleared successfully', context: context),
        error: (Object error, _) => SnackBars.showError(error.toString(), context: context),
      );
    });

    final bool isClearing = ref.watch(settingsControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FormSection(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              children: <Widget>[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: SwitchListTile(
                    title: const Text('Select theme'),
                    subtitle: const Text('Toggle between light and dark theme'),
                    secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                    value: isDark,
                    onChanged: (bool value) => ref.read(themeModeProvider.notifier).toggleTheme(),
                    activeColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormSection(
              title: 'Data & Privacy',
              icon: Icons.security_outlined,
              children: <Widget>[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: isClearing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.delete_sweep_outlined, color: colorScheme.error),
                        title: Text('Clear All Data', style: TextStyle(color: colorScheme.error)),
                        subtitle: const Text('Clears all application data'),
                        onTap: isClearing
                            ? null
                            : () async {
                                final bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: const Text('Clear All Data?'),
                                    content: const Text(
                                      'This will permanently delete all your books, authors, publishers, and other data. This action is irreversible.',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: colorScheme.error,
                                        ),
                                        child: const Text('Clear Everything'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm ?? false) {
                                  await ref
                                      .read(settingsControllerProvider.notifier)
                                      .clearAllData();
                                }
                              },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Icon(Icons.person_remove_outlined, color: colorScheme.error),
                        title: Text('Delete Account', style: TextStyle(color: colorScheme.error)),
                        subtitle: const Text('Permanently delete your account and all data'),
                        onTap: () {
                          // TODO(user): Implement delete account
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(const SnackBar(content: Text('Not implemented yet')));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
