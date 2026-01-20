import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/author_provider.dart';
import '../widgets/author_list_tile.dart';
import 'author_detail_page.dart';

class AuthorListPage extends ConsumerWidget {
  const AuthorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorsAsync = ref.watch(authorsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Authors')),
      body: authorsAsync.when(
        data: (authors) {
          if (authors.isEmpty) {
            return const Center(child: Text('No authors found.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.separated(
                  itemCount: authors.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final author = authors[index];
                    return AuthorListTile(
                      author: author,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuthorDetailPage(authorId: author.id),
                        ),
                      ),
                      onDelete: () => ref
                          .read(authorRepositoryProvider)
                          .deleteAuthor(author.id),
                    );
                  },
                );
              } else {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: authors.length,
                  itemBuilder: (context, index) {
                    final author = authors[index];
                    return Card(
                      child: AuthorListTile(
                        author: author,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AuthorDetailPage(authorId: author.id),
                          ),
                        ),
                        onDelete: () => ref
                            .read(authorRepositoryProvider)
                            .deleteAuthor(author.id),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
