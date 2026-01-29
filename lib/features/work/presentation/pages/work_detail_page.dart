import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/work_provider.dart';
import '../../domain/entities/work_entity.dart';

class WorkDetailPage extends ConsumerWidget {
  final String workId;

  const WorkDetailPage({super.key, required this.workId});

  Future<void> _editTitle(
    BuildContext context,
    WidgetRef ref,
    WorkEntity work,
  ) async {
    final controller = TextEditingController(text: work.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Title'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != work.title) {
      final updated = work.copyWith(title: newTitle);
      await ref.read(workRepositoryProvider).updateWork(updated);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(worksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Work Details')),
      body: worksAsync.when(
        data: (works) {
          WorkEntity? work;
          try {
            work = works.firstWhere((s) => s.id == workId);
          } catch (e) {
            work = null;
          }

          if (work == null) return const Center(child: Text('Work not found'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Title'),
                subtitle: Text(
                  work.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editTitle(context, ref, work!),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Genre'),
                subtitle: Text(work.genre.clientValue),
              ),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(work.language.clientValue),
              ),
              ListTile(
                title: const Text('Pages'),
                subtitle: Text('${work.noOfPages ?? 0}'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: Text(work.notes ?? 'No notes'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
