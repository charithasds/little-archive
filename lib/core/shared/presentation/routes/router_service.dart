import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/author/domain/entities/author_entity.dart';
import '../../../../features/author/presentation/pages/author_detail_page.dart';
import '../../../../features/author/presentation/pages/author_list_page.dart';
import '../../../../features/author/presentation/pages/upsert_author_page.dart';
import '../../../../features/book/domain/entities/book_entity.dart';
import '../../../../features/book/presentation/pages/book_detail_page.dart';
import '../../../../features/book/presentation/pages/book_list_page.dart';
import '../../../../features/book/presentation/pages/upsert_book_page.dart';
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

class RouterService {
  GoRouter createRouter(AsyncValue<void> init, AsyncValue<UserEntity?> auth) => GoRouter(
    initialLocation: '/loading',
    routes: _routes,
    redirect: (_, GoRouterState state) => _redirect(init, auth, state),
  );

  List<RouteBase> get _routes => <RouteBase>[
    GoRoute(
      path: '/loading',
      builder: (BuildContext context, GoRouterState state) => const LoadingPage(),
    ),
    GoRoute(
      path: '/error',
      builder: (BuildContext context, GoRouterState state) =>
          ErrorPage(error: state.extra ?? 'Unknown initialization error'),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'works',
          builder: (BuildContext context, GoRouterState state) => const WorkListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertWorkPage(existingWork: state.extra as WorkEntity?),
            ),
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return WorkDetailPage(workId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'books',
          builder: (BuildContext context, GoRouterState state) => const BookListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertBookPage(existingBook: state.extra as BookEntity?),
            ),
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return BookDetailPage(bookId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'authors',
          builder: (BuildContext context, GoRouterState state) => const AuthorListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertAuthorPage(existingAuthor: state.extra as AuthorEntity?),
            ),
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return AuthorDetailPage(authorId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'translators',
          builder: (BuildContext context, GoRouterState state) => const TranslatorListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertTranslatorPage(existingTranslator: state.extra as TranslatorEntity?),
            ),
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return TranslatorDetailPage(translatorId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'publishers',
          builder: (BuildContext context, GoRouterState state) => const PublisherListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertPublisherPage(existingPublisher: state.extra as PublisherEntity?),
            ),
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return PublisherDetailPage(publisherId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'sequences',
          builder: (BuildContext context, GoRouterState state) => const SequenceListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertSequencePage(existingSequence: state.extra as SequenceEntity?),
            ),
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return SequenceDetailPage(sequenceId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'readers',
          builder: (BuildContext context, GoRouterState state) => const ReaderListPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              builder: (BuildContext context, GoRouterState state) =>
                  UpsertReaderPage(existingReader: state.extra as ReaderEntity?),
            ),
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['id']!;
                return ReaderDetailPage(readerId: id);
              },
            ),
          ],
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
