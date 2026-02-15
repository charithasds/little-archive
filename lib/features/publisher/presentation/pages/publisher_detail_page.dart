import 'package:flutter/material.dart';

class PublisherDetailPage extends StatelessWidget {
  const PublisherDetailPage({super.key, required this.publisherId});
  final String publisherId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Publisher Details')),
    body: Center(child: Text('Publisher ID: $publisherId')),
  );
}
