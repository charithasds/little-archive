import 'package:flutter/material.dart';

class AuthorDetailPage extends StatelessWidget {
  final String authorId;
  const AuthorDetailPage({super.key, required this.authorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Author Details')),
      body: Center(child: Text('Author ID: $authorId')),
    );
  }
}
