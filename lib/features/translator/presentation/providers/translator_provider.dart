import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/translator_remote_datasource.dart';
import '../../data/repositories/translator_repository_impl.dart';
import '../../domain/repositories/translator_repository.dart';
import '../../domain/entities/translator_entity.dart';

final translatorRemoteDataSourceProvider = Provider<TranslatorRemoteDataSource>(
  (ref) {
    final firestore = ref.watch(firestoreProvider);
    return TranslatorRemoteDataSourceImpl(firestore: firestore);
  },
);

final translatorRepositoryProvider = Provider<TranslatorRepository>((ref) {
  final remoteDataSource = ref.watch(translatorRemoteDataSourceProvider);
  return TranslatorRepositoryImpl(remoteDataSource: remoteDataSource);
});

final translatorsStreamProvider = StreamProvider<List<TranslatorEntity>>((ref) {
  final repository = ref.watch(translatorRepositoryProvider);
  return repository.watchTranslators();
});
