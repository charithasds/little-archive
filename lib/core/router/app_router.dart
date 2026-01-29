import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';

import '../../features/work/presentation/pages/add_work_page.dart';
import '../../features/work/presentation/pages/work_detail_page.dart';
import '../../features/work/presentation/pages/work_list_page.dart';

import '../../features/book/presentation/pages/add_book_page.dart';
import '../../features/book/presentation/pages/book_detail_page.dart';
import '../../features/book/presentation/pages/book_list_page.dart';

import '../../features/author/presentation/pages/author_detail_page.dart';
import '../../features/author/presentation/pages/author_list_page.dart';
import '../../features/author/presentation/pages/add_author_page.dart';

import '../../features/translator/presentation/pages/translator_detail_page.dart';
import '../../features/translator/presentation/pages/translator_list_page.dart';
import '../../features/translator/presentation/pages/add_translator_page.dart';

import '../../features/publisher/presentation/pages/publisher_detail_page.dart';
import '../../features/publisher/presentation/pages/publisher_list_page.dart';
import '../../features/publisher/presentation/pages/add_publisher_page.dart';

import '../../features/sequence/presentation/pages/sequence_detail_page.dart';
import '../../features/sequence/presentation/pages/sequence_list_page.dart';
import '../../features/sequence/presentation/pages/add_sequence_page.dart';

import '../../features/reader/presentation/pages/reader_detail_page.dart';
import '../../features/reader/presentation/pages/reader_list_page.dart';
import '../../features/reader/presentation/pages/add_reader_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          // WORKS
          GoRoute(
            path: 'works',
            builder: (context, state) => const WorkListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddWorkPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return WorkDetailPage(workId: id);
                },
              ),
            ],
          ),

          // BOOKS
          GoRoute(
            path: 'books',
            builder: (context, state) => const BookListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddBookPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BookDetailPage(bookId: id);
                },
              ),
            ],
          ),

          // AUTHORS
          GoRoute(
            path: 'authors',
            builder: (context, state) => const AuthorListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddAuthorPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AuthorDetailPage(authorId: id);
                },
              ),
            ],
          ),

          // TRANSLATORS
          GoRoute(
            path: 'translators',
            builder: (context, state) => const TranslatorListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddTranslatorPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TranslatorDetailPage(translatorId: id);
                },
              ),
            ],
          ),

          // PUBLISHERS
          GoRoute(
            path: 'publishers',
            builder: (context, state) => const PublisherListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddPublisherPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PublisherDetailPage(publisherId: id);
                },
              ),
            ],
          ),

          // SEQUENCES
          GoRoute(
            path: 'sequences',
            builder: (context, state) => const SequenceListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddSequencePage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return SequenceDetailPage(sequenceId: id);
                },
              ),
            ],
          ),

          // READERS
          GoRoute(
            path: 'readers',
            builder: (context, state) => const ReaderListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddReaderPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ReaderDetailPage(readerId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
  );
});
