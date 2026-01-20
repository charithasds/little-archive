import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_archive/features/book/presentation/pages/book_list_page.dart';
import 'package:little_archive/features/short/presentation/pages/short_list_page.dart';
import 'package:little_archive/features/author/presentation/pages/author_list_page.dart';
import 'package:little_archive/features/translator/presentation/pages/translator_list_page.dart';
import 'package:little_archive/features/publisher/presentation/pages/publisher_list_page.dart';
import 'package:little_archive/features/sequence/presentation/pages/sequence_list_page.dart';
import 'package:little_archive/features/reader/presentation/pages/reader_list_page.dart';
import 'package:little_archive/features/book/presentation/providers/book_provider.dart';
import 'package:little_archive/features/short/presentation/providers/short_provider.dart';
import 'package:little_archive/features/author/presentation/providers/author_provider.dart';
import 'package:little_archive/features/translator/presentation/providers/translator_provider.dart';
import 'package:little_archive/features/publisher/presentation/providers/publisher_provider.dart';
import 'package:little_archive/features/sequence/presentation/providers/sequence_provider.dart';
import 'package:little_archive/features/reader/presentation/providers/reader_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksStreamProvider);
    final shortsAsync = ref.watch(shortsStreamProvider);
    final authorsAsync = ref.watch(authorsStreamProvider);
    final translatorsAsync = ref.watch(translatorsStreamProvider);
    final publishersAsync = ref.watch(publishersStreamProvider);
    final sequencesAsync = ref.watch(sequencesStreamProvider);
    final readersAsync = ref.watch(readersStreamProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600
            ? 2
            : (constraints.maxWidth < 1200 ? 4 : 5);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _DashboardCard(
              title: 'Books',
              icon: Icons.book_rounded,
              count: booksAsync.when(
                data: (d) => d.length.toString(),
                loading: () => '...',
                error: (err, stack) => '0',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookListPage()),
              ),
            ),
            _DashboardCard(
              title: 'Short Stories',
              icon: Icons.article_rounded,
              count: shortsAsync.when(
                data: (d) => d.length.toString(),
                loading: () => '...',
                error: (err, stack) => '0',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShortListPage()),
              ),
            ),
            _DashboardCard(
              title: 'Authors',
              icon: Icons.person_rounded,
              count: authorsAsync.when(
                data: (d) => d.length.toString(),
                loading: () => '...',
                error: (err, stack) => '0',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthorListPage()),
              ),
            ),
            _DashboardCard(
              title: 'Translators',
              icon: Icons.translate_rounded,
              count: translatorsAsync.when(
                data: (d) => d.length.toString(),
                loading: () => '...',
                error: (err, stack) => '0',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TranslatorListPage()),
              ),
            ),
            _DashboardCard(
              title: 'Publishers',
              icon: Icons.business_rounded,
              count: publishersAsync.when(
                data: (d) => d.length.toString(),
                loading: () => '...',
                error: (err, stack) => '0',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PublisherListPage()),
              ),
            ),
            _DashboardCard(
              title: 'Sequences',
              icon: Icons.layers_rounded,
              count: sequencesAsync.when(
                data: (d) => d.length.toString(),
                loading: () => '...',
                error: (err, stack) => '0',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SequenceListPage()),
              ),
            ),
            _DashboardCard(
              title: 'Readers',
              icon: Icons.face_rounded,
              count: readersAsync.when(
                data: (d) => d.length.toString(),
                loading: () => '...',
                error: (err, stack) => '0',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReaderListPage()),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String count;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: $count',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
