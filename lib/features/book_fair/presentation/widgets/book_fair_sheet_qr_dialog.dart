import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../book/domain/entities/book_entity.dart';
import '../providers/book_fair_sync_controller.dart';

class BookFairSheetQrDialog extends ConsumerWidget {
  const BookFairSheetQrDialog({super.key, required this.books});

  final List<BookEntity> books;

  /// Convenience factory to open the dialog from any [BuildContext].
  static Future<void> show(BuildContext context, List<BookEntity> books) => showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => BookFairSheetQrDialog(books: books),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BookFairSyncState syncState = ref.watch(bookFairSyncControllerProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color purpleContainer = isDark
        ? const Color(0xFF4A148C).withValues(alpha: 0.18)
        : const Color(0xFFE1BEE7).withValues(alpha: 0.35);
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // -----------------------------------------------------------------
            // Header
            // -----------------------------------------------------------------
            Row(
              children: <Widget>[
                FaIcon(FontAwesomeIcons.shareNodes, color: purplePrimary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Shopping List',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // Body (QR code / fallback)
            // -----------------------------------------------------------------
            if (syncState.status == BookFairSyncStatus.exporting)
              const Center(
                child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()),
              )
            else if (syncState.sheetUrl != null) ...<Widget>[
              // Instructional text
              Text(
                'Scan the QR code to open the Google Sheet on another device.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // QR Code container
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: syncState.sheetUrl!,
                    size: 200,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black87),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // URL chip + copy button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: purpleContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        syncState.sheetUrl!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: purplePrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.copy, size: 18, color: purplePrimary),
                      tooltip: 'Copy Link',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: syncState.sheetUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
