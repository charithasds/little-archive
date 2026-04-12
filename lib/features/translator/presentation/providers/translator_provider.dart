import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/translator_remote_datasource.dart';
import '../../data/repositories/translator_repository_impl.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../../domain/usecases/translator_usecases.dart';

part 'translator_provider.g.dart';

@riverpod
TranslatorRemoteDataSource translatorRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);

  return TranslatorRemoteDataSourceImpl(firestoreService: firestoreService);
}

@riverpod
TranslatorRepository translatorRepository(Ref ref) {
  final TranslatorRemoteDataSource remoteDataSource = ref.watch(translatorRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return TranslatorRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GetTranslatorsUseCase getTranslatorsUseCase(Ref ref) =>
    GetTranslatorsUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
WatchTranslatorsUseCase watchTranslatorsUseCase(Ref ref) =>
    WatchTranslatorsUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
GetTranslatorByIdUseCase getTranslatorByIdUseCase(Ref ref) =>
    GetTranslatorByIdUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
AddTranslatorUseCase addTranslatorUseCase(Ref ref) =>
    AddTranslatorUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
UpdateTranslatorUseCase updateTranslatorUseCase(Ref ref) =>
    UpdateTranslatorUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
DeleteTranslatorUseCase deleteTranslatorUseCase(Ref ref) =>
    DeleteTranslatorUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
Stream<List<TranslatorEntity>> translatorsStream(Ref ref) {
  final WatchTranslatorsUseCase watchTranslators = ref.watch(watchTranslatorsUseCaseProvider);
  final UserEntity? user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream<List<TranslatorEntity>>.value(<TranslatorEntity>[]);
  }

  return watchTranslators(user.uid);
}
