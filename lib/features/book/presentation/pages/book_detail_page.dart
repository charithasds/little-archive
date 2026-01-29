import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/exceptions.dart';
import '../providers/book_provider.dart';
import '../../domain/entities/book_entity.dart';

class BookDetailPage extends ConsumerWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  Future<void> _editTitle(
    BuildContext context,
    WidgetRef ref,
    BookEntity book,
  ) async {
    final controller = TextEditingController(text: book.title);
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

    if (newTitle != null && newTitle.isNotEmpty && newTitle != book.title) {
      try {
        final updated = book.copyWith(title: newTitle);
        await ref.read(bookRepositoryProvider).updateBook(updated);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Title updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on NoConnectionException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Helper for other fields can be created similar to _editTitle

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: booksAsync.when(
        data: (books) {
          // Find book safely
          BookEntity? book;
          try {
            book = books.firstWhere((b) => b.id == bookId);
          } catch (e) {
            book = null;
          }

          if (book == null) return const Center(child: Text('Book not found'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Title'),
                subtitle: Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editTitle(context, ref, book!),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Author(s)'),
                subtitle: Text(
                  book.authorIds.isEmpty
                      ? 'None'
                      : '${book.authorIds.length} Authors',
                ),
                trailing: const Icon(
                  Icons.edit,
                  size: 20,
                ), // Placeholder for edit logic
                onTap: () {
                  // Open Author selection dialog
                },
              ),
              ListTile(
                title: const Text('Genre'),
                subtitle: Text(book.genre.clientValue),
              ),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(book.language.clientValue),
              ),
              ListTile(
                title: const Text('Status'),
                subtitle: Text(book.collectionStatus.clientValue),
              ),
              if (book.publishedDate != null)
                ListTile(
                  title: const Text('Published'),
                  subtitle: Text(
                    DateFormat.yMMMd().format(book.publishedDate!),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: Text(book.notes ?? 'No notes'),
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
