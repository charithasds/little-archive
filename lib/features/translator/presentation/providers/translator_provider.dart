import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/translator_remote_datasource.dart';
import '../../data/repositories/translator_repository_impl.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../../domain/usecases/translator_usecases.dart';

part 'translator_provider.g.dart';

@riverpod
TranslatorRemoteDataSource _translatorRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return TranslatorRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}

@riverpod
TranslatorRepository _translatorRepository(Ref ref) {
  final TranslatorRemoteDataSource remoteDataSource = ref.watch(_translatorRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return TranslatorRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GenerateTranslatorIdUseCase generateTranslatorIdUseCase(Ref ref) =>
    GenerateTranslatorIdUseCase(ref.watch(_translatorRepositoryProvider));

@riverpod
FetchTranslatorsUseCase fetchTranslatorsUseCase(Ref ref) =>
    FetchTranslatorsUseCase(ref.watch(_translatorRepositoryProvider));

@riverpod
FetchTranslatorByIdUseCase fetchTranslatorByIdUseCase(Ref ref) =>
    FetchTranslatorByIdUseCase(ref.watch(_translatorRepositoryProvider));

@riverpod
WatchTranslatorsUseCase watchTranslatorsUseCase(Ref ref) =>
    WatchTranslatorsUseCase(ref.watch(_translatorRepositoryProvider));

@riverpod
AddTranslatorUseCase addTranslatorUseCase(Ref ref) =>
    AddTranslatorUseCase(ref.watch(_translatorRepositoryProvider));

@riverpod
EditTranslatorUseCase editTranslatorUseCase(Ref ref) =>
    EditTranslatorUseCase(ref.watch(_translatorRepositoryProvider));

@riverpod
RemoveTranslatorUseCase removeTranslatorUseCase(Ref ref) =>
    RemoveTranslatorUseCase(ref.watch(_translatorRepositoryProvider));

@riverpod
Stream<List<TranslatorEntity>> translatorsStream(Ref ref) {
  final WatchTranslatorsUseCase watchTranslators = ref.watch(watchTranslatorsUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<TranslatorEntity>>.value(<TranslatorEntity>[]);
  }

  return watchTranslators();
}
