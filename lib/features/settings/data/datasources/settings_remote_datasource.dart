import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';

part 'settings_remote_datasource.g.dart';

abstract class SettingsRemoteDataSource {
  Future<void> clearAllData({void Function(double progress)? onProgress});
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  Future<void> clearAllData({void Function(double progress)? onProgress}) async {
    final List<TableInfo<Table, DataClass>> tables = <TableInfo<Table, DataClass>>[
      db.books,
      db.publishers,
      db.creators,
      db.works,
      db.sequences,
      db.sequenceVolumes,
      db.readers,
      db.bookCreatorsJoin,
      db.workCreatorsJoin,
    ];
    await db.transaction(() async {
      for (int i = 0; i < tables.length; i++) {
        await db.delete(tables[i]).go();
        onProgress?.call((i + 1) / tables.length);
      }
    });
  }
}

@riverpod
SettingsRemoteDataSource settingsRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return SettingsRemoteDataSourceImpl(db: db);
}
