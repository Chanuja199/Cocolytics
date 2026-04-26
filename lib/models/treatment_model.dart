class ChemicalTreatment {
  final String name;
  final String use;
  final List<String> whereToBuy;
  final String? youtubeUrl;

  ChemicalTreatment({
    required this.name,
    required this.use,
    required this.whereToBuy,
    this.youtubeUrl,
  });

  factory ChemicalTreatment.fromMap(Map<String, dynamic> map) {
    return ChemicalTreatment(
      name: map['name'] ?? '',
      use: map['use'] ?? '',
      whereToBuy: List<String>.from(map['whereToBuy'] ?? []),
      youtubeUrl: map['youtubeUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'use': use,
    'whereToBuy': whereToBuy,
    'youtubeUrl': youtubeUrl,
  };
}

class TreatmentModel {
  final String diseaseId;
  final String diseaseName;
  final List<String> shortTermSteps;
  final List<ChemicalTreatment> chemicalTreatments;
  final List<String> longTermSteps;

  TreatmentModel({
    required this.diseaseId,
    required this.diseaseName,
    required this.shortTermSteps,
    required this.chemicalTreatments,
    required this.longTermSteps,
  });

  factory TreatmentModel.fromMap(Map<String, dynamic> map) {
    return TreatmentModel(
      diseaseId: map['diseaseId'] ?? '',
      diseaseName: map['diseaseName'] ?? '',
      shortTermSteps: List<String>.from(map['shortTermSteps'] ?? []),
      chemicalTreatments: (map['chemicalTreatments'] as List? ?? [])
          .map(
            (e) => ChemicalTreatment.fromMap(
              Map<String, dynamic>.from(e as Map), // ← this is the fix
            ),
          )
          .toList(),
      longTermSteps: List<String>.from(map['longTermSteps'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'diseaseId': diseaseId,
    'diseaseName': diseaseName,
    'shortTermSteps': shortTermSteps,
    'chemicalTreatments': chemicalTreatments.map((e) => e.toMap()).toList(),
    'longTermSteps': longTermSteps,
  };
}
