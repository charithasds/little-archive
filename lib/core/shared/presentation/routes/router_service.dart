import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/author/domain/entities/author_entity.dart';
import '../../../../features/author/presentation/pages/author_detail_page.dart';
import '../../../../features/author/presentation/pages/author_list_page.dart';
import '../../../../features/author/presentation/pages/upsert_author_page.dart';
import '../../../../features/book/domain/entities/book_entity.dart';
import '../../../../features/book/presentation/pages/book_collection_status_manage_page.dart';
import '../../../../features/book/presentation/pages/book_data_quality_manage_page.dart';
import '../../../../features/book/presentation/pages/book_detail_page.dart';
import '../../../../features/book/presentation/pages/book_list_page.dart';
import '../../../../features/book/presentation/pages/book_reading_status_manage_page.dart';
import '../../../../features/book/presentation/pages/upsert_book_page.dart';
import '../../../../features/book_fair/presentation/pages/book_fair_setup_page.dart';
import '../../../../features/book_fair/presentation/pages/book_fair_shopping_plan_page.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../../../features/publisher/domain/entities/publisher_entity.dart';
import '../../../../features/publisher/presentation/pages/publisher_detail_page.dart';
import '../../../../features/publisher/presentation/pages/publisher_list_page.dart';
import '../../../../features/publisher/presentation/pages/upsert_publisher_page.dart';
import '../../../../features/reader/domain/entities/reader_entity.dart';
import '../../../../features/reader/presentation/pages/reader_detail_page.dart';
import '../../../../features/reader/presentation/pages/reader_list_page.dart';
import '../../../../features/reader/presentation/pages/upsert_reader_page.dart';
import '../../../../features/sequence/domain/entities/sequence_entity.dart';
import '../../../../features/sequence/presentation/pages/sequence_detail_page.dart';
import '../../../../features/sequence/presentation/pages/sequence_list_page.dart';
import '../../../../features/sequence/presentation/pages/upsert_sequence_page.dart';
import '../../../../features/settings/presentation/pages/settings_page.dart';
import '../../../../features/translator/domain/entities/translator_entity.dart';
import '../../../../features/translator/presentation/pages/translator_detail_page.dart';
import '../../../../features/translator/presentation/pages/translator_list_page.dart';
import '../../../../features/translator/presentation/pages/upsert_translator_page.dart';
import '../../../../features/work/domain/entities/work_entity.dart';
import '../../../../features/work/presentation/pages/upsert_work_page.dart';
import '../../../../features/work/presentation/pages/work_detail_page.dart';
import '../../../../features/work/presentation/pages/work_list_page.dart';
import '../../presentation/providers/initialization_provider.dart';
import '../pages/error_page.dart';
import '../pages/loading_page.dart';
import 'route_constants.dart';

part 'router_service.g.dart';

class RouterService {
  GoRouter createRouter(AsyncValue<void> init) => GoRouter(
    initialLocation: RouteConstants.pathLoading,
    routes: _routes,
    redirect: (_, GoRouterState state) => _redirect(init, state),
  );

