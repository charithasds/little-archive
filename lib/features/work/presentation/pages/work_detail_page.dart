import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/widgets/snackbar_utils.dart';
import '../../domain/entities/work_entity.dart';
import '../providers/work_provider.dart';

class WorkDetailPage extends ConsumerWidget {
  const WorkDetailPage({super.key, required this.workId});
  final String workId;

  Future<void> _editTitle(BuildContext context, WidgetRef ref, WorkEntity work) async {
    final TextEditingController controller = TextEditingController(text: work.title);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final String? newTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Edit Title'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (String? v) => v == null || v.isEmpty ? 'Title is required' : null,
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != work.title) {
      try {
        final WorkEntity updated = work.copyWith(title: newTitle);
        await ref.read(workRepositoryProvider).updateWork(updated);
        if (context.mounted) {
          SnackBarUtils.showSuccess(context, 'Title updated');
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarUtils.showError(context, 'Update failed: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Work Details')),
      body: worksAsync.when(
        data: (List<WorkEntity> works) {
          WorkEntity? work;
          try {
            work = works.firstWhere((WorkEntity s) => s.id == workId);
          } catch (e) {
            work = null;
          }

          if (work == null) {
            return const Center(child: Text('Work not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ListTile(
                title: const Text('Title'),
                subtitle: Text(work.title, style: Theme.of(context).textTheme.headlineSmall),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editTitle(context, ref, work!),
                ),
              ),
              const Divider(),
              ListTile(title: const Text('Genre'), subtitle: Text(work.genre.clientValue)),
              ListTile(title: const Text('Language'), subtitle: Text(work.language.clientValue)),
              ListTile(title: const Text('Pages'), subtitle: Text('${work.noOfPages ?? 0}')),
              const SizedBox(height: 16),
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: Text(work.notes ?? 'No notes'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
