import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_circle_image.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/sequence_entity.dart';
import '../providers/sequence_provider.dart';

class SequenceQuickInfoDialog extends ConsumerWidget {
  const SequenceQuickInfoDialog({super.key, required this.sequenceId});

  final String sequenceId;

  static void show(BuildContext context, String sequenceId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => SequenceQuickInfoDialog(sequenceId: sequenceId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final AsyncValue<SequenceEntity?> async = ref.watch(sequenceProvider(sequenceId));

    final Widget content = async.when(
      data: (SequenceEntity? sequence) {
        if (sequence == null) {
          return const Text('Sequence not found');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const InfoDialogCircleImage(icon: Icons.layers_rounded),
            const SizedBox(height: 16),
            Text(sequence.name, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (sequence.otherName != null && sequence.otherName!.isNotEmpty)
              Text(
                sequence.otherName!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Divider(height: 32),
            DetailTile(
              label: 'Volumes Count',
              value: '${sequence.sequenceVolumeIds.length} volumes',
              leadingIcon: Icons.layers_rounded,
            ),
            InfoDialogMetadata(created: sequence.createdDate, updated: sequence.lastUpdated),
          ],
        );
      },
      loading: () => const InfoDialogLoading(),
      error: (Object e, _) => Text('Error: $e'),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Sequence Info'),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
