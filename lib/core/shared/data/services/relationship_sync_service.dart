import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/domain/error/exceptions.dart';

class RelationshipSyncService {
  RelationshipSyncService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  String get _currentUserId {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const UnauthorizedException();
    }
    return user.uid;
  }

  String _collectionPath(String collection) => 'users/$_currentUserId/$collection';

  Future<void> syncBookRelationships({
    required String bookId,
    required List<String> newAuthorIds,
    required List<String> newTranslatorIds,
    required List<String> newSequenceVolumeIds,
    String? newPublisherId,
    String? newReaderId,
    List<String> oldAuthorIds = const <String>[],
    List<String> oldTranslatorIds = const <String>[],
    List<String> oldSequenceVolumeIds = const <String>[],
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

    await _syncEntityRelationship(
      batch: batch,
      collection: 'sequence_volumes',
      fieldName: 'bookId',
      entityId: bookId,
      newIds: newSequenceVolumeIds,
      oldIds: oldSequenceVolumeIds,
      isSingleSync: true,
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
    required List<String> newSequenceVolumeIds,
    List<String> oldAuthorIds = const <String>[],
    List<String> oldTranslatorIds = const <String>[],
    List<String> oldSequenceVolumeIds = const <String>[],
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

    await _syncEntityRelationship(
      batch: batch,
      collection: 'sequence_volumes',
      fieldName: 'workId',
      entityId: workId,
      newIds: newSequenceVolumeIds,
      oldIds: oldSequenceVolumeIds,
      isSingleSync: true,
    );

    await batch.commit();
  }

  Future<void> syncAuthorRelationships({
    required String authorId,
    required List<String> newBookIds,
    required List<String> newWorkIds,
    List<String> oldBookIds = const <String>[],
    List<String> oldWorkIds = const <String>[],
  }) async {
    final WriteBatch batch = _firestore.batch();

    await _syncEntityRelationship(
      batch: batch,
      collection: 'books',
      fieldName: 'authorIds',
      entityId: authorId,
      newIds: newBookIds,
      oldIds: oldBookIds,
    );

    await _syncEntityRelationship(
      batch: batch,
      collection: 'works',
      fieldName: 'authorIds',
      entityId: authorId,
      newIds: newWorkIds,
      oldIds: oldWorkIds,
    );

    await batch.commit();
  }

  Future<void> syncTranslatorRelationships({
    required String translatorId,
    required List<String> newBookIds,
    required List<String> newWorkIds,
    List<String> oldBookIds = const <String>[],
    List<String> oldWorkIds = const <String>[],
  }) async {
    final WriteBatch batch = _firestore.batch();

    await _syncEntityRelationship(
      batch: batch,
      collection: 'books',
      fieldName: 'translatorIds',
      entityId: translatorId,
      newIds: newBookIds,
      oldIds: oldBookIds,
    );

    await _syncEntityRelationship(
      batch: batch,
      collection: 'works',
      fieldName: 'translatorIds',
      entityId: translatorId,
      newIds: newWorkIds,
      oldIds: oldWorkIds,
    );

    await batch.commit();
  }

  Future<void> syncPublisherRelationships({
    required String publisherId,
    required List<String> newBookIds,
    List<String> oldBookIds = const <String>[],
  }) async {
    final WriteBatch batch = _firestore.batch();

    await _syncEntityRelationship(
      batch: batch,
      collection: 'books',
      fieldName: 'publisherId',
      entityId: publisherId,
      newIds: newBookIds,
      oldIds: oldBookIds,
      isSingleSync: true,
    );

    await batch.commit();
  }

  Future<void> syncReaderRelationships({
    required String readerId,
    required List<String> newBookIds,
    List<String> oldBookIds = const <String>[],
  }) async {
    final WriteBatch batch = _firestore.batch();

    await _syncEntityRelationship(
      batch: batch,
      collection: 'books',
      fieldName: 'readerId',
      entityId: readerId,
      newIds: newBookIds,
      oldIds: oldBookIds,
      isSingleSync: true,
    );

    await batch.commit();
  }

  Future<void> syncSequenceRelationships({
    required String sequenceId,
    required List<String> newSequenceVolumeIds,
    List<String> oldSequenceVolumeIds = const <String>[],
  }) async {
    final WriteBatch batch = _firestore.batch();

    await _syncEntityRelationship(
      batch: batch,
      collection: 'sequence_volumes',
      fieldName: 'sequenceId',
      entityId: sequenceId,
      newIds: newSequenceVolumeIds,
      oldIds: oldSequenceVolumeIds,
      isSingleSync: true,
    );

    await batch.commit();
  }

  Future<void> syncSequenceVolumeRelationships({
    required String volumeId,
    required String newSequenceId,
    String? newBookId,
    String? newWorkId,
    String? oldSequenceId,
    String? oldBookId,
    String? oldWorkId,
  }) async {
    final WriteBatch batch = _firestore.batch();

    await _syncSingleEntityRelationship(
      batch: batch,
      collection: 'sequences',
      fieldName: 'sequenceVolumeIds',
      entityId: volumeId,
      newId: newSequenceId,
      oldId: oldSequenceId,
    );

    await _syncSingleEntityRelationship(
      batch: batch,
      collection: 'books',
      fieldName: 'sequenceVolumeIds',
      entityId: volumeId,
      newId: newBookId,
      oldId: oldBookId,
    );

    await _syncSingleEntityRelationship(
      batch: batch,
      collection: 'works',
      fieldName: 'sequenceVolumeIds',
      entityId: volumeId,
      newId: newWorkId,
      oldId: oldWorkId,
    );

    await batch.commit();
  }

  Future<void> removeBookRelationships({
    required String bookId,
    required List<String> authorIds,
    required List<String> translatorIds,
    required List<String> sequenceVolumeIds,
    String? publisherId,
    String? readerId,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String authorId in authorIds) {
      batch.update(_firestore.collection(_collectionPath('authors')).doc(authorId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String translatorId in translatorIds) {
      batch.update(_firestore.collection(_collectionPath('translators')).doc(translatorId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String volumeId in sequenceVolumeIds) {
      batch.update(_firestore.collection(_collectionPath('sequence_volumes')).doc(volumeId), <String, dynamic>{
        'bookId': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    if (publisherId != null) {
      batch.update(_firestore.collection(_collectionPath('publishers')).doc(publisherId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    if (readerId != null) {
      batch.update(_firestore.collection(_collectionPath('readers')).doc(readerId), <String, dynamic>{
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
    required List<String> sequenceVolumeIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String authorId in authorIds) {
      batch.update(_firestore.collection(_collectionPath('authors')).doc(authorId), <String, dynamic>{
        'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String translatorId in translatorIds) {
      batch.update(_firestore.collection(_collectionPath('translators')).doc(translatorId), <String, dynamic>{
        'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String volumeId in sequenceVolumeIds) {
      batch.update(_firestore.collection(_collectionPath('sequence_volumes')).doc(volumeId), <String, dynamic>{
        'workId': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> removeAuthorRelationships({
    required String authorId,
    required List<String> bookIds,
    required List<String> workIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String bookId in bookIds) {
      batch.update(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'authorIds': FieldValue.arrayRemove(<dynamic>[authorId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String workId in workIds) {
      batch.update(_firestore.collection(_collectionPath('works')).doc(workId), <String, dynamic>{
        'authorIds': FieldValue.arrayRemove(<dynamic>[authorId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> removeTranslatorRelationships({
    required String translatorId,
    required List<String> bookIds,
    required List<String> workIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String bookId in bookIds) {
      batch.update(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'translatorIds': FieldValue.arrayRemove(<dynamic>[translatorId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String workId in workIds) {
      batch.update(_firestore.collection(_collectionPath('works')).doc(workId), <String, dynamic>{
        'translatorIds': FieldValue.arrayRemove(<dynamic>[translatorId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> removePublisherRelationships({
    required String publisherId,
    required List<String> bookIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String bookId in bookIds) {
      batch.update(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'publisherId': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> removeReaderRelationships({
    required String readerId,
    required List<String> bookIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String bookId in bookIds) {
      batch.update(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'readerId': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> removeSequenceRelationships({
    required String sequenceId,
    required List<String> sequenceVolumeIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String volumeId in sequenceVolumeIds) {
      batch.update(_firestore.collection(_collectionPath('sequence_volumes')).doc(volumeId), <String, dynamic>{
        'sequenceId': '',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> removeSequenceVolumeRelationships({
    required String volumeId,
    required String sequenceId,
    String? bookId,
    String? workId,
  }) async {
    final WriteBatch batch = _firestore.batch();

    batch.update(_firestore.collection(_collectionPath('sequences')).doc(sequenceId), <String, dynamic>{
      'sequenceVolumeIds': FieldValue.arrayRemove(<dynamic>[volumeId]),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    if (bookId != null && bookId.isNotEmpty) {
      batch.update(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'sequenceVolumeIds': FieldValue.arrayRemove(<dynamic>[volumeId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    if (workId != null && workId.isNotEmpty) {
      batch.update(_firestore.collection(_collectionPath('works')).doc(workId), <String, dynamic>{
        'sequenceVolumeIds': FieldValue.arrayRemove(<dynamic>[volumeId]),
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
    bool isSingleSync = false,
  }) async {
    final List<String> toAdd = newIds.where((String id) => !oldIds.contains(id)).toList();
    final List<String> toRemove = oldIds.where((String id) => !newIds.contains(id)).toList();

    for (final String id in toAdd) {
      if (id.isEmpty) {
        continue;
      }
      batch.update(_firestore.collection(_collectionPath(collection)).doc(id), <String, dynamic>{
        fieldName: isSingleSync ? entityId : FieldValue.arrayUnion(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    for (final String id in toRemove) {
      if (id.isEmpty) {
        continue;
      }
      batch.update(_firestore.collection(_collectionPath(collection)).doc(id), <String, dynamic>{
        fieldName: isSingleSync ? null : FieldValue.arrayRemove(<dynamic>[entityId]),
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

    if (oldId != null && oldId.isNotEmpty) {
      batch.update(_firestore.collection(_collectionPath(collection)).doc(oldId), <String, dynamic>{
        fieldName: FieldValue.arrayRemove(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    if (newId != null && newId.isNotEmpty) {
      batch.update(_firestore.collection(_collectionPath(collection)).doc(newId), <String, dynamic>{
        fieldName: FieldValue.arrayUnion(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
}
