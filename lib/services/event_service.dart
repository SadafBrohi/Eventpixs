import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> createEvent(Map<String, dynamic> data) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .add(data);
      return doc.id;
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  Future<String?> joinEventByCode(String code, String userId) async {
    try {
      final query = await _db
          .collection('events')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      await doc.reference.update({
        'participants': FieldValue.arrayUnion([userId]),
      });
      return doc.id;
    } catch (e) {
      print('Error joining event: $e');
      return null;
    }
  }

  Future<void> addPhotoToEvent(String eventId, String imageUrl) async {
    final doc = _db.collection('events').doc(eventId);
    await doc.update({
      'photos': FieldValue.arrayUnion([imageUrl]),
    });
  }

  Stream<QuerySnapshot> getUserCreatedEvents(String uid) {
    return _db
        .collection('events')
        .where('createdBy', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserJoinedEvents(String uid) {
    return _db
        .collection('events')
        .where('participants', arrayContains: uid)
        .snapshots();
  }

  Future<void> deleteMultiplePhotos(
    String eventId,
    List<String> imageUrls,
  ) async {
    try {
      final doc = _db.collection('events').doc(eventId);
      await doc.update({'photos': FieldValue.arrayRemove(imageUrls)});
      print('Photos deleted successfully.');
    } catch (e) {
      print('Error deleting photos: $e');
    }
  }

  Future<List<String>> getEventMembers(String eventId) async {
    try {
      final eventDoc = await _db.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return [];

      final eventData = eventDoc.data();
      if (eventData == null) return [];

      final String ownerId = eventData['createdBy'];
      final List<dynamic> participantIds = eventData['participants'] ?? [];

      final allUserIds = [ownerId, ...participantIds];

      final usersQuery = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: allUserIds)
          .get();

      final Map<String, String> uidToName = {};
      for (var doc in usersQuery.docs) {
        final data = doc.data();
        uidToName[doc.id] = data['name'] ?? 'Unknown';
      }

      final List<String> names = [uidToName[ownerId] ?? 'Unknown'];
      for (var id in participantIds) {
        if (id != ownerId) names.add(uidToName[id] ?? 'Unknown');
      }

      return names;
    } catch (e) {
      print('Error fetching event members: $e');
      return [];
    }
  }
}
