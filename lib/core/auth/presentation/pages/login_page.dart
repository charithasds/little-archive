import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/expressive_page_layout.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return ExpressivePageLayout(
      title: 'Little Archive',
      description: 'Your personal library companion',
      content: const GoogleSignInButton(),
      secondaryContent: Text(
        'Keep your library in sync across all your devices.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
