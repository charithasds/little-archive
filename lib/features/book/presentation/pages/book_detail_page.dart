import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/book_provider.dart';

class BookDetailPage extends ConsumerWidget {
  const BookDetailPage({super.key, required this.bookId});
  final String bookId;

  Future<void> _editTitle(BuildContext context, WidgetRef ref, BookEntity book) async {
    final TextEditingController controller = TextEditingController(text: book.title);
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

    if (newTitle != null && newTitle.isNotEmpty && newTitle != book.title) {
      try {
        final BookEntity updated = book.copyWith(title: newTitle);
        await ref.read(bookRepositoryProvider).updateBook(updated);
        if (context.mounted) {
          SnackBarUtils.showSuccess(context, 'Title updated');
        }
      } on NoConnectionException catch (e) {
        if (context.mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarUtils.showError(context, 'Update failed: $e');
        }
      }
    }
  }

  // Helper for other fields can be created similar to _editTitle

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: booksAsync.when(
        data: (List<BookEntity> books) {
          // Find book safely
          BookEntity? book;
          try {
            book = books.firstWhere((BookEntity b) => b.id == bookId);
          } catch (e) {
            book = null;
          }

          if (book == null) {
            return const Center(child: Text('Book not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ListTile(
                title: const Text('Title'),
                subtitle: Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editTitle(context, ref, book!),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Author(s)'),
                subtitle: Text(
                  book.authorIds.isEmpty ? 'None' : '${book.authorIds.length} Authors',
                ),
                trailing: const Icon(Icons.edit, size: 20), // Placeholder for edit logic
                onTap: () {
                  // Open Author selection dialog
                },
              ),
              ListTile(title: const Text('Genre'), subtitle: Text(book.genre.clientValue)),
              ListTile(title: const Text('Language'), subtitle: Text(book.language.clientValue)),
              ListTile(
                title: const Text('Status'),
                subtitle: Text(book.collectionStatus.clientValue),
              ),
              if (book.publishedDate != null)
                ListTile(
                  title: const Text('Published'),
                  subtitle: Text(DateFormat.yMMMd().format(book.publishedDate!)),
                ),
              const SizedBox(height: 16),
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: Text(book.notes ?? 'No notes'),
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
