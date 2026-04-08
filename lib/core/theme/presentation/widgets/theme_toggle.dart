import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

/// A premium [IconButton] that toggles between light and dark modes.
///
/// Features a smooth rotation and scale transition when switching.
class ThemeToggle extends ConsumerWidget {
  /// Create a [ThemeToggle] widget.
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
    tooltip: ref.watch(themeModeProvider) == ThemeMode.dark
        ? 'Switch to Light Mode'
        : 'Switch to Dark Mode',
    icon: AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) => RotationTransition(
        turns: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: Icon(
        ref.watch(themeModeProvider) == ThemeMode.dark
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
        key: ValueKey<bool>(ref.watch(themeModeProvider) == ThemeMode.dark),
      ),
    ),
  );
}
