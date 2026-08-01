import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../domain/entities/creator_entity.dart';
import '../providers/creator_mapping_controller.dart';
import '../providers/creator_provider.dart';

class CreatorMappingPage extends ConsumerWidget {
  const CreatorMappingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CreatorEntity>> unmappedTranslators = ref.watch(creatorMappingControllerProvider);
    final AsyncValue<List<CreatorEntity>> allCreators = ref.watch(creatorsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Translators to Creators'),
      ),
      body: unmappedTranslators.when(
        data: (List<CreatorEntity> translators) {
          if (translators.isEmpty) {
            return const Center(child: Text('No unmapped translators found.'));
          }

          return ListView.builder(
            itemCount: translators.length,
            itemBuilder: (BuildContext context, int index) {
              final CreatorEntity translator = translators[index];
              return ListTile(
                title: Text(translator.name),
                subtitle: Text(translator.id),
                trailing: allCreators.when(
                  data: (List<CreatorEntity> creators) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          _confirmKeepAsIs(context, ref, translator);
                        },
                        child: const Text('Keep as is'),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        hint: const Text('Map to...'),
                        items: creators.map((CreatorEntity creator) => DropdownMenuItem<String>(
                            value: creator.id,
                            child: Text(creator.name),
                          )).toList(),
                        onChanged: (String? newCreatorId) {
                          if (newCreatorId != null) {
                            _confirmMapping(context, ref, translator, creators.firstWhere((CreatorEntity c) => c.id == newCreatorId));
                          }
                        },
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (Object e, StackTrace s) => const Icon(Icons.error),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _confirmMapping(BuildContext context, WidgetRef ref, CreatorEntity translator, CreatorEntity creator) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: const Text('Confirm Mapping'),
          content: Text('Are you sure you want to map "${translator.name}" to "${creator.name}"?\nThis will update all books and works translated by this person.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Map'),
            ),
          ],
        ),
    );

    if (confirm ?? false) {
      await ref.read(creatorMappingControllerProvider.notifier).mapTranslator(translator.id, creator.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully mapped ${translator.name} to ${creator.name}.')),
        );
      }
    }
  }

  Future<void> _confirmKeepAsIs(BuildContext context, WidgetRef ref, CreatorEntity translator) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: const Text('Confirm Keep As Is'),
          content: Text('Are you sure you want to keep "${translator.name}" as a distinct creator?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Keep'),
            ),
          ],
        ),
    );

    if (confirm ?? false) {
      await ref.read(creatorMappingControllerProvider.notifier).keepTranslatorAsIs(translator.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully kept ${translator.name} as a distinct creator.')),
        );
      }
    }
  }
}
