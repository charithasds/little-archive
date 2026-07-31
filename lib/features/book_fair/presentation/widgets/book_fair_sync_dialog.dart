import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../book/domain/entities/book_entity.dart';
import '../providers/book_fair_sync_controller.dart';

class BookFairSyncDialog extends ConsumerStatefulWidget {
  const BookFairSyncDialog({super.key, required this.books});

  final List<BookEntity> books;

  static Future<void> show(BuildContext context, List<BookEntity> books) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => BookFairSyncDialog(books: books),
      );

  @override
  ConsumerState<BookFairSyncDialog> createState() => _BookFairSyncDialogState();
}

class _BookFairSyncDialogState extends ConsumerState<BookFairSyncDialog> {
  @override
  void initState() {
    super.initState();
    // Start sync automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookFairSyncControllerProvider.notifier).pullUpdates(widget.books);
    });
  }

  @override
  Widget build(BuildContext context) {
    final BookFairSyncState syncState = ref.watch(bookFairSyncControllerProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                FaIcon(FontAwesomeIcons.arrowsRotate, color: purplePrimary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Syncing List',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            if (syncState.status == BookFairSyncStatus.pulling ||
                syncState.status == BookFairSyncStatus.idle)
              const Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking for updates from Google Sheets...'),
                ],
              )
            else if (syncState.status == BookFairSyncStatus.error)
              Column(
                children: <Widget>[
                  FaIcon(FontAwesomeIcons.circleExclamation, color: colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    syncState.error ?? 'Unknown error occurred.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              )
            else if (syncState.status == BookFairSyncStatus.done)
              Column(
                children: <Widget>[
                  const FaIcon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  if (syncState.updatedBookTitles == null || syncState.updatedBookTitles!.isEmpty)
                    Text(
                      'No new updates found in the sheet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else ...<Widget>[
                    Text(
                      '${syncState.updatedBookTitles!.length} book(s) marked as Collected:',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: syncState.updatedBookTitles!.length,
                        itemBuilder: (BuildContext context, int index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.check, size: 14, color: Colors.green),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  syncState.updatedBookTitles![index],
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Conflicts UI
                  if (syncState.conflictBookTitles != null && syncState.conflictBookTitles!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              FaIcon(FontAwesomeIcons.triangleExclamation, color: colorScheme.error, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Conflict: Already collected locally',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...syncState.conflictBookTitles!.map((String title) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: 24),

            // Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: purplePrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (syncState.status == BookFairSyncStatus.pulling ||
                        syncState.status == BookFairSyncStatus.idle)
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
