import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_section.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  /// Shared M3 Expressive confirmation dialog for destructive actions.
  static Future<bool> _showDestructiveDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required ColorScheme cs,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: cs.error, size: 40),
        iconPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Text(title),
        titleTextStyle: Theme.of(
          ctx,
        ).textTheme.titleLarge?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
        content: Text(
          content,
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

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
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // ── Appearance ───────────────────────────────────────────────
            FormSection(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              children: <Widget>[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active'),
                    secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                    value: isDark,
                    onChanged: (bool value) => ref.read(themeModeProvider.notifier).toggleTheme(),
                    activeColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
            // ── Data & Privacy ───────────────────────────────────────────
            FormSection(
              title: 'Data & Privacy',
              icon: Icons.security_outlined,
              children: <Widget>[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      // Clear All Data
                      ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        leading: isClearing
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.error,
                                ),
                              )
                            : Icon(Icons.delete_sweep_outlined, color: colorScheme.error),
                        title: Text(
                          'Clear All Data',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Permanently removes all books, authors and related data',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: isClearing
                            ? null
                            : () async {
                                final bool confirmed = await _showDestructiveDialog(
                                  context,
                                  title: 'Clear All Data?',
                                  content:
                                      'This will permanently delete all your books, authors, publishers, and other data. This action is irreversible.',
                                  confirmLabel: 'Clear Everything',
                                  cs: colorScheme,
                                );
                                if (confirmed) {
                                  await ref
                                      .read(settingsControllerProvider.notifier)
                                      .clearAllData();
                                }
                              },
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colorScheme.outlineVariant,
                      ),
                      // Delete Account
                      ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        leading: Icon(Icons.person_remove_outlined, color: colorScheme.error),
                        title: Text(
                          'Delete Account',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Permanently deletes your account and all associated data',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          // Feature: Implement delete account
                          SnackBars.showInfo('Account deletion is not yet available.');
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
