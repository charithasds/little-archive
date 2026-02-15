import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/presentation/providers/firestore_provider.dart';
import '../../data/datasources/translator_remote_datasource.dart';
import '../../data/repositories/translator_repository_impl.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';

final Provider<TranslatorRemoteDataSource> translatorRemoteDataSourceProvider =
    Provider<TranslatorRemoteDataSource>((Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return TranslatorRemoteDataSourceImpl(firestoreService: firestoreService);
    });

final Provider<TranslatorRepository> translatorRepositoryProvider = Provider<TranslatorRepository>((
  Ref ref,
) {
  final TranslatorRemoteDataSource remoteDataSource = ref.watch(translatorRemoteDataSourceProvider);
  return TranslatorRepositoryImpl(remoteDataSource: remoteDataSource);
});

final StreamProvider<List<TranslatorEntity>> translatorsStreamProvider =
    StreamProvider<List<TranslatorEntity>>((Ref ref) {
      final TranslatorRepository repository = ref.watch(translatorRepositoryProvider);
      final UserEntity? user = ref.watch(authStateProvider).value;
      if (user == null) {
        return Stream<List<TranslatorEntity>>.value(<TranslatorEntity>[]);
      }
      return repository.watchTranslators(user.uid);
    });
