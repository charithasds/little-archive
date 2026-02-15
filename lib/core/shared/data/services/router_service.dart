import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/author/presentation/pages/add_author_page.dart';
import '../../../../features/author/presentation/pages/author_detail_page.dart';
import '../../../../features/author/presentation/pages/author_list_page.dart';
import '../../../../features/book/presentation/pages/add_book_page.dart';
import '../../../../features/book/presentation/pages/book_detail_page.dart';
import '../../../../features/book/presentation/pages/book_list_page.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../../../features/publisher/presentation/pages/add_publisher_page.dart';
import '../../../../features/publisher/presentation/pages/publisher_detail_page.dart';
import '../../../../features/publisher/presentation/pages/publisher_list_page.dart';
import '../../../../features/reader/presentation/pages/add_reader_page.dart';
import '../../../../features/reader/presentation/pages/reader_detail_page.dart';
import '../../../../features/reader/presentation/pages/reader_list_page.dart';
import '../../../../features/sequence/presentation/pages/add_sequence_page.dart';
import '../../../../features/sequence/presentation/pages/sequence_detail_page.dart';
import '../../../../features/sequence/presentation/pages/sequence_list_page.dart';
import '../../../../features/translator/presentation/pages/add_translator_page.dart';
import '../../../../features/translator/presentation/pages/translator_detail_page.dart';
import '../../../../features/translator/presentation/pages/translator_list_page.dart';
import '../../../../features/work/presentation/pages/add_work_page.dart';
import '../../../../features/work/presentation/pages/work_detail_page.dart';
import '../../../../features/work/presentation/pages/work_list_page.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/login_page.dart';

class RouterService {
  GoRouter createRouter(AsyncValue<UserEntity?> authStateAsync) => GoRouter(
    initialLocation: '/',
    routes: _routes,
    redirect: (BuildContext context, GoRouterState state) => _redirect(authStateAsync, state),
  );

  List<RouteBase> get _routes => <RouteBase>[
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
              builder: (BuildContext context, GoRouterState state) => const AddWorkPage(),
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
              builder: (BuildContext context, GoRouterState state) => const AddBookPage(),
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
              builder: (BuildContext context, GoRouterState state) => const AddAuthorPage(),
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
              builder: (BuildContext context, GoRouterState state) => const AddTranslatorPage(),
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
              builder: (BuildContext context, GoRouterState state) => const AddPublisherPage(),
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
              builder: (BuildContext context, GoRouterState state) => const AddSequencePage(),
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
              builder: (BuildContext context, GoRouterState state) => const AddReaderPage(),
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

  String? _redirect(AsyncValue<UserEntity?> authState, GoRouterState state) {
    if (authState.isLoading) {
      return null;
    }

    final bool isLoggedIn = authState.value != null;
    final bool isLoggingIn = state.uri.toString() == '/login';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }

    return null;
  }
}
