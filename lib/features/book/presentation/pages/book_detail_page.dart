import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  const BookDetailPage({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Book Details')),
    body: Center(child: Text('Book ID: $bookId')),
  );
}
