import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
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
    state = UpsertReaderState(pickedBase64Image: reader?.image);
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

  Future<ReaderEntity?> saveReader({
    required ReaderEntity? existingReader,
    required String name,
    String? otherName,
    String? email,
    String? facebook,
    String? phoneNumber,
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
            otherName: Nullable<String?>(otherName?.isEmpty ?? true ? null : otherName),
            email: Nullable<String?>(email?.isEmpty ?? true ? null : email),
            facebook: Nullable<String?>(facebook?.isEmpty ?? true ? null : facebook),
            phoneNumber: Nullable<String?>(phoneNumber?.isEmpty ?? true ? null : phoneNumber),
            image: Nullable<String?>(state.pickedBase64Image),
            lastUpdated: DateTime.now(),
          )
        : ReaderEntity(
            id: generatedId,
            name: name,
            otherName: otherName?.isEmpty ?? true ? null : otherName,
            email: email?.isEmpty ?? true ? null : email,
            facebook: facebook?.isEmpty ?? true ? null : facebook,
            phoneNumber: phoneNumber?.isEmpty ?? true ? null : phoneNumber,
            image: state.pickedBase64Image,
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
