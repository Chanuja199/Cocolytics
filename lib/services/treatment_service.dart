import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/treatment_model.dart';

class TreatmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retrieves the treatment plan for a specific disease ID.
  /// Checks local offline dictionary first for zero-network latency, then falls back to Firestore.
  Future<TreatmentModel?> getTreatment(String diseaseId) async {
    final offlineTreatment = _getOfflineTreatment(diseaseId);
    if (offlineTreatment != null) {
      return offlineTreatment;
    }

    try {
      final doc = await _db.collection('treatments').doc(diseaseId).get();
      if (doc.exists && doc.data() != null) {
        return TreatmentModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Firebase fetch failed: $e');
    }
    
    return null;
  }

  TreatmentModel? _getOfflineTreatment(String diseaseId) {
    switch (diseaseId) {
      case 'bud_rot':
        return TreatmentModel(
          diseaseId: 'bud_rot',
          diseaseName: 'Bud Rot',
          shortTermSteps: [
            'Immediately remove and destroy the infected bud tissues.',
            'Apply Bordeaux mixture or copper oxychloride paste to the cut surface.',
            'Provide good drainage to reduce humidity around the palm.',
          ],
          chemicalTreatments: [
            ChemicalTreatment(
              name: 'Copper Oxychloride',
              use: 'Apply as a paste on the affected crown or spray 1% Bordeaux mixture.',
              whereToBuy: ['Local agricultural stores', 'Farm chem suppliers'],
            ),
          ],
          longTermSteps: [
            'Regularly inspect neighboring palms for early detection.',
            'Ensure proper plant spacing for air circulation.',
            'Avoid physical damage to the palm bud during harvesting.',
          ],
        );
      case 'lethal_yellowing':
        return TreatmentModel(
          diseaseId: 'lethal_yellowing',
          diseaseName: 'Lethal Yellowing',
          shortTermSteps: [
            'Quarantine the affected area immediately.',
            'Fell and burn actively infected palms to prevent insect vector spread.',
          ],
          chemicalTreatments: [
            ChemicalTreatment(
              name: 'Oxytetracycline HCl',
              use: 'Trunk injection (antibiotic) for temporary suppression of symptoms. Note: Not a cure.',
              whereToBuy: ['Certified agricultural antibiotic distributors'],
            ),
          ],
          longTermSteps: [
            'Replant with resistant or highly tolerant coconut varieties (e.g., Malayan Dwarf).',
            'Control populations of the planthopper vector.',
          ],
        );
      case 'root_wilt':
        return TreatmentModel(
          diseaseId: 'root_wilt',
          diseaseName: 'Root Wilt',
          shortTermSteps: [
            'Cut and remove severely diseased palms showing yellowing and flaccidity.',
            'Apply organic manure (50 kg) mixed with bio-fertilizers per palm.',
          ],
          chemicalTreatments: [
            ChemicalTreatment(
              name: 'NPK + Magnesium',
              use: 'Apply balanced chemical fertilizers with extra Magnesium Sulphate to combat yellowing.',
              whereToBuy: ['Fertilizer distributors'],
            ),
          ],
          longTermSteps: [
            'Cultivate intercrops to improve soil health and microbial activity.',
            'Irrigate properly during summer months.',
            'Use disease-resistant seedlings for gap filling.',
          ],
        );
      case 'leaf_spot':
        return TreatmentModel(
          diseaseId: 'leaf_spot',
          diseaseName: 'Leaf Spot',
          shortTermSteps: [
            'Cut and burn the severely infected lower leaves.',
            'Improve field sanitation by removing weeds.',
          ],
          chemicalTreatments: [
            ChemicalTreatment(
              name: 'Mancozeb or Copper Oxychloride',
              use: 'Spray 1% Bordeaux mixture or 0.2% Mancozeb on the leaves.',
              whereToBuy: ['General agro-chemical shops'],
            ),
          ],
          longTermSteps: [
            'Ensure adequate potassium nutrition in the soil.',
            'Maintain wider spacing during new planting.',
          ],
        );
      default:
        return null;
    }
  }
}
