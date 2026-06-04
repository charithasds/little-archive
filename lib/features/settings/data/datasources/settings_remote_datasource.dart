import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';

part 'settings_remote_datasource.g.dart';

abstract class SettingsRemoteDataSource {
  Future<void> clearAllData();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  Future<void> clearAllData() async {
    // Delete all rows from every table inside a single SQL transaction
    await db.transaction(() async {
      await db.delete(db.books).go();
      await db.delete(db.publishers).go();
      await db.delete(db.authors).go();
      await db.delete(db.translators).go();
      await db.delete(db.works).go();
      await db.delete(db.sequences).go();
      await db.delete(db.sequenceVolumes).go();
      await db.delete(db.readers).go();
      await db.delete(db.bookAuthorsJoin).go();
      await db.delete(db.bookTranslatorsJoin).go();
      await db.delete(db.workAuthorsJoin).go();
      await db.delete(db.workTranslatorsJoin).go();
    });
  }
}

@riverpod
SettingsRemoteDataSource settingsRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return SettingsRemoteDataSourceImpl(db: db);
}
