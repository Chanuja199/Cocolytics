import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/district_model.dart';

class MapService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<DistrictModel>> getDistrictData() async {
    final snapshot = await _db
        .collection('districts')
        .orderBy('totalCases', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DistrictModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<DistrictModel>> getRecentAlerts() async {
    final snapshot = await _db
        .collection('districts')
        .orderBy('lastUpdated', descending: true)
        .limit(5)
        .get();

    return snapshot.docs
        .map((doc) => DistrictModel.fromMap(doc.data()))
        .toList();
  }

  // Called after every successful scan to update district stats
  Future<void> updateDistrictCount({
    required String district,
    required String diseaseName,
  }) async {
    final ref = _db.collection('districts').doc(district);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (snapshot.exists) {
        transaction.update(ref, {
          'totalCases': FieldValue.increment(1),
          'lastUpdated': DateTime.now().toIso8601String(),
          'mostCommonDisease': diseaseName,
          'recentCases': FieldValue.arrayUnion([
            {
              'district': district,
              'diseaseName': diseaseName,
              'timeAgo': 'Just now',
            },
          ]),
        });
      } else {
        transaction.set(ref, {
          'district': district,
          'totalCases': 1,
          'mostCommonDisease': diseaseName,
          'lastUpdated': DateTime.now().toIso8601String(),
          'recentCases': [
            {
              'district': district,
              'diseaseName': diseaseName,
              'timeAgo': 'Just now',
            },
          ],
        });
      }
    });
  }
}
