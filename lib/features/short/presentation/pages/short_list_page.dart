import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/short_provider.dart';
import '../widgets/short_list_tile.dart';
import 'short_detail_page.dart';

class ShortListPage extends ConsumerWidget {
  const ShortListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortsAsync = ref.watch(shortsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Short Stories')),
      body: shortsAsync.when(
        data: (shorts) {
          if (shorts.isEmpty) {
            return const Center(child: Text('No shorts found.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.separated(
                  itemCount: shorts.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final short = shorts[index];
                    return ShortListTile(
                      short: short,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShortDetailPage(shortId: short.id),
                        ),
                      ),
                      onDelete: () => ref
                          .read(shortRepositoryProvider)
                          .deleteShort(short.id),
                    );
                  },
                );
              } else {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: shorts.length,
                  itemBuilder: (context, index) {
                    final short = shorts[index];
                    return Card(
                      child: ShortListTile(
                        short: short,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShortDetailPage(shortId: short.id),
                          ),
                        ),
                        onDelete: () => ref
                            .read(shortRepositoryProvider)
                            .deleteShort(short.id),
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
        onPressed: () {
          // Add Short logic
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
