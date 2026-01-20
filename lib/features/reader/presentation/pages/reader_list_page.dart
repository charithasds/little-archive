import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reader_provider.dart';
import '../widgets/reader_list_tile.dart';
import 'reader_detail_page.dart';

class ReaderListPage extends ConsumerWidget {
  const ReaderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readersAsync = ref.watch(readersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Readers')),
      body: readersAsync.when(
        data: (readers) {
          if (readers.isEmpty) {
            return const Center(child: Text('No readers found.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.separated(
                  itemCount: readers.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final reader = readers[index];
                    return ReaderListTile(
                      reader: reader,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderDetailPage(readerId: reader.id),
                        ),
                      ),
                      onDelete: () => ref
                          .read(readerRepositoryProvider)
                          .deleteReader(reader.id),
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
                  itemCount: readers.length,
                  itemBuilder: (context, index) {
                    final reader = readers[index];
                    return Card(
                      child: ReaderListTile(
                        reader: reader,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReaderDetailPage(readerId: reader.id),
                          ),
                        ),
                        onDelete: () => ref
                            .read(readerRepositoryProvider)
                            .deleteReader(reader.id),
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
