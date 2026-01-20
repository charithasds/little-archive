import '../entities/short_entity.dart';

abstract class ShortRepository {
  Future<List<ShortEntity>> getShorts();
  Future<ShortEntity?> getShortById(String id);
  Future<void> addShort(ShortEntity short);
  Future<void> updateShort(ShortEntity short);
  Future<void> deleteShort(String id);
  Stream<List<ShortEntity>> watchShorts();
}
