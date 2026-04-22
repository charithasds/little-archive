import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../domain/entities/publisher_entity.dart';
import 'publisher_provider.dart';

part 'upsert_publisher_controller.g.dart';

class UpsertPublisherState {
  const UpsertPublisherState({
    this.existingPublisher,
    this.isLoading = false,
    this.error,
    this.pickedBase64Logo,
  });

  final PublisherEntity? existingPublisher;
  final bool isLoading;
  final String? error;
  final String? pickedBase64Logo;

  UpsertPublisherState copyWith({
    Nullable<PublisherEntity?>? existingPublisher,
    bool? isLoading,
    Nullable<String?>? error,
    Nullable<String?>? pickedBase64Logo,
  }) =>
      UpsertPublisherState(
        existingPublisher: existingPublisher != null ? existingPublisher.value : this.existingPublisher,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error.value : this.error,
        pickedBase64Logo: pickedBase64Logo != null ? pickedBase64Logo.value : this.pickedBase64Logo,
      );
}

@riverpod
class UpsertPublisherController extends _$UpsertPublisherController {
  @override
  UpsertPublisherState build() => const UpsertPublisherState();

  void initializeWith(PublisherEntity? publisher) {
    state = UpsertPublisherState(
      existingPublisher: publisher,
      pickedBase64Logo: publisher?.logo,
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      state = state.copyWith(pickedBase64Logo: Nullable<String?>(base64Encode(bytes)));
    }
  }

  void clearLogo() {
    state = state.copyWith(pickedBase64Logo: const Nullable<String?>(null));
  }

  Future<PublisherEntity?> savePublisher({
    required String name,
    String? otherName,
    String? website,
    String? email,
    String? facebook,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));

    final UserEntity? user = ref.read(authStateProvider).value;

    if (user == null) {
      state = state.copyWith(isLoading: false, error: const Nullable<String?>('User not authenticated'));
      return null;
    }

    final PublisherEntity? existingPublisher = state.existingPublisher;
    final String generatedId = ref.read(generatePublisherIdUseCaseProvider)();

    final PublisherEntity publisherToSave = existingPublisher != null
        ? existingPublisher.copyWith(
            name: name,
            otherName: Nullable<String?>(otherName?.isEmpty ?? true ? null : otherName),
            website: Nullable<String?>(website?.isEmpty ?? true ? null : website),
            email: Nullable<String?>(email?.isEmpty ?? true ? null : email),
            facebook: Nullable<String?>(facebook?.isEmpty ?? true ? null : facebook),
            phoneNumber: Nullable<String?>(phone?.isEmpty ?? true ? null : phone),
            logo: Nullable<String?>(state.pickedBase64Logo),
            lastUpdated: DateTime.now(),
          )
        : PublisherEntity(
            id: generatedId,
            name: name,
            otherName: otherName?.isEmpty ?? true ? null : otherName,
            website: website?.isEmpty ?? true ? null : website,
            email: email?.isEmpty ?? true ? null : email,
            facebook: facebook?.isEmpty ?? true ? null : facebook,
            phoneNumber: phone?.isEmpty ?? true ? null : phone,
            logo: state.pickedBase64Logo,
            bookIds: const <String>[],
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

    try {
      if (existingPublisher != null) {
        await ref.read(editPublisherUseCaseProvider)(publisherToSave);
      } else {
        await ref.read(addPublisherUseCaseProvider)(publisherToSave);
      }

      state = state.copyWith(isLoading: false);

      return publisherToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>('Error saving publisher: $e'));
      return null;
    }
  }
}
