import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../datasources/translator_remote_datasource.dart';
import '../models/translator_model.dart';

part 'translator_repository_impl.g.dart';

class TranslatorRepositoryImpl implements TranslatorRepository {
  TranslatorRepositoryImpl({required this.remoteDataSource});

  final TranslatorRemoteDataSource remoteDataSource;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<TranslatorEntity>> fetchTranslators() => remoteDataSource.fetchTranslators();

  @override
  Future<TranslatorEntity?> fetchTranslatorById(String id) =>
      remoteDataSource.fetchTranslatorById(id);

  @override
  Stream<List<TranslatorEntity>> watchTranslators() => remoteDataSource.watchTranslators();

  @override
  Future<void> addTranslator(TranslatorEntity translator) async {
    await remoteDataSource.addTranslator(
      TranslatorModel(
        id: translator.id,
        name: translator.name,
        image: translator.image,
        otherName: translator.otherName,
        website: translator.website,
        facebook: translator.facebook,
        bookIds: translator.bookIds,
        workIds: translator.workIds,
        createdDate: translator.createdDate,
        lastUpdated: translator.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editTranslator(TranslatorEntity translator, {TranslatorEntity? oldTranslator}) async {
    await remoteDataSource.editTranslator(
      TranslatorModel(
        id: translator.id,
        name: translator.name,
        image: translator.image,
        otherName: translator.otherName,
        website: translator.website,
        facebook: translator.facebook,
        bookIds: translator.bookIds,
        workIds: translator.workIds,
        createdDate: translator.createdDate,
        lastUpdated: translator.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removeTranslator(String id) async {
    await remoteDataSource.removeTranslator(id);
  }
}

@riverpod
TranslatorRepository translatorRepository(Ref ref) {
  final TranslatorRemoteDataSource remoteDataSource = ref.watch(translatorRemoteDataSourceProvider);

  return TranslatorRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}
