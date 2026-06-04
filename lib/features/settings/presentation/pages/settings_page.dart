import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/shared/presentation/utils/dialogs.dart';
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
        error: (Object error, _) => SnackBars.showError(error.toString(), context: context),
      );
    });

    final bool isLoading = ref.watch(settingsControllerProvider).isLoading;

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
              icon: FontAwesomeIcons.palette,
              children: <Widget>[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active'),
                    secondary: FaIcon(isDark ? FontAwesomeIcons.moon : FontAwesomeIcons.sun),
                    value: isDark,
                    onChanged: (bool value) => ref.read(themeModeProvider.notifier).toggleTheme(),
                    activeColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
            // ── Backup & Restore ─────────────────────────────────────────
            FormSection(
              title: 'Backup & Restore',
              icon: FontAwesomeIcons.floppyDisk,
              children: <Widget>[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      // Local Backup
                      ListTile(
                        leading: FaIcon(FontAwesomeIcons.fileExport, color: colorScheme.primary),
                        title: const Text('Export Local Backup'),
                        subtitle: const Text('Save a copy of your library to local storage'),
                        onTap: isLoading
                            ? null
                            : () async {
                                final bool success = await ref
                                    .read(settingsControllerProvider.notifier)
                                    .exportLocalBackup();
                                if (success && context.mounted) {
                                  SnackBars.showSuccess('Local backup exported successfully!', context: context);
                                }
                              },
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colorScheme.outlineVariant,
                      ),
                      // Local Restore
                      ListTile(
                        leading: FaIcon(FontAwesomeIcons.fileImport, color: colorScheme.primary),
                        title: const Text('Import Local Restore'),
                        subtitle: const Text('Restore your library from a local backup file'),
                        onTap: isLoading
                            ? null
                            : () async {
                                final bool confirmed = await AppDialogs.showDestructiveDialog(
                                  context,
                                  title: 'Restore Library?',
                                  content:
                                      'Importing a local backup will replace your current active library data. This action is irreversible.',
                                  confirmLabel: 'Start Import',
                                );
                                if (confirmed) {
                                  final bool success = await ref
                                      .read(settingsControllerProvider.notifier)
                                      .importLocalRestore();
                                  if (success && context.mounted) {
                                    SnackBars.showSuccess('Library restored successfully! Restarting app...', context: context);
                                    await Future<void>.delayed(const Duration(milliseconds: 1500));
                                    if (context.mounted) {
                                      Phoenix.rebirth(context);
                                    }
                                  }
                                }
                              },
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colorScheme.outlineVariant,
                      ),
                      // Google Drive Backup
                      ListTile(
                        leading: FaIcon(FontAwesomeIcons.googleDrive, color: colorScheme.primary),
                        title: const Text('Backup to Google Drive'),
                        subtitle: const Text('Upload your library to your personal Google Drive'),
                        onTap: isLoading
                            ? null
                            : () async {
                                final bool success = await ref
                                    .read(settingsControllerProvider.notifier)
                                    .backupToGoogleDrive();
                                if (success && context.mounted) {
                                  SnackBars.showSuccess('Uploaded library to Google Drive successfully!', context: context);
                                }
                              },
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colorScheme.outlineVariant,
                      ),
                      // Google Drive Restore
                      ListTile(
                        leading: FaIcon(FontAwesomeIcons.cloudArrowDown, color: colorScheme.primary),
                        title: const Text('Restore from Google Drive'),
                        subtitle: const Text('Download your library from Google Drive'),
                        onTap: isLoading
                            ? null
                            : () async {
                                final bool confirmed = await AppDialogs.showDestructiveDialog(
                                  context,
                                  title: 'Restore from Google Drive?',
                                  content:
                                      'Restoring will completely overwrite your current active local database with the backup saved on your Google Drive. This action cannot be undone.',
                                  confirmLabel: 'Start Restore',
                                );
                                if (confirmed) {
                                  final bool success = await ref
                                      .read(settingsControllerProvider.notifier)
                                      .restoreFromGoogleDrive();
                                  if (success && context.mounted) {
                                    SnackBars.showSuccess('Library restored successfully! Restarting app...', context: context);
                                    await Future<void>.delayed(const Duration(milliseconds: 1500));
                                    if (context.mounted) {
                                      Phoenix.rebirth(context);
                                    }
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ── Data & Privacy ───────────────────────────────────────────
            FormSection(
              title: 'Data & Privacy',
              icon: FontAwesomeIcons.shieldHalved,
              children: <Widget>[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      // Clear All Data
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leading: isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.error,
                                ),
                              )
                            : FaIcon(FontAwesomeIcons.broom, color: colorScheme.error),
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
                        onTap: isLoading
                            ? null
                            : () async {
                                final bool confirmed = await AppDialogs.showDestructiveDialog(
                                  context,
                                  title: 'Clear All Data?',
                                  content:
                                      'This will permanently delete all your books, authors, publishers, and other data. This action is irreversible.',
                                  confirmLabel: 'Clear Everything',
                                );
                                if (confirmed) {
                                  await ref
                                      .read(settingsControllerProvider.notifier)
                                      .clearAllData();
                                  if (context.mounted && !ref.read(settingsControllerProvider).hasError) {
                                    SnackBars.showSuccess(
                                      'All application data cleared successfully',
                                      context: context,
                                    );
                                  }
                                }
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
