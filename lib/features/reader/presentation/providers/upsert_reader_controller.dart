import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../domain/entities/reader_entity.dart';
import 'reader_provider.dart';

class UpsertReaderState {
  const UpsertReaderState({this.isLoading = false, this.error, this.pickedBase64Image});

  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertReaderState copyWith({
    bool? isLoading,
    String? error,
    String? pickedBase64Image,
    bool clearImage = false,
  }) => UpsertReaderState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    pickedBase64Image: clearImage ? null : (pickedBase64Image ?? this.pickedBase64Image),
  );
}

class UpsertReaderController extends Notifier<UpsertReaderState> {
  @override
  UpsertReaderState build() => const UpsertReaderState();

  void initializeWith(ReaderEntity? reader) {
    if (reader != null && reader.image != null) {
      state = state.copyWith(pickedBase64Image: reader.image);
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

  Future<ReaderEntity?> saveReader({
    required ReaderEntity? existingReader,
    required String name,
    required String email,
    required String facebook,
  }) async {
    state = state.copyWith(isLoading: true);

    final UserEntity? user = ref.read(authStateProvider).value;
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return null;
    }

    final String generatedId = ref.read(readerRepositoryProvider).generateId();

    final ReaderEntity readerToSave = existingReader != null
        ? existingReader.copyWith(
            name: name,
            email: email.isEmpty ? null : email,
            facebook: facebook.isEmpty ? null : facebook,
            image: state.pickedBase64Image,
            lastUpdated: DateTime.now(),
          )
        : ReaderEntity(
            id: generatedId,
            name: name,
            email: email.isEmpty ? null : email,
            facebook: facebook.isEmpty ? null : facebook,
            image: state.pickedBase64Image,
            bookIds: const <String>[],
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

    try {
      if (existingReader != null) {
        await ref.read(updateReaderUseCaseProvider)(readerToSave);
      } else {
        await ref.read(addReaderUseCaseProvider)(readerToSave);
      }
      state = state.copyWith(isLoading: false);
      return readerToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error saving reader: $e');
      return null;
    }
  }
}

final NotifierProvider<UpsertReaderController, UpsertReaderState> upsertReaderControllerProvider =
    NotifierProvider<UpsertReaderController, UpsertReaderState>(UpsertReaderController.new);
