import 'package:cloud_firestore/cloud_firestore.dart';

class RelationshipSyncService {
  RelationshipSyncService({required FirebaseFirestore firestore, required String userId})
    : _firestore = firestore,
      _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;

  String get _userPath => 'users/$_userId';

  String _collectionPath(String collection) => '$_userPath/$collection';

  Future<void> syncBookRelationships({
    required String bookId,
    required List<String> newAuthorIds,
    required List<String> newTranslatorIds,
    required List<String> newSequenceVolumeIds,
    required List<String> newWorkIds,
    String? newPublisherId,
    String? newReaderId,
    List<String> oldAuthorIds = const <String>[],
    List<String> oldTranslatorIds = const <String>[],
    List<String> oldSequenceVolumeIds = const <String>[],
    List<String> oldWorkIds = const <String>[],
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
      collection: 'works',
      fieldName: 'bookId',
      entityId: bookId,
      newIds: newWorkIds,
      oldIds: oldWorkIds,
      isSingleSync: true,
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
    String? newBookId,
    List<String> oldAuthorIds = const <String>[],
    List<String> oldTranslatorIds = const <String>[],
    List<String> oldSequenceVolumeIds = const <String>[],
    String? oldBookId,
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

    await _syncSingleEntityRelationship(
      batch: batch,
      collection: 'books',
      fieldName: 'workIds',
      entityId: workId,
      newId: newBookId,
      oldId: oldBookId,
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
    required List<String> workIds,
    String? publisherId,
    String? readerId,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String authorId in authorIds) {
      batch.set(_firestore.collection(_collectionPath('authors')).doc(authorId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    for (final String translatorId in translatorIds) {
      batch.set(
        _firestore.collection(_collectionPath('translators')).doc(translatorId),
        <String, dynamic>{
          'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    for (final String workId in workIds) {
      batch.set(_firestore.collection(_collectionPath('works')).doc(workId), <String, dynamic>{
        'bookId': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    for (final String volumeId in sequenceVolumeIds) {
      batch.set(
        _firestore.collection(_collectionPath('sequence_volumes')).doc(volumeId),
        <String, dynamic>{'bookId': null, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }

    if (publisherId != null) {
      batch.set(
        _firestore.collection(_collectionPath('publishers')).doc(publisherId),
        <String, dynamic>{
          'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    if (readerId != null) {
      batch.set(_firestore.collection(_collectionPath('readers')).doc(readerId), <String, dynamic>{
        'bookIds': FieldValue.arrayRemove(<dynamic>[bookId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> removeWorkRelationships({
    required String workId,
    required List<String> authorIds,
    required List<String> translatorIds,
    required List<String> sequenceVolumeIds,
    String? bookId,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String authorId in authorIds) {
      batch.set(_firestore.collection(_collectionPath('authors')).doc(authorId), <String, dynamic>{
        'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    for (final String translatorId in translatorIds) {
      batch.set(
        _firestore.collection(_collectionPath('translators')).doc(translatorId),
        <String, dynamic>{
          'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    if (bookId != null && bookId.isNotEmpty) {
      batch.set(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'workIds': FieldValue.arrayRemove(<dynamic>[workId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    for (final String volumeId in sequenceVolumeIds) {
      batch.set(
        _firestore.collection(_collectionPath('sequence_volumes')).doc(volumeId),
        <String, dynamic>{'workId': null, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
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
      batch.set(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'authorIds': FieldValue.arrayRemove(<dynamic>[authorId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    for (final String workId in workIds) {
      batch.set(_firestore.collection(_collectionPath('works')).doc(workId), <String, dynamic>{
        'authorIds': FieldValue.arrayRemove(<dynamic>[authorId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
      batch.set(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'translatorIds': FieldValue.arrayRemove(<dynamic>[translatorId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    for (final String workId in workIds) {
      batch.set(_firestore.collection(_collectionPath('works')).doc(workId), <String, dynamic>{
        'translatorIds': FieldValue.arrayRemove(<dynamic>[translatorId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> removePublisherRelationships({
    required String publisherId,
    required List<String> bookIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String bookId in bookIds) {
      batch.set(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'publisherId': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> removeReaderRelationships({
    required String readerId,
    required List<String> bookIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String bookId in bookIds) {
      batch.set(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'readerId': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> removeSequenceRelationships({
    required String sequenceId,
    required List<String> sequenceVolumeIds,
  }) async {
    final WriteBatch batch = _firestore.batch();

    for (final String volumeId in sequenceVolumeIds) {
      batch.set(
        _firestore.collection(_collectionPath('sequence_volumes')).doc(volumeId),
        <String, dynamic>{'sequenceId': '', 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
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

    batch.set(
      _firestore.collection(_collectionPath('sequences')).doc(sequenceId),
      <String, dynamic>{
        'sequenceVolumeIds': FieldValue.arrayRemove(<dynamic>[volumeId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (bookId != null && bookId.isNotEmpty) {
      batch.set(_firestore.collection(_collectionPath('books')).doc(bookId), <String, dynamic>{
        'sequenceVolumeIds': FieldValue.arrayRemove(<dynamic>[volumeId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (workId != null && workId.isNotEmpty) {
      batch.set(_firestore.collection(_collectionPath('works')).doc(workId), <String, dynamic>{
        'sequenceVolumeIds': FieldValue.arrayRemove(<dynamic>[volumeId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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

      batch.set(_firestore.collection(_collectionPath(collection)).doc(id), <String, dynamic>{
        fieldName: isSingleSync ? entityId : FieldValue.arrayUnion(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    for (final String id in toRemove) {
      if (id.isEmpty) {
        continue;
      }

      batch.set(_firestore.collection(_collectionPath(collection)).doc(id), <String, dynamic>{
        fieldName: isSingleSync ? null : FieldValue.arrayRemove(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
      batch.set(_firestore.collection(_collectionPath(collection)).doc(oldId), <String, dynamic>{
        fieldName: FieldValue.arrayRemove(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (newId != null && newId.isNotEmpty) {
      batch.set(_firestore.collection(_collectionPath(collection)).doc(newId), <String, dynamic>{
        fieldName: FieldValue.arrayUnion(<dynamic>[entityId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
