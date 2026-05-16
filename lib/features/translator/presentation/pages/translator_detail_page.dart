import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/external_launcher.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/detail_widgets.dart';
import '../../../../core/shared/presentation/widgets/info_dialogs.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/widgets/book_list_tile.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../../work/presentation/widgets/work_list_tile.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/usecases/translator_usecases.dart';
import '../providers/translator_provider.dart';

class TranslatorDetailPage extends ConsumerWidget {
  const TranslatorDetailPage({super.key, required this.translatorId});
  final String translatorId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String translatorId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Translator'),
        content: const Text(
          'Are you sure you want to remove this translator? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(removeTranslatorUseCaseProvider)(translatorId);
      SnackBars.showSuccess('Translator removed successfully');
      if (context.mounted) {
        context.pop();
      }
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TranslatorEntity?> translatorAsync = ref.watch(
      translatorProvider(translatorId),
    );
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return translatorAsync.when(
      data: (TranslatorEntity? translator) {
        if (translator == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: Icons.translate_rounded,
              title: 'Translator Not Found',
              subtitle: 'This translator may have been removed.',
            ),
          );
        }

        final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
        final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);

        final List<BookEntity> translatorBooks =
            (booksAsync.value ?? <BookEntity>[])
                .where((BookEntity b) => translator.bookIds.contains(b.id))
                .toList()
              ..sort(
                (BookEntity a, BookEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

        final List<WorkEntity> translatorWorks =
            (worksAsync.value ?? <WorkEntity>[])
                .where((WorkEntity w) => translator.workIds.contains(w.id))
                .toList()
              ..sort(
                (WorkEntity a, WorkEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(translator.name),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                surfaceTintColor: theme.colorScheme.primary,
                scrolledUnderElevation: 1,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () async {
                      await context.push('/translators/add', extra: translator);
                      ref.invalidate(translatorProvider(translatorId));
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _handleRemove(context, ref, translator.id),
                    tooltip: 'Remove',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Center(
                      child: Hero(
                        tag: 'translator_${translator.id}',
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Images.getAvatarBackgroundColor(theme),
                            image: translator.image != null && translator.image!.isNotEmpty
                                ? DecorationImage(
                                    image: Images.getImageProvider(translator.image),
                                    fit: BoxFit.contain,
                                  )
                                : null,
                          ),
                          child: translator.image == null || translator.image!.isEmpty
                              ? Icon(
                                  Icons.translate_rounded,
                                  color: Images.getAvatarIconColor(theme),
                                  size: 120,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DetailSection(
                      title: 'INFORMATION',
                      children: <Widget>[
                        if (translator.otherName != null && translator.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: translator.otherName!,
                            icon: Icons.badge_rounded,
                          ),
                        DetailTile(
                          label: 'Books Count',
                          value: '${translatorBooks.length} books',
                          icon: Icons.book_rounded,
                        ),
                        DetailTile(
                          label: 'Works Count',
                          value: '${translatorWorks.length} works',
                          icon: Icons.article_rounded,
                        ),
                        if (translator.website != null && translator.website!.isNotEmpty)
                          DetailTile(
                            label: 'Website',
                            value: translator.website!,
                            icon: Icons.language_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchBrowser(translator.website!),
                          ),
                        if (translator.facebook != null && translator.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: translator.facebook!,
                            icon: Icons.facebook_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchBrowser(translator.facebook!),
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(translator.createdDate),
                          icon: Icons.calendar_today_rounded,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(translator.lastUpdated),
                          icon: Icons.update_rounded,
                        ),
                      ],
                    ),
                    DetailSection(
                      title: 'BOOKS (${translatorBooks.length})',
                      showDivider: translatorWorks.isNotEmpty,
                      children: translatorBooks
                          .map(
                            (BookEntity book) => BookListTile(
                              book: book,
                              onInfo: () => EntityQuickInfoDialog.show(context, book.id, 'book'),
                            ),
                          )
                          .toList(),
                    ),
                    DetailSection(
                      title: 'WORKS (${translatorWorks.length})',
                      showDivider: false,
                      children: translatorWorks
                          .map(
                            (WorkEntity work) => WorkListTile(
                              work: work,
                              onInfo: () => EntityQuickInfoDialog.show(context, work.id, 'work'),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: ListLoadingState()),
      error: (Object err, StackTrace stack) => Scaffold(body: ListErrorState(error: err)),
    );
  }
}
