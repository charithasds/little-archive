import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/usecases/creator_usecases.dart';

part 'upsert_creator_controller.g.dart';

class UpsertCreatorState {
  const UpsertCreatorState({
    this.existingCreator,
    this.isLoading = false,
    this.error,
    this.pickedBase64Image,
  });

  final CreatorEntity? existingCreator;
  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertCreatorState copyWith({
    Nullable<CreatorEntity?>? existingCreator,
    bool? isLoading,
    Nullable<String?>? error,
    Nullable<String?>? pickedBase64Image,
  }) => UpsertCreatorState(
    existingCreator: existingCreator != null ? existingCreator.value : this.existingCreator,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
    pickedBase64Image: pickedBase64Image != null ? pickedBase64Image.value : this.pickedBase64Image,
  );
}

@riverpod
class UpsertCreatorController extends _$UpsertCreatorController {
  @override
  UpsertCreatorState build() => const UpsertCreatorState();

  void initializeWith(CreatorEntity? creator) {
    state = UpsertCreatorState(existingCreator: creator, pickedBase64Image: creator?.image);
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      final String rawBase64 = base64Encode(bytes);
      final String compressed = Images.compressImageIfNeeded(rawBase64) ?? rawBase64;
      state = state.copyWith(pickedBase64Image: Nullable<String?>(compressed));
    }
  }

  void clearImage() {
    state = state.copyWith(pickedBase64Image: const Nullable<String?>(null));
  }

  Future<CreatorEntity?> saveCreator({
    required String name,
    String? otherName,
    String? website,
    String? facebook,
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));

    await Future<void>.delayed(Duration.zero);

    final CreatorEntity? existingCreator = state.existingCreator;
    final String generatedId = ref.read(generateCreatorIdUseCaseProvider)();

    // Eagerly compress the image if it exists to prevent SQLite OOM and large documents.
    final String? compressedImage = Images.compressImageIfNeeded(state.pickedBase64Image);
    if (compressedImage != state.pickedBase64Image) {
      state = state.copyWith(pickedBase64Image: Nullable<String?>(compressedImage));
    }

    final CreatorEntity creatorToSave = existingCreator != null
        ? existingCreator.copyWith(
            name: name,
            otherName: Nullable<String?>(otherName?.isEmpty ?? true ? null : otherName),
            website: Nullable<String?>(website?.isEmpty ?? true ? null : website),
            facebook: Nullable<String?>(facebook?.isEmpty ?? true ? null : facebook),
            image: Nullable<String?>(compressedImage),
            lastUpdated: DateTime.now(),
          )
        : CreatorEntity(
            id: generatedId,
            name: name,
            otherName: otherName?.isEmpty ?? true ? null : otherName,
            website: website?.isEmpty ?? true ? null : website,
            facebook: facebook?.isEmpty ?? true ? null : facebook,
            image: compressedImage,
            authoredBookIds: const <String>[],
            translatedBookIds: const <String>[],
            authoredWorkIds: const <String>[],
            translatedWorkIds: const <String>[],
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

    try {
      if (existingCreator != null) {
        await ref.read(editCreatorUseCaseProvider)(creatorToSave);
      } else {
        await ref.read(addCreatorUseCaseProvider)(creatorToSave);
      }

      state = state.copyWith(isLoading: false);
      return creatorToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>('Error saving creator: $e'));
      return null;
    }
  }
}
