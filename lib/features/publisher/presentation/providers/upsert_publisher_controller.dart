import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../domain/entities/publisher_entity.dart';
import 'publisher_provider.dart';

class UpsertPublisherState {
  const UpsertPublisherState({this.isLoading = false, this.error, this.pickedBase64Logo});

  final bool isLoading;
  final String? error;
  final String? pickedBase64Logo;

  UpsertPublisherState copyWith({
    bool? isLoading,
    String? error,
    String? pickedBase64Logo,
    bool clearImage = false,
  }) => UpsertPublisherState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    pickedBase64Logo: clearImage ? null : (pickedBase64Logo ?? this.pickedBase64Logo),
  );
}

class UpsertPublisherController extends Notifier<UpsertPublisherState> {
  @override
  UpsertPublisherState build() => const UpsertPublisherState();

  void initializeWith(PublisherEntity? publisher) {
    if (publisher != null && publisher.logo != null) {
      state = state.copyWith(pickedBase64Logo: publisher.logo);
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      state = state.copyWith(pickedBase64Logo: base64Encode(bytes));
    }
  }

  Future<PublisherEntity?> savePublisher({
    required PublisherEntity? existingPublisher,
    required String name,
    required String otherName,
    required String website,
    required String email,
    required String facebook,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true);

    final UserEntity? user = ref.read(authStateProvider).value;
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return null;
    }

    final String generatedId = ref.read(publisherRepositoryProvider).generateId();

    final PublisherEntity publisherToSave = existingPublisher != null
        ? existingPublisher.copyWith(
            name: name,
            otherName: otherName.isEmpty ? null : otherName,
            website: website.isEmpty ? null : website,
            email: email.isEmpty ? null : email,
            facebook: facebook.isEmpty ? null : facebook,
            phoneNumber: phone.isEmpty ? null : phone,
            logo: state.pickedBase64Logo,
            lastUpdated: DateTime.now(),
          )
        : PublisherEntity(
            id: generatedId,
            name: name,
            otherName: otherName.isEmpty ? null : otherName,
            website: website.isEmpty ? null : website,
            email: email.isEmpty ? null : email,
            facebook: facebook.isEmpty ? null : facebook,
            phoneNumber: phone.isEmpty ? null : phone,
            logo: state.pickedBase64Logo,
            bookIds: const <String>[],
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

    try {
      if (existingPublisher != null) {
        await ref.read(updatePublisherUseCaseProvider)(publisherToSave);
      } else {
        await ref.read(addPublisherUseCaseProvider)(publisherToSave);
      }
      state = state.copyWith(isLoading: false);
      return publisherToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error saving publisher: $e');
      return null;
    }
  }
}

final NotifierProvider<UpsertPublisherController, UpsertPublisherState>
upsertPublisherControllerProvider =
    NotifierProvider<UpsertPublisherController, UpsertPublisherState>(
      UpsertPublisherController.new,
    );
