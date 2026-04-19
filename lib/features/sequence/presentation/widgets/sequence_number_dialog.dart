import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';

class SequenceNumberDialog extends StatefulWidget {
  const SequenceNumberDialog({super.key, this.initialValue, this.sequenceName});

  final String? initialValue;
  final String? sequenceName;

  @override
  State<SequenceNumberDialog> createState() => _SequenceNumberDialogState();
}

class _SequenceNumberDialogState extends State<SequenceNumberDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          widget.sequenceName != null
              ? 'Enter Volume Number for ${widget.sequenceName}'
              : 'Enter Sequence Number',
        ),
    content: FormTextField(
      controller: _controller,
      label: 'Sequence Number',
      hint: '1, 2.5, ...',
      prefixIcon: Icons.format_list_numbered_rounded,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autofocus: true,
    ),
    actions: <Widget>[
      TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
      FilledButton(onPressed: () => context.pop(_controller.text.trim()), child: const Text('OK')),
    ],
  );
}
