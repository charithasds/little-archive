import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/routes/route_constants.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/widgets/list_empty_state.dart';
import '../../../../core/shared/presentation/widgets/list_error_state.dart';
import '../../../../core/shared/presentation/widgets/list_loading_state.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/usecases/author_usecases.dart';
import '../providers/author_list_controller.dart';
import '../providers/author_provider.dart';
import '../widgets/author_list_tile.dart';

class AuthorListPage extends ConsumerStatefulWidget {
  const AuthorListPage({super.key});

  @override
  ConsumerState<AuthorListPage> createState() => _AuthorListPageState();
}

class _AuthorListPageState extends ConsumerState<AuthorListPage> {
  bool _isExtended = true;

  Future<void> _handleRemove(String authorId, String authorName) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Author',
      entityName: authorName,
      onConfirm: () async {
        await ref.read(removeAuthorUseCaseProvider)(authorId);
        ref.invalidate(authorCountProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Authors'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: authorsAsync.when(
        data: (_) {
          final AuthorListState state = ref.watch(authorListControllerProvider);
          final List<AuthorEntity> authors = state.displayedAuthors;

          if (authors.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: FontAwesomeIcons.user,
              title: 'No Authors Yet',
              subtitle: 'Tap the button below to add your first author.',
            );
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: (UserScrollNotification notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (_isExtended) {
                  setState(() => _isExtended = false);
                }
              } else if (notification.direction == ScrollDirection.forward) {
                if (!_isExtended) {
                  setState(() => _isExtended = true);
                }
              }

              return true;
            },
            child: Column(
              children: <Widget>[
                SearchField(
                  hintText: 'Search',
                  onChanged: (String query) =>
                      ref.read(authorListControllerProvider.notifier).setSearchQuery(query),
                ),
                if (authors.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No authors match your search.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        if (constraints.maxWidth < 600) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: authors.length,
                            itemBuilder: (BuildContext context, int index) {
                              final AuthorEntity author = authors[index];

                              return AuthorListTile(
                                author: author,
                                onTap: () => context.goNamed(RouteConstants.authorDetail, pathParameters: <String, String>{'id': author.id}),
                                onEdit: () => context.pushNamed(RouteConstants.upsertAuthor, extra: author),
                                onRemove: () => _handleRemove(author.id, author.name),
                              );
                            },
                          );
                        } else {
                          return GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 600,
                              mainAxisExtent: 160,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                            ),
                            itemCount: authors.length,
                            itemBuilder: (BuildContext context, int index) {
                              final AuthorEntity author = authors[index];

                              return AuthorListTile(
                                author: author,
                                onTap: () => context.goNamed(RouteConstants.authorDetail, pathParameters: <String, String>{'id': author.id}),
                                onEdit: () => context.pushNamed(RouteConstants.upsertAuthor, extra: author),
                                onRemove: () => _handleRemove(author.id, author.name),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const ListLoadingState(),
        error: (Object err, StackTrace stack) => ListErrorState(error: err),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: _isExtended,
        backgroundColor: Buttons.getPrimaryActionBackgroundColor(theme),
        foregroundColor: Buttons.getPrimaryActionForegroundColor(theme),
        onPressed: () => context.pushNamed(RouteConstants.upsertAuthor),
        icon: const FaIcon(FontAwesomeIcons.plus),
        label: const Text('Add Author'),
      ),
    );
  }
}
