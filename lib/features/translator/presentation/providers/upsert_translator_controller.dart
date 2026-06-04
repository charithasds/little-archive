import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/usecases/translator_usecases.dart';
import 'translator_provider.dart';

part 'upsert_translator_controller.g.dart';

class UpsertTranslatorState {
  const UpsertTranslatorState({
    this.existingTranslator,
    this.isLoading = false,
    this.error,
    this.pickedBase64Image,
  });

  final TranslatorEntity? existingTranslator;
  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertTranslatorState copyWith({
    Nullable<TranslatorEntity?>? existingTranslator,
    bool? isLoading,
    Nullable<String?>? error,
    Nullable<String?>? pickedBase64Image,
  }) => UpsertTranslatorState(
    existingTranslator: existingTranslator != null
        ? existingTranslator.value
        : this.existingTranslator,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
    pickedBase64Image: pickedBase64Image != null ? pickedBase64Image.value : this.pickedBase64Image,
  );
}

@riverpod
class UpsertTranslatorController extends _$UpsertTranslatorController {
  @override
  UpsertTranslatorState build() => const UpsertTranslatorState();

  void initializeWith(TranslatorEntity? translator) {
    state = UpsertTranslatorState(
      existingTranslator: translator,
      pickedBase64Image: translator?.image,
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      state = state.copyWith(pickedBase64Image: Nullable<String?>(base64Encode(bytes)));
    }
  }

  void clearImage() {
    state = state.copyWith(pickedBase64Image: const Nullable<String?>(null));
  }

  Future<TranslatorEntity?> saveTranslator({
    required String name,
    String? otherName,
    String? website,
    String? facebook,
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));



    final TranslatorEntity? existingTranslator = state.existingTranslator;
    final String generatedId = ref.read(generateTranslatorIdUseCaseProvider)();

    TranslatorEntity translatorToSave = existingTranslator != null
        ? existingTranslator.copyWith(
            name: name,
            otherName: Nullable<String?>(otherName?.isEmpty ?? true ? null : otherName),
            website: Nullable<String?>(website?.isEmpty ?? true ? null : website),
            facebook: Nullable<String?>(facebook?.isEmpty ?? true ? null : facebook),
            image: Nullable<String?>(state.pickedBase64Image),
            lastUpdated: DateTime.now(),
          )
        : TranslatorEntity(
            id: generatedId,
            name: name,
            otherName: otherName?.isEmpty ?? true ? null : otherName,
            website: website?.isEmpty ?? true ? null : website,
            facebook: facebook?.isEmpty ?? true ? null : facebook,
            image: state.pickedBase64Image,
            bookIds: const <String>[],
            workIds: const <String>[],
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

    try {
      if (existingTranslator != null) {
        try {
          await ref.read(editTranslatorUseCaseProvider)(translatorToSave);
        } catch (e) {
          if (e.toString().contains('longer than 1048487 bytes')) {
            final String? compressedImage = Images.compressImageIfNeeded(state.pickedBase64Image);
            translatorToSave = translatorToSave.copyWith(image: Nullable<String?>(compressedImage));
            await ref.read(editTranslatorUseCaseProvider)(translatorToSave);
          } else {
            rethrow;
          }
        }
      } else {
        try {
          await ref.read(addTranslatorUseCaseProvider)(translatorToSave);
        } catch (e) {
          if (e.toString().contains('longer than 1048487 bytes')) {
            final String? compressedImage = Images.compressImageIfNeeded(state.pickedBase64Image);
            translatorToSave = translatorToSave.copyWith(image: Nullable<String?>(compressedImage));
            await ref.read(addTranslatorUseCaseProvider)(translatorToSave);
          } else {
            rethrow;
          }
        }
      }

      state = state.copyWith(isLoading: false);
      ref.invalidate(translatorCountProvider);
      return translatorToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: Nullable<String?>('Error saving translator: $e'),
      );
      return null;
    }
  }
}
