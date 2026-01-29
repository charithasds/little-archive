import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_archive/features/book/presentation/providers/book_provider.dart';
import 'package:little_archive/features/author/presentation/providers/author_provider.dart';
import 'package:little_archive/features/translator/presentation/providers/translator_provider.dart';
import 'package:little_archive/features/publisher/presentation/providers/publisher_provider.dart';
import 'package:little_archive/features/sequence/presentation/providers/sequence_provider.dart';
import 'package:little_archive/features/reader/presentation/providers/reader_provider.dart';
import 'package:little_archive/features/work/presentation/providers/work_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksStreamProvider);
    final worksAsync = ref.watch(worksStreamProvider);
    final authorsAsync = ref.watch(authorsStreamProvider);
    final translatorsAsync = ref.watch(translatorsStreamProvider);
    final publishersAsync = ref.watch(publishersStreamProvider);
    final sequencesAsync = ref.watch(sequencesStreamProvider);
    final readersAsync = ref.watch(readersStreamProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use consistent aspect ratio to prevent overflow
        final isLargeScreen = constraints.maxWidth >= 600;
        const aspectRatio = 0.95; // Slightly taller than wide for content

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isLargeScreen ? 220 : 200,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                delegate: SliverChildListDelegate([
                  _DashboardCard(
                    title: 'Books',
                    icon: Icons.book_rounded,
                    gradient: [
                      colorScheme.primaryContainer,
                      colorScheme.primary,
                    ],
                    iconColor: colorScheme.onPrimary,
                    count: booksAsync.when(
                      data: (d) => d.length,
                      loading: () => null,
                      error: (err, stack) => 0,
                    ),
                    onTap: () => context.go('/books'),
                  ),
                  _DashboardCard(
                    title: 'Works',
                    icon: Icons.article_rounded,
                    gradient: [
                      colorScheme.secondaryContainer,
                      colorScheme.secondary,
                    ],
                    iconColor: colorScheme.onSecondary,
                    count: worksAsync.when(
                      data: (d) => d.length,
                      loading: () => null,
                      error: (err, stack) => 0,
                    ),
                    onTap: () => context.go('/works'),
                  ),
                  _DashboardCard(
                    title: 'Authors',
                    icon: Icons.person_rounded,
                    gradient: [
                      colorScheme.tertiaryContainer,
                      colorScheme.tertiary,
                    ],
                    iconColor: colorScheme.onTertiary,
                    count: authorsAsync.when(
                      data: (d) => d.length,
                      loading: () => null,
                      error: (err, stack) => 0,
                    ),
                    onTap: () => context.go('/authors'),
                  ),
                  _DashboardCard(
                    title: 'Translators',
                    icon: Icons.translate_rounded,
                    gradient: [
                      colorScheme.primaryContainer,
                      colorScheme.primary,
                    ],
                    iconColor: colorScheme.onPrimary,
                    count: translatorsAsync.when(
                      data: (d) => d.length,
                      loading: () => null,
                      error: (err, stack) => 0,
                    ),
                    onTap: () => context.go('/translators'),
                  ),
                  _DashboardCard(
                    title: 'Publishers',
                    icon: Icons.business_rounded,
                    gradient: [
                      colorScheme.secondaryContainer,
                      colorScheme.secondary,
                    ],
                    iconColor: colorScheme.onSecondary,
                    count: publishersAsync.when(
                      data: (d) => d.length,
                      loading: () => null,
                      error: (err, stack) => 0,
                    ),
                    onTap: () => context.go('/publishers'),
                  ),
                  _DashboardCard(
                    title: 'Sequences',
                    icon: Icons.layers_rounded,
                    gradient: [
                      colorScheme.tertiaryContainer,
                      colorScheme.tertiary,
                    ],
                    iconColor: colorScheme.onTertiary,
                    count: sequencesAsync.when(
                      data: (d) => d.length,
                      loading: () => null,
                      error: (err, stack) => 0,
                    ),
                    onTap: () => context.go('/sequences'),
                  ),
                  _DashboardCard(
                    title: 'Readers',
                    icon: Icons.face_rounded,
                    gradient: [
                      colorScheme.primaryContainer,
                      colorScheme.primary,
                    ],
                    iconColor: colorScheme.onPrimary,
                    count: readersAsync.when(
                      data: (d) => d.length,
                      loading: () => null,
                      error: (err, stack) => 0,
                    ),
                    onTap: () => context.go('/readers'),
                  ),
                ]),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;
  final int? count;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradient[0].withValues(alpha: 0.3),
                gradient[1].withValues(alpha: 0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[1].withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Spacer(),
              // Count
              if (count != null)
                Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                )
              else
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: gradient[1],
                  ),
                ),
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
