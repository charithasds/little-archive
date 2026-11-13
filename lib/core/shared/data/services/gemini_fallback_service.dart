import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

/// Runs Gemini requests through an ordered model chain with a hard timeout
/// per attempt. Recoverable failures (timeouts, quota / rate limits, server
/// overload, retired models) cascade to the next model; fatal client errors
/// (invalid argument, blocked prompt) are rethrown immediately.
class GeminiFallbackService {
  const GeminiFallbackService({
    this.modelChain = defaultModelChain,
    this.modelTimeout = const Duration(seconds: 20),
  });

  /// Ordered hierarchy: Primary Flash -> Secondary Flash -> Lite 1 -> Lite 2.
  static const List<String> defaultModelChain = <String>[
    'gemini-3.8-flash',
    'gemini-3.6-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
  ];

  final List<String> modelChain;

  /// Image / multimodal requests need a longer window (upload + tokenization).
  final Duration modelTimeout;

  /// Executes content generation with automatic timeout and fallback.
  /// Returns the response text of the first model that succeeds.
  Future<String> generateWithFallback({
    required List<Content> prompt,
    GenerationConfig? generationConfig,
  }) async {
    Object? lastError;

    for (int i = 0; i < modelChain.length; i++) {
      final String modelName = modelChain[i];
      final bool isLast = i == modelChain.length - 1;

      try {
        final GenerativeModel model = FirebaseAI.googleAI().generativeModel(
          model: modelName,
          generationConfig: generationConfig,
        );

        // Enforce a hard timeout on the request.
        final GenerateContentResponse response = await model
            .generateContent(prompt)
            .timeout(modelTimeout);

        final String? text = response.text;
        if (text != null && text.isNotEmpty) {
          return text;
        }

        debugPrint('[$modelName] returned an empty response. Falling back...');
        lastError = Exception('[$modelName] returned an empty response.');
      } on TimeoutException catch (e) {
        debugPrint(
          '[$modelName] timed out after ${modelTimeout.inSeconds}s. Falling back...',
        );
        lastError = e;
      } on FirebaseAIException catch (e) {
        if (!_isRecoverable(e.message)) {
          // Fatal client error (e.g. 400 invalid argument / blocked prompt):
          // a fallback model would fail the same way.
          rethrow;
        }
        debugPrint('[$modelName] failed (${e.message}). Cascading to next model...');
        lastError = e;
      } catch (e) {
        debugPrint('[$modelName] encountered unexpected error: $e');
        if (isLast) {
          rethrow;
        }
        lastError = e;
      }
    }

    throw Exception('All Gemini models in fallback chain failed. Last error: $lastError');
  }

  static bool _isRecoverable(String message) {
    final String msg = message.toLowerCase();
    final bool isQuota =
        msg.contains('429') ||
        msg.contains('resource_exhausted') ||
        msg.contains('quota') ||
        msg.contains('rate limit');
    final bool isUnavailable =
        msg.contains('503') || msg.contains('unavailable') || msg.contains('overloaded');
    final bool isServerError = msg.contains('500') || msg.contains('internal');
    // A model that was retired or renamed should not break the chain.
    final bool isModelMissing = msg.contains('404') || msg.contains('not found');
    return isQuota || isUnavailable || isServerError || isModelMissing;
  }
}
