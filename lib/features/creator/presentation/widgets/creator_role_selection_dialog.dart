import 'package:flutter/material.dart';

class CreatorRoleSelectionDialog extends StatefulWidget {
  const CreatorRoleSelectionDialog({
    super.key,
    required this.itemTitle,
    this.initialIsTranslator = false,
  });

  final String itemTitle;
  final bool initialIsTranslator;

  static Future<bool?> show(
    BuildContext context, {
    required String itemTitle,
    bool initialIsTranslator = false,
  }) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CreatorRoleSelectionDialog(
          itemTitle: itemTitle,
          initialIsTranslator: initialIsTranslator,
        ),
      );

  @override
  State<CreatorRoleSelectionDialog> createState() => _CreatorRoleSelectionDialogState();
}

class _CreatorRoleSelectionDialogState extends State<CreatorRoleSelectionDialog> {
  late bool _isAuthor;
  late bool _isTranslator;

  @override
  void initState() {
    super.initState();
    _isTranslator = widget.initialIsTranslator;
    _isAuthor = !_isTranslator;
  }

  void _onAuthorChanged(bool value) {
    setState(() {
      _isAuthor = value;
      _isTranslator = !value;
    });
  }

  void _onTranslatorChanged(bool value) {
    setState(() {
      _isTranslator = value;
      _isAuthor = !value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Select Role',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.itemTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SwitchListTile(
            title: const Text('As Author'),
            value: _isAuthor,
            activeColor: colorScheme.primary,
            onChanged: _onAuthorChanged,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('As Translator'),
            value: _isTranslator,
            activeColor: colorScheme.secondary,
            onChanged: _onTranslatorChanged,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_isTranslator),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
