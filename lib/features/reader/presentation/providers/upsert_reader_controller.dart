import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/usecases/reader_usecases.dart';

part 'upsert_reader_controller.g.dart';

class UpsertReaderState {
  const UpsertReaderState({
    this.existingReader,
    this.isLoading = false,
    this.error,
    this.pickedBase64Image,
  });

  final ReaderEntity? existingReader;
  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertReaderState copyWith({
    Nullable<ReaderEntity?>? existingReader,
    bool? isLoading,
    Nullable<String?>? error,
    Nullable<String?>? pickedBase64Image,
  }) => UpsertReaderState(
    existingReader: existingReader != null ? existingReader.value : this.existingReader,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
    pickedBase64Image: pickedBase64Image != null ? pickedBase64Image.value : this.pickedBase64Image,
  );
}

@riverpod
class UpsertReaderController extends _$UpsertReaderController {
  @override
  UpsertReaderState build() => const UpsertReaderState();

  void initializeWith(ReaderEntity? reader) {
    state = UpsertReaderState(existingReader: reader, pickedBase64Image: reader?.image);
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

  Future<ReaderEntity?> saveReader({
    required String name,
    String? otherName,
    String? email,
    String? facebook,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));

    await Future<void>.delayed(Duration.zero);

    final ReaderEntity? existingReader = state.existingReader;
    final String generatedId = ref.read(generateReaderIdUseCaseProvider)();

    // Eagerly compress the image if it exists to prevent SQLite OOM and large documents.
    final String? compressedImage = Images.compressImageIfNeeded(state.pickedBase64Image);
    if (compressedImage != state.pickedBase64Image) {
      state = state.copyWith(pickedBase64Image: Nullable<String?>(compressedImage));
    }

    final ReaderEntity readerToSave = existingReader != null
        ? existingReader.copyWith(
            name: name,
            otherName: Nullable<String?>(otherName?.isEmpty ?? true ? null : otherName),
            email: Nullable<String?>(email?.isEmpty ?? true ? null : email),
            facebook: Nullable<String?>(facebook?.isEmpty ?? true ? null : facebook),
            phoneNumber: Nullable<String?>(phoneNumber?.isEmpty ?? true ? null : phoneNumber),
            image: Nullable<String?>(compressedImage),
            lastUpdated: DateTime.now(),
          )
        : ReaderEntity(
            id: generatedId,
            name: name,
            otherName: otherName?.isEmpty ?? true ? null : otherName,
            email: email?.isEmpty ?? true ? null : email,
            facebook: facebook?.isEmpty ?? true ? null : facebook,
            phoneNumber: phoneNumber?.isEmpty ?? true ? null : phoneNumber,
            image: compressedImage,
            bookIds: const <String>[],
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

    try {
      if (existingReader != null) {
        await ref.read(editReaderUseCaseProvider)(readerToSave);
      } else {
        await ref.read(addReaderUseCaseProvider)(readerToSave);
      }

      state = state.copyWith(isLoading: false);
      return readerToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>('Error saving reader: $e'));
      return null;
    }
  }
}
