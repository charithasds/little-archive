import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/publisher_provider.dart';
import '../widgets/publisher_list_tile.dart';
import 'publisher_detail_page.dart';

class PublisherListPage extends ConsumerWidget {
  const PublisherListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishersAsync = ref.watch(publishersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Publishers')),
      body: publishersAsync.when(
        data: (publishers) {
          if (publishers.isEmpty) {
            return const Center(child: Text('No publishers found.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.separated(
                  itemCount: publishers.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final publisher = publishers[index];
                    return PublisherListTile(
                      publisher: publisher,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PublisherDetailPage(publisherId: publisher.id),
                        ),
                      ),
                      onDelete: () => ref
                          .read(publisherRepositoryProvider)
                          .deletePublisher(publisher.id),
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
                  itemCount: publishers.length,
                  itemBuilder: (context, index) {
                    final publisher = publishers[index];
                    return Card(
                      child: PublisherListTile(
                        publisher: publisher,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PublisherDetailPage(publisherId: publisher.id),
                          ),
                        ),
                        onDelete: () => ref
                            .read(publisherRepositoryProvider)
                            .deletePublisher(publisher.id),
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
