import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translator_provider.dart';
import '../widgets/translator_list_tile.dart';
import 'translator_detail_page.dart';

class TranslatorListPage extends ConsumerWidget {
  const TranslatorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translatorsAsync = ref.watch(translatorsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Translators')),
      body: translatorsAsync.when(
        data: (translators) {
          if (translators.isEmpty) {
            return const Center(child: Text('No translators found.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.separated(
                  itemCount: translators.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final translator = translators[index];
                    return TranslatorListTile(
                      translator: translator,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TranslatorDetailPage(translatorId: translator.id),
                        ),
                      ),
                      onDelete: () => ref
                          .read(translatorRepositoryProvider)
                          .deleteTranslator(translator.id),
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
                  itemCount: translators.length,
                  itemBuilder: (context, index) {
                    final translator = translators[index];
                    return Card(
                      child: TranslatorListTile(
                        translator: translator,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TranslatorDetailPage(
                              translatorId: translator.id,
                            ),
                          ),
                        ),
                        onDelete: () => ref
                            .read(translatorRepositoryProvider)
                            .deleteTranslator(translator.id),
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
