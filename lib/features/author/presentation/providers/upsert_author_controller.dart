import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../domain/entities/author_entity.dart';
import 'author_provider.dart';

class UpsertAuthorState {
  const UpsertAuthorState({this.isLoading = false, this.error, this.pickedBase64Image});

  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertAuthorState copyWith({
    bool? isLoading,
    String? error,
    String? pickedBase64Image,
    bool clearImage = false,
  }) => UpsertAuthorState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    pickedBase64Image: clearImage ? null : (pickedBase64Image ?? this.pickedBase64Image),
  );
}

class UpsertAuthorController extends Notifier<UpsertAuthorState> {
  @override
  UpsertAuthorState build() => const UpsertAuthorState();

  void initializeWith(AuthorEntity? author) {
    if (author != null && author.image != null) {
      state = state.copyWith(pickedBase64Image: author.image);
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

  Future<AuthorEntity?> saveAuthor({
    required AuthorEntity? existingAuthor,
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

    final String generatedId = ref.read(authorRepositoryProvider).generateId();

    final AuthorEntity authorToSave = existingAuthor != null
        ? existingAuthor.copyWith(
            name: name,
            otherName: otherName.isEmpty ? null : otherName,
            website: website.isEmpty ? null : website,
            facebook: facebook.isEmpty ? null : facebook,
            image: state.pickedBase64Image,
            lastUpdated: DateTime.now(),
          )
        : AuthorEntity(
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
      if (existingAuthor != null) {
        await ref.read(updateAuthorUseCaseProvider)(authorToSave);
      } else {
        await ref.read(addAuthorUseCaseProvider)(authorToSave);
      }
      state = state.copyWith(isLoading: false);
      return authorToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error saving author: $e');
      return null;
    }
  }
}

final NotifierProvider<UpsertAuthorController, UpsertAuthorState> upsertAuthorControllerProvider =
    NotifierProvider<UpsertAuthorController, UpsertAuthorState>(UpsertAuthorController.new);
