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
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../presentation/providers/initialization_provider.dart';
import '../pages/error_page.dart';
import '../pages/loading_page.dart';

part 'router_service.g.dart';

abstract class RouteConstants {
  static const String loading = 'loading';
  static const String error = 'error';
  static const String login = 'login';
  static const String home = 'home';
  static const String works = 'works';
  static const String upsertWork = 'upsert-work';
  static const String workDetail = 'work-detail';
  static const String books = 'books';
  static const String upsertBook = 'upsert-book';
  static const String bookDetail = 'book-detail';
  static const String authors = 'authors';
  static const String upsertAuthor = 'upsert-author';
  static const String authorDetail = 'author-detail';
  static const String translators = 'translators';
  static const String upsertTranslator = 'upsert-translator';
  static const String translatorDetail = 'translator-detail';
  static const String publishers = 'publishers';
  static const String upsertPublisher = 'upsert-publisher';
  static const String publisherDetail = 'publisher-detail';
  static const String sequences = 'sequences';
  static const String upsertSequence = 'upsert-sequence';
  static const String sequenceDetail = 'sequence-detail';
  static const String readers = 'readers';
  static const String upsertReader = 'upsert-reader';
  static const String readerDetail = 'reader-detail';
  static const String settings = 'settings';
  static const String collectionStatus = 'collection-status';
  static const String readingStatus = 'reading-status';
  static const String dataQuality = 'data-quality';
  static const String bookFair = 'book-fair';
  static const String shoppingPlan = 'shopping-plan';
}

class RouterService {
  GoRouter createRouter(AsyncValue<void> init, AsyncValue<UserEntity?> auth) => GoRouter(
    initialLocation: '/loading',
    routes: _routes,
    redirect: (_, GoRouterState state) => _redirect(init, auth, state),
  );

  List<RouteBase> get _routes => <RouteBase>[
    GoRoute(
      path: '/loading',
      name: RouteConstants.loading,
      builder: (BuildContext context, GoRouterState state) => const LoadingPage(),
    ),
    GoRoute(
      path: '/error',
      name: RouteConstants.error,
      builder: (BuildContext context, GoRouterState state) =>
          ErrorPage(error: state.extra ?? 'Unknown initialization error'),
    ),
    GoRoute(
      path: '/login',
      name: RouteConstants.login,
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      name: RouteConstants.home,
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'works',
          name: RouteConstants.works,
          builder: (BuildContext context, GoRouterState state) => const WorkListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'upsert',
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
              path: ':id',
              name: RouteConstants.workDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return WorkDetailPage(workId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'books',
          name: RouteConstants.books,
          builder: (BuildContext context, GoRouterState state) => const BookListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'upsert',
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
              path: ':id',
              name: RouteConstants.bookDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return BookDetailPage(bookId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'authors',
          name: RouteConstants.authors,
          builder: (BuildContext context, GoRouterState state) => const AuthorListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'upsert',
              name: RouteConstants.upsertAuthor,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertAuthorPage(existingAuthor: state.extra as AuthorEntity?),
            ),
            GoRoute(
              path: ':id',
              name: RouteConstants.authorDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return AuthorDetailPage(authorId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'translators',
          name: RouteConstants.translators,
          builder: (BuildContext context, GoRouterState state) => const TranslatorListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'upsert',
              name: RouteConstants.upsertTranslator,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertTranslatorPage(existingTranslator: state.extra as TranslatorEntity?),
            ),
            GoRoute(
              path: ':id',
              name: RouteConstants.translatorDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return TranslatorDetailPage(translatorId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'publishers',
          name: RouteConstants.publishers,
          builder: (BuildContext context, GoRouterState state) => const PublisherListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'upsert',
              name: RouteConstants.upsertPublisher,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertPublisherPage(existingPublisher: state.extra as PublisherEntity?),
            ),
            GoRoute(
              path: ':id',
              name: RouteConstants.publisherDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return PublisherDetailPage(publisherId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'sequences',
          name: RouteConstants.sequences,
          builder: (BuildContext context, GoRouterState state) => const SequenceListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'upsert',
              name: RouteConstants.upsertSequence,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertSequencePage(existingSequence: state.extra as SequenceEntity?),
            ),
            GoRoute(
              path: ':id',
              name: RouteConstants.sequenceDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return SequenceDetailPage(sequenceId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'readers',
          name: RouteConstants.readers,
          builder: (BuildContext context, GoRouterState state) => const ReaderListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'upsert',
              name: RouteConstants.upsertReader,
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertReaderPage(existingReader: state.extra as ReaderEntity?),
            ),
            GoRoute(
              path: ':id',
              name: RouteConstants.readerDetail,
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return ReaderDetailPage(readerId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'settings',
          name: RouteConstants.settings,
          builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
        ),

        GoRoute(
          path: 'collection-status',
          name: RouteConstants.collectionStatus,
          builder: (BuildContext context, GoRouterState state) =>
              const BookCollectionStatusManagePage(),
        ),

        GoRoute(
          path: 'reading-status',
          name: RouteConstants.readingStatus,
          builder: (BuildContext context, GoRouterState state) =>
              const BookReadingStatusManagePage(),
        ),

        GoRoute(
          path: 'data-quality',
          name: RouteConstants.dataQuality,
          builder: (BuildContext context, GoRouterState state) => const BookDataQualityManagePage(),
        ),

        GoRoute(
          path: 'book-fair',
          name: RouteConstants.bookFair,
          builder: (BuildContext context, GoRouterState state) => const BookFairSetupPage(),
        ),
        GoRoute(
          path: 'shopping-plan',
          name: RouteConstants.shoppingPlan,
          builder: (BuildContext context, GoRouterState state) => const BookFairShoppingPlanPage(),
        ),
      ],
    ),
  ];

  String? _redirect(AsyncValue<void> init, AsyncValue<UserEntity?> auth, GoRouterState state) {
    final String path = state.uri.path;

    if (init.isLoading || auth.isLoading) {
      return path == '/loading' ? null : '/loading';
    }

    if (init.hasError || auth.hasError) {
      return path == '/error' ? null : '/error';
    }

    final bool isLoggedIn = auth.value != null;

    if (!isLoggedIn) {
      return path == '/login' ? null : '/login';
    }

    if (path == '/login' || path == '/loading' || path == '/error') {
      return '/';
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
  final AsyncValue<UserEntity?> auth = ref.watch(authStateProvider);

  if (!init.hasValue && init.isLoading) {
    return routerService.createRouter(init, const AsyncValue<UserEntity?>.loading());
  }

  return routerService.createRouter(init, auth);
}
