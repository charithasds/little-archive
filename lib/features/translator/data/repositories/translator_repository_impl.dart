import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../datasources/translator_remote_datasource.dart';
import '../models/translator_model.dart';

part 'translator_repository_impl.g.dart';

class TranslatorRepositoryImpl implements TranslatorRepository {
  TranslatorRepositoryImpl({required this.remoteDataSource});

  final TranslatorRemoteDataSource remoteDataSource;

  final Set<String> _processedImageTranslatorIds = <String>{};

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<TranslatorEntity>> fetchTranslators() async {
    final List<TranslatorEntity> translators = await remoteDataSource.fetchTranslators();
    _compressExistingLargeImages(translators);
    return translators;
  }

  void _compressExistingLargeImages(List<TranslatorEntity> translators) {
    Future<void>.microtask(() async {
      for (final TranslatorEntity translator in translators) {
        if (_processedImageTranslatorIds.contains(translator.id)) {
          continue;
        }
        _processedImageTranslatorIds.add(translator.id);

        final String? image = translator.image;
        if (image != null && image.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(image);
          if (compressed != null && compressed != image) {
            final TranslatorEntity updated = translator.copyWith(
              image: Nullable<String?>(compressed),
              lastUpdated: DateTime.now(),
            );
            await editTranslator(updated);
          }
        }
      }
    });
  }

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
        image: Images.compressImageIfNeeded(translator.image),
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
        image: Images.compressImageIfNeeded(translator.image),
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
