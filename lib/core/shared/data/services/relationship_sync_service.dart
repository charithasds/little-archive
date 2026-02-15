import 'package:cloud_firestore/cloud_firestore.dart';

class RelationshipSyncService {
  RelationshipSyncService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<void> syncBookRelationships({
    required String bookId,
    required List<String> newAuthorIds,
    required List<String> newTranslatorIds,
    String? newPublisherId,
    String? newReaderId,
    List<String> oldAuthorIds = const <String>[],
    List<String> oldTranslatorIds = const <String>[],
    String? oldPublisherId,
    String? oldReaderId,
  }) async {
    final WriteBatch batch = _firestore.batch();

    await _syncEntityRelationship(
      batch: batch,
      collection: 'authors',
      fieldName: 'bookIds',
      entityId: bookId,
      newIds: newAuthorIds,
      oldIds: oldAuthorIds,
    );

    await _syncEntityRelationship(
      batch: batch,
      collection: 'translators',
      fieldName: 'bookIds',
      entityId: bookId,
      newIds: newTranslatorIds,
      oldIds: oldTranslatorIds,
    );

    await _syncSingleEntityRelationship(
      batch: batch,
      collection: 'publishers',
      fieldName: 'bookIds',
      entityId: bookId,
      newId: newPublisherId,
      oldId: oldPublisherId,
    );

    await _syncSingleEntityRelationship(
      batch: batch,
      collection: 'readers',
      fieldName: 'bookIds',
      entityId: bookId,
      newId: newReaderId,
      oldId: oldReaderId,
    );

    await batch.commit();
  }

  Future<void> syncWorkRelationships({
    required String workId,
    required List<String> newAuthorIds,
    required List<String> newTranslatorIds,
    List<String> oldAuthorIds = const <String>[],
    List<String> oldTranslatorIds = const <String>[],
  }) async {
    final WriteBatch batch = _firestore.batch();

    await _syncEntityRelationship(
      batch: batch,
      collection: 'authors',
      fieldName: 'workIds',
      entityId: workId,
      newIds: newAuthorIds,
      oldIds: oldAuthorIds,
    );

    await _syncEntityRelationship(
      batch: batch,
      collection: 'translators',
      fieldName: 'workIds',
      entityId: workId,
      newIds: newTranslatorIds,
      oldIds: oldTranslatorIds,
    );

    await batch.commit();
  }

  Future<void> removeBookRelationships({
    required String bookId,
    required List<String> authorIds,
    required List<String> translatorIds,
    String? publisherId,
    String? readerId,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String authorId in authorIds) {
      batch.update(_firestore.collection('authors').doc(authorId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String translatorId in translatorIds) {
      batch.update(_firestore.collection('translators').doc(translatorId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    if (publisherId != null) {
      batch.update(_firestore.collection('publishers').doc(publisherId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    if (readerId != null) {
      batch.update(_firestore.collection('readers').doc(readerId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> removeWorkRelationships({
    required String workId,
    required List<String> authorIds,
    required List<String> translatorIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String authorId in authorIds) {
      batch.update(_firestore.collection('authors').doc(authorId), <String, dynamic>{
        'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String translatorId in translatorIds) {
      batch.update(_firestore.collection('translators').doc(translatorId), <String, dynamic>{
        'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> _syncEntityRelationship({
    required WriteBatch batch,
    required String collection,
    required String fieldName,
    required String entityId,
    required List<String> newIds,
    required List<String> oldIds,
  }) async {
    final List<String> toAdd = newIds.where((String id) => !oldIds.contains(id)).toList();
    final List<String> toRemove = oldIds.where((String id) => !newIds.contains(id)).toList();

    for (final String id in toAdd) {
      batch.update(_firestore.collection(collection).doc(id), <String, dynamic>{
        fieldName: FieldValue.arrayUnion(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String id in toRemove) {
      batch.update(_firestore.collection(collection).doc(id), <String, dynamic>{
        fieldName: FieldValue.arrayRemove(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _syncSingleEntityRelationship({
    required WriteBatch batch,
    required String collection,
    required String fieldName,
    required String entityId,
    String? newId,
    String? oldId,
  }) async {
    if (oldId == newId) {
      return;
    }

    if (oldId != null) {
      batch.update(_firestore.collection(collection).doc(oldId), <String, dynamic>{
        fieldName: FieldValue.arrayRemove(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    if (newId != null) {
      batch.update(_firestore.collection(collection).doc(newId), <String, dynamic>{
        fieldName: FieldValue.arrayUnion(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
}
