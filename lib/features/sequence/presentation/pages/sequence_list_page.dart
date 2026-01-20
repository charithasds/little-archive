import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sequence_provider.dart';
import '../widgets/sequence_list_tile.dart';
import 'sequence_detail_page.dart';

class SequenceListPage extends ConsumerWidget {
  const SequenceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sequencesAsync = ref.watch(sequencesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sequences')),
      body: sequencesAsync.when(
        data: (sequences) {
          if (sequences.isEmpty) {
            return const Center(child: Text('No sequences found.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.separated(
                  itemCount: sequences.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sequence = sequences[index];
                    return SequenceListTile(
                      sequence: sequence,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SequenceDetailPage(sequenceId: sequence.id),
                        ),
                      ),
                      onDelete: () => ref
                          .read(sequenceRepositoryProvider)
                          .deleteSequence(sequence.id),
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
                  itemCount: sequences.length,
                  itemBuilder: (context, index) {
                    final sequence = sequences[index];
                    return Card(
                      child: SequenceListTile(
                        sequence: sequence,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SequenceDetailPage(sequenceId: sequence.id),
                          ),
                        ),
                        onDelete: () => ref
                            .read(sequenceRepositoryProvider)
                            .deleteSequence(sequence.id),
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