  List<RouteBase> get _routes => <RouteBase>[
    GoRoute(
      path: RouteConstants.pathLoading,
      name: RouteConstants.loading,
      builder: (BuildContext context, GoRouterState state) => const LoadingPage(),
    ),
    GoRoute(
      path: RouteConstants.pathError,
      name: RouteConstants.error,
      builder: (BuildContext context, GoRouterState state) =>
          ErrorPage(error: state.extra ?? 'Unknown initialization error'),
    ),
    GoRoute(
      path: RouteConstants.pathHome,
      name: RouteConstants.home,
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
      routes: <RouteBase>[
        GoRoute(
          path: RouteConstants.pathWorks,
          name: RouteConstants.works,
          builder: (BuildContext context, GoRouterState state) => const WorkListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.pathUpsertWork,
              name: RouteConstants.upsertWork,
              builder: (BuildContext context, GoRouterState state) {
                final Object? extra = state.extra;
                if (extra is Map<String, dynamic>) {
                  return UpsertWorkPage(
                    existingWork: extra['existingWork'] as WorkEntity?,
                    preselectedSequence: extra['preselectedSequence'] as SequenceEntity?,
                  );
                }
                return UpsertWorkPage(existingWork: extra as WorkEntity?);
              },
            ),
            GoRoute(
              path: RouteConstants.pathWorkDetail,
              name: RouteConstants.workDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return WorkDetailPage(workId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: RouteConstants.pathBooks,
          name: RouteConstants.books,
          builder: (BuildContext context, GoRouterState state) => const BookListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.pathUpsertBook,
              name: RouteConstants.upsertBook,
              builder: (BuildContext context, GoRouterState state) {
                final Object? extra = state.extra;
                if (extra is Map<String, dynamic>) {
                  return UpsertBookPage(
                    existingBook: extra['existingBook'] as BookEntity?,
                    preselectedSequence: extra['preselectedSequence'] as SequenceEntity?,
                  );
                }
                return UpsertBookPage(existingBook: extra as BookEntity?);
              },
            ),
            GoRoute(
              path: RouteConstants.pathBookDetail,
              name: RouteConstants.bookDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return BookDetailPage(bookId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: RouteConstants.pathAuthors,
          name: RouteConstants.authors,
          builder: (BuildContext context, GoRouterState state) => const AuthorListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.pathUpsertAuthor,
              name: RouteConstants.upsertAuthor,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertAuthorPage(existingAuthor: state.extra as AuthorEntity?),
            ),
            GoRoute(
              path: RouteConstants.pathAuthorDetail,
              name: RouteConstants.authorDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return AuthorDetailPage(authorId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: RouteConstants.pathTranslators,
          name: RouteConstants.translators,
          builder: (BuildContext context, GoRouterState state) => const TranslatorListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.pathUpsertTranslator,
              name: RouteConstants.upsertTranslator,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertTranslatorPage(existingTranslator: state.extra as TranslatorEntity?),
            ),
            GoRoute(
              path: RouteConstants.pathTranslatorDetail,
              name: RouteConstants.translatorDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return TranslatorDetailPage(translatorId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: RouteConstants.pathPublishers,
          name: RouteConstants.publishers,
          builder: (BuildContext context, GoRouterState state) => const PublisherListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.pathUpsertPublisher,
              name: RouteConstants.upsertPublisher,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertPublisherPage(existingPublisher: state.extra as PublisherEntity?),
            ),
            GoRoute(
              path: RouteConstants.pathPublisherDetail,
              name: RouteConstants.publisherDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return PublisherDetailPage(publisherId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: RouteConstants.pathSequences,
          name: RouteConstants.sequences,
          builder: (BuildContext context, GoRouterState state) => const SequenceListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.pathUpsertSequence,
              name: RouteConstants.upsertSequence,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertSequencePage(existingSequence: state.extra as SequenceEntity?),
            ),
            GoRoute(
              path: RouteConstants.pathSequenceDetail,
              name: RouteConstants.sequenceDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return SequenceDetailPage(sequenceId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: RouteConstants.pathReaders,
          name: RouteConstants.readers,
          builder: (BuildContext context, GoRouterState state) => const ReaderListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: RouteConstants.pathUpsertReader,
              name: RouteConstants.upsertReader,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertReaderPage(existingReader: state.extra as ReaderEntity?),
            ),
            GoRoute(
              path: RouteConstants.pathReaderDetail,
              name: RouteConstants.readerDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return ReaderDetailPage(readerId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: RouteConstants.pathSettings,
          name: RouteConstants.settings,
          builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
        ),

        GoRoute(
          path: RouteConstants.pathCollectionStatus,
          name: RouteConstants.collectionStatus,
          builder: (BuildContext context, GoRouterState state) =>
              const BookCollectionStatusManagePage(),
        ),

        GoRoute(
          path: RouteConstants.pathReadingStatus,
          name: RouteConstants.readingStatus,
          builder: (BuildContext context, GoRouterState state) =>
              const BookReadingStatusManagePage(),
        ),

        GoRoute(
          path: RouteConstants.pathDataQuality,
          name: RouteConstants.dataQuality,
          builder: (BuildContext context, GoRouterState state) => const BookDataQualityManagePage(),
        ),

        GoRoute(
          path: RouteConstants.pathBookFair,
          name: RouteConstants.bookFair,
          builder: (BuildContext context, GoRouterState state) => const BookFairSetupPage(),
        ),
        GoRoute(
          path: RouteConstants.pathShoppingPlan,
          name: RouteConstants.shoppingPlan,
          builder: (BuildContext context, GoRouterState state) => const BookFairShoppingPlanPage(),
        ),
      ],
    ),
  ];

  String? _redirect(AsyncValue<void> init, GoRouterState state) {
    final String path = state.uri.path;

    if (init.isLoading) {
      return path == RouteConstants.pathLoading ? null : RouteConstants.pathLoading;
    }

    if (init.hasError) {
      return path == RouteConstants.pathError ? null : RouteConstants.pathError;
    }

    if (path == RouteConstants.pathLoading || path == RouteConstants.pathError) {
      return RouteConstants.pathHome;
    }

    return null;
  }
}

@riverpod
RouterService routerService(Ref ref) => RouterService();

@riverpod
GoRouter goRouter(Ref ref) {
  final AsyncValue<void> init = ref.watch(initializationProvider);
  final RouterService routerService = ref.watch(routerServiceProvider);

  if (!init.hasValue && init.isLoading) {
    return routerService.createRouter(init);
  }

  return routerService.createRouter(init);
}
