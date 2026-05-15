import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/usecases/author_usecases.dart';

part 'upsert_author_controller.g.dart';

class UpsertAuthorState {
  const UpsertAuthorState({
    this.existingAuthor,
    this.isLoading = false,
    this.error,
    this.pickedBase64Image,
  });

  final AuthorEntity? existingAuthor;
  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertAuthorState copyWith({
    Nullable<AuthorEntity?>? existingAuthor,
    bool? isLoading,
    Nullable<String?>? error,
    Nullable<String?>? pickedBase64Image,
  }) => UpsertAuthorState(
    existingAuthor: existingAuthor != null ? existingAuthor.value : this.existingAuthor,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
    pickedBase64Image: pickedBase64Image != null ? pickedBase64Image.value : this.pickedBase64Image,
  );
}

@riverpod
class UpsertAuthorController extends _$UpsertAuthorController {
  @override
  UpsertAuthorState build() => const UpsertAuthorState();

  void initializeWith(AuthorEntity? author) {
    state = UpsertAuthorState(existingAuthor: author, pickedBase64Image: author?.image);
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

  Future<AuthorEntity?> saveAuthor({
    required String name,
    String? otherName,
    String? website,
    String? facebook,
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));

    final UserEntity? user = ref.read(authStateProvider).value;

    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        error: const Nullable<String?>('User not authenticated'),
      );
      return null;
    }

    final AuthorEntity? existingAuthor = state.existingAuthor;
    final String generatedId = ref.read(generateAuthorIdUseCaseProvider)();

    AuthorEntity authorToSave = existingAuthor != null
        ? existingAuthor.copyWith(
            name: name,
            otherName: Nullable<String?>(otherName?.isEmpty ?? true ? null : otherName),
            website: Nullable<String?>(website?.isEmpty ?? true ? null : website),
            facebook: Nullable<String?>(facebook?.isEmpty ?? true ? null : facebook),
            image: Nullable<String?>(state.pickedBase64Image),
            lastUpdated: DateTime.now(),
          )
        : AuthorEntity(
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
      if (existingAuthor != null) {
        try {
          await ref.read(editAuthorUseCaseProvider)(authorToSave);
        } catch (e) {
          if (e.toString().contains('longer than 1048487 bytes')) {
            final String? compressedImage = Images.ensureFitsFirestore(state.pickedBase64Image);
            authorToSave = authorToSave.copyWith(image: Nullable<String?>(compressedImage));
            await ref.read(editAuthorUseCaseProvider)(authorToSave);
          } else {
            rethrow;
          }
        }
      } else {
        try {
          await ref.read(addAuthorUseCaseProvider)(authorToSave);
        } catch (e) {
          if (e.toString().contains('longer than 1048487 bytes')) {
            final String? compressedImage = Images.ensureFitsFirestore(state.pickedBase64Image);
            authorToSave = authorToSave.copyWith(image: Nullable<String?>(compressedImage));
            await ref.read(addAuthorUseCaseProvider)(authorToSave);
          } else {
            rethrow;
          }
        }
      }

      state = state.copyWith(isLoading: false);

      return authorToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>('Error saving author: $e'));
      return null;
    }
  }
}
