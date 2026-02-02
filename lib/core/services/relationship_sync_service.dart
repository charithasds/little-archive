import 'package:cloud_firestore/cloud_firestore.dart';

/// Service responsible for synchronizing bidirectional relationships
/// between Books/Works and their related entities (Author, Translator,
/// Publisher, Sequence, Reader).
///
/// When a Book or Work is added, updated, or deleted, this service ensures
/// that the related entities have their bookIds/workIds arrays updated
/// accordingly.
class RelationshipSyncService {
  RelationshipSyncService({required this.firestore});
  final FirebaseFirestore firestore;

  /// Syncs relationships when a Book is added or updated.
  ///
  /// [bookId] - The ID of the book being added/updated
  /// [newAuthorIds] - List of author IDs connected to the book
  /// [newTranslatorIds] - List of translator IDs connected to the book
  /// [newPublisherId] - Publisher ID connected to the book (nullable)
  /// [newReaderId] - Reader ID connected to the book (nullable)
  /// [oldAuthorIds] - Previous author IDs (for updates, empty for adds)
  /// [oldTranslatorIds] - Previous translator IDs (for updates, empty for adds)
  /// [oldPublisherId] - Previous publisher ID (for updates, null for adds)
  /// [oldReaderId] - Previous reader ID (for updates, null for adds)
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
    final WriteBatch batch = firestore.batch();

    // Sync Authors
    await _syncEntityRelationship(
      batch: batch,
      collection: 'authors',
      fieldName: 'bookIds',
      entityId: bookId,
      newIds: newAuthorIds,
      oldIds: oldAuthorIds,
    );

    // Sync Translators
    await _syncEntityRelationship(
      batch: batch,
      collection: 'translators',
      fieldName: 'bookIds',
      entityId: bookId,
      newIds: newTranslatorIds,
      oldIds: oldTranslatorIds,
    );

    // Sync Publisher
    await _syncSingleEntityRelationship(
      batch: batch,
      collection: 'publishers',
      fieldName: 'bookIds',
      entityId: bookId,
      newId: newPublisherId,
      oldId: oldPublisherId,
    );

    // Sync Reader
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

  /// Syncs relationships when a Work is added or updated.
  ///
  /// [workId] - The ID of the work being added/updated
  /// [newAuthorIds] - List of author IDs connected to the work
  /// [newTranslatorIds] - List of translator IDs connected to the work
  /// [oldAuthorIds] - Previous author IDs (for updates, empty for adds)
  /// [oldTranslatorIds] - Previous translator IDs (for updates, empty for adds)
  Future<void> syncWorkRelationships({
    required String workId,
    required List<String> newAuthorIds,
    required List<String> newTranslatorIds,
    List<String> oldAuthorIds = const <String>[],
    List<String> oldTranslatorIds = const <String>[],
  }) async {
    final WriteBatch batch = firestore.batch();

    // Sync Authors
    await _syncEntityRelationship(
      batch: batch,
      collection: 'authors',
      fieldName: 'workIds',
      entityId: workId,
      newIds: newAuthorIds,
      oldIds: oldAuthorIds,
    );

    // Sync Translators
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

  /// Removes book relationships from all related entities when a book is deleted.
  Future<void> removeBookRelationships({
    required String bookId,
    required List<String> authorIds,
    required List<String> translatorIds,
    String? publisherId,
    String? readerId,
  }) async {
    final WriteBatch batch = firestore.batch();

    // Remove from Authors
    for (final String authorId in authorIds) {
      batch.update(firestore.collection('authors').doc(authorId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Remove from Translators
    for (final String translatorId in translatorIds) {
      batch.update(firestore.collection('translators').doc(translatorId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Remove from Publisher
    if (publisherId != null) {
      batch.update(firestore.collection('publishers').doc(publisherId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Remove from Reader
    if (readerId != null) {
      batch.update(firestore.collection('readers').doc(readerId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Removes work relationships from all related entities when a work is deleted.
  Future<void> removeWorkRelationships({
    required String workId,
    required List<String> authorIds,
    required List<String> translatorIds,
  }) async {
    final WriteBatch batch = firestore.batch();

    // Remove from Authors
    for (final String authorId in authorIds) {
      batch.update(firestore.collection('authors').doc(authorId), <String, dynamic>{
        'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Remove from Translators
    for (final String translatorId in translatorIds) {
      batch.update(firestore.collection('translators').doc(translatorId), <String, dynamic>{
        'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Helper method to sync many-to-many relationships.
  /// Adds entityId to new connections and removes from old connections.
  Future<void> _syncEntityRelationship({
    required WriteBatch batch,
    required String collection,
    required String fieldName,
    required String entityId,
    required List<String> newIds,
    required List<String> oldIds,
  }) async {
    // Find IDs that need to be added (in new but not in old)
    final List<String> toAdd = newIds.where((String id) => !oldIds.contains(id)).toList();
    // Find IDs that need to be removed (in old but not in new)
    final List<String> toRemove = oldIds.where((String id) => !newIds.contains(id)).toList();

    // Add entityId to new connections
    for (final String id in toAdd) {
      batch.update(firestore.collection(collection).doc(id), <String, dynamic>{
        fieldName: FieldValue.arrayUnion(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Remove entityId from old connections
    for (final String id in toRemove) {
      batch.update(firestore.collection(collection).doc(id), <String, dynamic>{
        fieldName: FieldValue.arrayRemove(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Helper method to sync single-entity relationships (like Publisher, Reader).
  Future<void> _syncSingleEntityRelationship({
    required WriteBatch batch,
    required String collection,
    required String fieldName,
    required String entityId,
    String? newId,
    String? oldId,
  }) async {
    // If old and new are the same, nothing to do
    if (oldId == newId) {
      return;
    }

    // Remove from old entity
    if (oldId != null) {
      batch.update(firestore.collection(collection).doc(oldId), <String, dynamic>{
        fieldName: FieldValue.arrayRemove(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Add to new entity
    if (newId != null) {
      batch.update(firestore.collection(collection).doc(newId), <String, dynamic>{
        fieldName: FieldValue.arrayUnion(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
}
