import 'package:flutter/material.dart';

class WorkDetailPage extends StatelessWidget {
  const WorkDetailPage({super.key, required this.workId});
  final String workId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Work Details')),
    body: Center(child: Text('Work ID: $workId')),
  );
}
