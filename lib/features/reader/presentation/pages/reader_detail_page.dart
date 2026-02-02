import 'package:flutter/material.dart';

class ReaderDetailPage extends StatelessWidget {
  const ReaderDetailPage({super.key, required this.readerId});
  final String readerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reader Details')),
      body: Center(child: Text('Reader ID: $readerId')),
    );
  }
}
