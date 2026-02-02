import 'package:flutter/material.dart';

class AuthorDetailPage extends StatelessWidget {
  const AuthorDetailPage({super.key, required this.authorId});
  final String authorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Author Details')),
      body: Center(child: Text('Author ID: $authorId')),
    );
  }
}
