import 'package:flutter/material.dart';

class PublisherDetailPage extends StatelessWidget {
  final String publisherId;
  const PublisherDetailPage({super.key, required this.publisherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publisher Details')),
      body: Center(child: Text('Publisher ID: $publisherId')),
    );
  }
}
