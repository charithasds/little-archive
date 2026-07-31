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

  Widget _buildProgressIndicator({
    required bool isActive,
    required double? progress,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    if (!isActive) {
      return const SizedBox.shrink();
    }

    final int percentage = progress != null ? (progress * 100).clamp(0, 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              color: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            progress != null ? '$percentage%' : 'Processing...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    ref.listen(settingsControllerProvider, (SettingsState? previous, SettingsState next) {
      next.status.whenOrNull(
        error: (Object error, _) => SnackBars.showError(error.toString(), context: context),
      );
    });

    final SettingsState settingsState = ref.watch(settingsControllerProvider);
    final bool isLoading = settingsState.status.isLoading;
    final SettingsOperation? activeOp = settingsState.currentOperation;

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
                    title: const Text('Change Theme'),
                    subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active'),
                    secondary: FaIcon(
                      isDark ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
                      color: colorScheme.primary,
                    ),
                    value: isDark,
                    onChanged: isLoading
                        ? null
                        : (bool value) => ref.read(themeModeProvider.notifier).toggleTheme(),
                    activeColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
            // ── Data Management ──────────────────────────────────────────
            FormSection(
              title: 'Data Management',
              icon: FontAwesomeIcons.database,
              children: <Widget>[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      // Local Backup
                      ListTile(
                        enabled: !isLoading,
                        leading: activeOp == SettingsOperation.exportLocal
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : FaIcon(FontAwesomeIcons.fileExport, color: colorScheme.primary),
                        title: const Text('Export to Local Storage'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('Save library to local storage'),
                            _buildProgressIndicator(
                              isActive: activeOp == SettingsOperation.exportLocal,
                              progress: settingsState.progress,
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],
                        ),
                        onTap: isLoading
                            ? null
                            : () async {
                                final bool success = await ref
                                    .read(settingsControllerProvider.notifier)
                                    .exportLocalBackup();
                                if (success && context.mounted) {
                                  SnackBars.showSuccess(
                                    'Local backup exported successfully!',
                                    context: context,
                                  );
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
                        enabled: !isLoading,
                        leading: activeOp == SettingsOperation.importLocal
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : FaIcon(FontAwesomeIcons.fileImport, color: colorScheme.primary),
                        title: const Text('Restore from Local Storage'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('Restore library from local storage'),
                            _buildProgressIndicator(
                              isActive: activeOp == SettingsOperation.importLocal,
                              progress: settingsState.progress,
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],
                        ),
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
                                    SnackBars.showSuccess(
                                      'Library restored successfully! Restarting app...',
                                      context: context,
                                    );
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
                        enabled: !isLoading,
                        leading: activeOp == SettingsOperation.backupDrive
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : FaIcon(FontAwesomeIcons.googleDrive, color: colorScheme.primary),
                        title: const Text('Backup to Google Drive'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('Save library to Google Drive'),
                            _buildProgressIndicator(
                              isActive: activeOp == SettingsOperation.backupDrive,
                              progress: settingsState.progress,
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],
                        ),
                        onTap: isLoading
                            ? null
                            : () async {
                                final bool success = await ref
                                    .read(settingsControllerProvider.notifier)
                                    .backupToGoogleDrive();
                                if (success && context.mounted) {
                                  SnackBars.showSuccess(
                                    'Uploaded library to Google Drive successfully!',
                                    context: context,
                                  );
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
                        enabled: !isLoading,
                        leading: activeOp == SettingsOperation.restoreDrive
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : FaIcon(FontAwesomeIcons.cloudArrowDown, color: colorScheme.primary),
                        title: const Text('Restore from Google Drive'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('Restore library from Google Drive'),
                            _buildProgressIndicator(
                              isActive: activeOp == SettingsOperation.restoreDrive,
                              progress: settingsState.progress,
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],
                        ),
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
                                    SnackBars.showSuccess(
                                      'Library restored successfully! Restarting app...',
                                      context: context,
                                    );
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
                      // Compress & Downscale All Images
                      ListTile(
                        enabled: !isLoading,
                        leading: activeOp == SettingsOperation.compressImages
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : FaIcon(FontAwesomeIcons.fileImage, color: colorScheme.primary),
                        title: const Text('Compress & Downscale Database Images'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Downscale stored images larger than 50k characters to save memory',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            _buildProgressIndicator(
                              isActive: activeOp == SettingsOperation.compressImages,
                              progress: settingsState.progress,
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],
                        ),
                        onTap: isLoading
                            ? null
                            : () async {
                                final int count = await ref
                                    .read(settingsControllerProvider.notifier)
                                    .compressAllDatabaseImages();
                                if (context.mounted) {
                                  SnackBars.showSuccess(
                                    count > 0
                                        ? 'Successfully downscaled $count image(s)!'
                                        : 'All database images are already compressed.',
                                    context: context,
                                  );
                                }
                              },
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colorScheme.outlineVariant,
                      ),
                      // Clear All Data
                      ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        enabled: !isLoading,
                        leading: activeOp == SettingsOperation.clearData
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : FaIcon(FontAwesomeIcons.broom, color: colorScheme.primary),
                        title: Text(
                          'Clear All Data',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Permanently removes all books, authors and related data',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            _buildProgressIndicator(
                              isActive: activeOp == SettingsOperation.clearData,
                              progress: settingsState.progress,
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],
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
                                  if (context.mounted &&
                                      !ref.read(settingsControllerProvider).status.hasError) {
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
