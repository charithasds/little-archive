import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../domain/entities/translator_entity.dart';
import 'translator_provider.dart';

class UpsertTranslatorState {
  const UpsertTranslatorState({this.isLoading = false, this.error, this.pickedBase64Image});

  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertTranslatorState copyWith({
    bool? isLoading,
    String? error,
    String? pickedBase64Image,
    bool clearImage = false,
  }) => UpsertTranslatorState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    pickedBase64Image: clearImage ? null : (pickedBase64Image ?? this.pickedBase64Image),
  );
}

class UpsertTranslatorController extends Notifier<UpsertTranslatorState> {
  @override
  UpsertTranslatorState build() => const UpsertTranslatorState();

  void initializeWith(TranslatorEntity? translator) {
    if (translator != null && translator.image != null) {
      state = state.copyWith(pickedBase64Image: translator.image);
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      state = state.copyWith(pickedBase64Image: base64Encode(bytes));
    }
  }

  void clearImage() {
    state = state.copyWith(clearImage: true);
  }

  Future<TranslatorEntity?> saveTranslator({
    required TranslatorEntity? existingTranslator,
    required String name,
    required String otherName,
    required String website,
    required String facebook,
  }) async {
    state = state.copyWith(isLoading: true);

    final UserEntity? user = ref.read(authStateProvider).value;

    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return null;
    }

    final String generatedId = ref.read(translatorRepositoryProvider).generateId();

    final TranslatorEntity translatorToSave = existingTranslator != null
        ? existingTranslator.copyWith(
            name: name,
            otherName: Nullable<String?>(otherName.isEmpty ? null : otherName),
            website: Nullable<String?>(website.isEmpty ? null : website),
            facebook: Nullable<String?>(facebook.isEmpty ? null : facebook),
            image: Nullable<String?>(state.pickedBase64Image),
            lastUpdated: DateTime.now(),
          )
        : TranslatorEntity(
            id: generatedId,
            name: name,
            otherName: otherName.isEmpty ? null : otherName,
            website: website.isEmpty ? null : website,
            facebook: facebook.isEmpty ? null : facebook,
            image: state.pickedBase64Image,
            bookIds: const <String>[],
            workIds: const <String>[],
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

    try {
      if (existingTranslator != null) {
        await ref.read(updateTranslatorUseCaseProvider)(translatorToSave);
      } else {
        await ref.read(addTranslatorUseCaseProvider)(translatorToSave);
      }

      state = state.copyWith(isLoading: false);

      return translatorToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error saving translator: $e');
      return null;
    }
  }
}

final NotifierProvider<UpsertTranslatorController, UpsertTranslatorState>
upsertTranslatorControllerProvider =
    NotifierProvider<UpsertTranslatorController, UpsertTranslatorState>(
      UpsertTranslatorController.new,
    );
