import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/utils/external_launcher.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/widgets/detail_section.dart';
import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/list_empty_state.dart';
import '../../../../core/shared/presentation/widgets/list_error_state.dart';
import '../../../../core/shared/presentation/widgets/list_loading_state.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/widgets/book_list_tile.dart';
import '../../../book/presentation/widgets/book_quick_info_dialog.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../../work/presentation/widgets/work_list_tile.dart';
import '../../../work/presentation/widgets/work_quick_info_dialog.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/usecases/translator_usecases.dart';
import '../providers/translator_provider.dart';

class TranslatorDetailPage extends ConsumerWidget {
  const TranslatorDetailPage({super.key, required this.translatorId});
  final String translatorId;

  Future<void> _handleRemove(
    BuildContext context,
    WidgetRef ref,
    TranslatorEntity translator,
  ) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Translator',
      entityName: translator.name,
      onConfirm: () async {
        await ref.read(removeTranslatorUseCaseProvider)(translator.id);
        if (context.mounted) {
          context.pop();
        }
      },
    );
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
              icon: FontAwesomeIcons.language,
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
                    icon: const FaIcon(FontAwesomeIcons.penToSquare),
                    onPressed: () async {
                      await context.push('/translators/upsert', extra: translator);
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.trash),
                    onPressed: () => _handleRemove(context, ref, translator),
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
                          alignment: Alignment.center,
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
                              ? FaIcon(
                                  FontAwesomeIcons.language,
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
                            leadingIcon: FontAwesomeIcons.idBadge,
                          ),
                        DetailTile(
                          label: 'Books Count',
                          value: '${translatorBooks.length} books',
                          leadingIcon: FontAwesomeIcons.book,
                        ),
                        DetailTile(
                          label: 'Works Count',
                          value: '${translatorWorks.length} works',
                          leadingIcon: FontAwesomeIcons.fileLines,
                        ),
                        if (translator.website != null && translator.website!.isNotEmpty)
                          DetailTile(
                            label: 'Website',
                            value: translator.website!,
                            leadingIcon: FontAwesomeIcons.globe,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchBrowser(translator.website!),
                          ),
                        if (translator.facebook != null && translator.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: translator.facebook!,
                            leadingIcon: FontAwesomeIcons.facebook,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchBrowser(translator.facebook!),
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(translator.createdDate),
                          leadingIcon: FontAwesomeIcons.calendar,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(translator.lastUpdated),
                          leadingIcon: FontAwesomeIcons.clockRotateLeft,
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
                              onTap: () => BookQuickInfoDialog.show(context, book.id),
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
                              onTap: () => WorkQuickInfoDialog.show(context, work.id),
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
