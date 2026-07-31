import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/sync/data/services/backup_service.dart';
import '../../../author/data/repositories/author_repository_impl.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/domain/repositories/author_repository.dart';
import '../../../book/data/repositories/book_repository_impl.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/domain/repositories/book_repository.dart';
import '../../../publisher/data/repositories/publisher_repository_impl.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/domain/repositories/publisher_repository.dart';
import '../../../reader/data/repositories/reader_repository_impl.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/domain/repositories/reader_repository.dart';
import '../../../translator/data/repositories/translator_repository_impl.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/domain/repositories/translator_repository.dart';
import '../../domain/usecases/settings_usecases.dart';

part 'settings_controller.g.dart';

enum SettingsOperation {
  exportLocal,
  importLocal,
  backupDrive,
  restoreDrive,
  clearData,
  compressImages,
}

class SettingsState {
  const SettingsState({
    required this.status,
    this.currentOperation,
    this.progress,
  });

  final AsyncValue<void> status;
  final SettingsOperation? currentOperation;
  final double? progress;

  SettingsState copyWith({
    AsyncValue<void>? status,
    SettingsOperation? currentOperation,
    double? progress,
  }) => SettingsState(
    status: status ?? this.status,
    currentOperation: currentOperation ?? this.currentOperation,
    progress: progress ?? this.progress,
  );
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() => const SettingsState(status: AsyncValue<void>.data(null));

  Future<int> compressAllDatabaseImages() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.compressImages,
      progress: 0.0,
    );
    await Future<void>.delayed(Duration.zero);

    int count = 0;

    final AsyncValue<int> result = await AsyncValue.guard(() async {
      final BookRepository bookRepo = ref.read(bookRepositoryProvider);
      final List<BookEntity> books = await bookRepo.fetchBooks();

      final AuthorRepository authorRepo = ref.read(authorRepositoryProvider);
      final List<AuthorEntity> authors = await authorRepo.fetchAuthors();

      final PublisherRepository publisherRepo = ref.read(publisherRepositoryProvider);
      final List<PublisherEntity> publishers = await publisherRepo.fetchPublishers();

      final ReaderRepository readerRepo = ref.read(readerRepositoryProvider);
      final List<ReaderEntity> readers = await readerRepo.fetchReaders();

      final TranslatorRepository translatorRepo = ref.read(translatorRepositoryProvider);
      final List<TranslatorEntity> translators = await translatorRepo.fetchTranslators();

      int totalItems = books.length + authors.length + publishers.length + readers.length + translators.length;
      if (totalItems == 0) {
        totalItems = 1;
      }
      int processed = 0;

      // Books
      for (final BookEntity book in books) {
        processed++;
        state = state.copyWith(progress: processed / totalItems);
        if (book.cover != null && book.cover!.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(book.cover);
          if (compressed != null && compressed != book.cover) {
            await bookRepo.editBook(
              book.copyWith(cover: Nullable<String?>(compressed), lastUpdated: DateTime.now()),
            );
            count++;
          }
        }
      }

      // Authors
      for (final AuthorEntity author in authors) {
        processed++;
        state = state.copyWith(progress: processed / totalItems);
        if (author.image != null && author.image!.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(author.image);
          if (compressed != null && compressed != author.image) {
            await authorRepo.editAuthor(
              author.copyWith(image: Nullable<String?>(compressed), lastUpdated: DateTime.now()),
            );
            count++;
          }
        }
      }

      // Publishers
      for (final PublisherEntity publisher in publishers) {
        processed++;
        state = state.copyWith(progress: processed / totalItems);
        if (publisher.logo != null && publisher.logo!.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(publisher.logo);
          if (compressed != null && compressed != publisher.logo) {
            await publisherRepo.editPublisher(
              publisher.copyWith(logo: Nullable<String?>(compressed), lastUpdated: DateTime.now()),
            );
            count++;
          }
        }
      }

      // Readers
      for (final ReaderEntity reader in readers) {
        processed++;
        state = state.copyWith(progress: processed / totalItems);
        if (reader.image != null && reader.image!.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(reader.image);
          if (compressed != null && compressed != reader.image) {
            await readerRepo.editReader(
              reader.copyWith(image: Nullable<String?>(compressed), lastUpdated: DateTime.now()),
            );
            count++;
          }
        }
      }

      // Translators
      for (final TranslatorEntity translator in translators) {
        processed++;
        state = state.copyWith(progress: processed / totalItems);
        if (translator.image != null && translator.image!.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(translator.image);
          if (compressed != null && compressed != translator.image) {
            await translatorRepo.editTranslator(
              translator.copyWith(image: Nullable<String?>(compressed), lastUpdated: DateTime.now()),
            );
            count++;
          }
        }
      }

      Images.clearCache();
      return count;
    });

    state = SettingsState(
      status: result.when(
        data: (_) => const AsyncValue<void>.data(null),
        error: (Object error, StackTrace st) => AsyncValue<void>.error(error, st),
        loading: () => const AsyncValue<void>.loading(),
      ),
    );

    return count;
  }

  Future<void> clearAllData() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.clearData,
      progress: 0.0,
    );
    await Future<void>.delayed(Duration.zero);
    final AsyncValue<void> result = await AsyncValue.guard(() async {
      await ref.read(clearAllDataUseCaseProvider).call(
        onProgress: (double p) => state = state.copyWith(progress: p),
      );
    });
    state = SettingsState(
      status: result,
    );
  }

  Future<bool> exportLocalBackup() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.exportLocal,
    );
    await Future<void>.delayed(Duration.zero);
    final bool success = await ref.read(backupServiceProvider).exportLocalBackup(
      onProgress: (double p) => state = state.copyWith(progress: p),
    );
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      state = SettingsState(
        status: AsyncValue<void>.error('Local export failed or cancelled.', StackTrace.current),
      );
    }
    return success;
  }

  Future<bool> importLocalRestore() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.importLocal,
    );
    await Future<void>.delayed(Duration.zero);
    final AppDatabase db = ref.read(appDatabaseProvider);
    await db.close();
    
    final bool success = await ref.read(backupServiceProvider).importLocalRestore(
      onProgress: (double p) => state = state.copyWith(progress: p),
    );
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      ref.invalidate(appDatabaseProvider);
      state = SettingsState(
        status: AsyncValue<void>.error('Local import failed or cancelled.', StackTrace.current),
      );
    }
    return success;
  }

  Future<bool> backupToGoogleDrive() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.backupDrive,
    );
    await Future<void>.delayed(Duration.zero);
    final bool success = await ref.read(backupServiceProvider).backupToGoogleDrive(
      onProgress: (double p) => state = state.copyWith(progress: p),
    );
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      state = SettingsState(
        status: AsyncValue<void>.error('Google Drive backup failed. Please check network/auth.', StackTrace.current),
      );
    }
    return success;
  }

  Future<bool> restoreFromGoogleDrive() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.restoreDrive,
    );
    await Future<void>.delayed(Duration.zero);
    final AppDatabase db = ref.read(appDatabaseProvider);
    await db.close();
    
    final bool success = await ref.read(backupServiceProvider).restoreFromGoogleDrive(
      onProgress: (double p) => state = state.copyWith(progress: p),
    );
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      ref.invalidate(appDatabaseProvider);
      state = SettingsState(
        status: AsyncValue<void>.error('Google Drive restore failed or no backup found.', StackTrace.current),
      );
    }
    return success;
  }
}
