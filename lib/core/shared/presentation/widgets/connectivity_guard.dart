import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';
import 'snackbar_utils.dart';

/// Extension on [WidgetRef] providing a connectivity guard for UI actions.
///
/// Usage — call [requireConnectivity] before any navigation or write that
/// needs the network. It returns `true` if online, `false` if offline
/// (and shows a warning snackbar automatically):
///
/// ```dart
/// Future<void> _onAddTap() async {
///   if (!await ref.requireConnectivity(context)) return;
///   context.go('/books/add');
/// }
/// ```
extension ConnectivityGuard on WidgetRef {
  /// Returns `true` when the device is online.
  ///
  /// When offline, shows a [SnackBarUtils.showWarning] and returns `false`.
  /// Uses a live [ConnectivityService.isConnected] check — not just the
  /// last stream value — so it is accurate at the time of the tap.
  Future<bool> requireConnectivity(BuildContext context) async {
    final bool isConnected = await read(connectivityServiceProvider).isConnected();

    if (!isConnected) {
      if (context.mounted) {
        SnackBarUtils.showWarning(
          context,
          'You are offline. Please check your connection and try again.',
        );
      }

      return false;
    }

    return true;
  }
}
