class RecentCase {
  final String district;
  final String diseaseName;
  final String timeAgo;

  RecentCase({
    required this.district,
    required this.diseaseName,
    required this.timeAgo,
  });

  factory RecentCase.fromMap(Map<String, dynamic> map) => RecentCase(
    district: map['district'] ?? '',
    diseaseName: map['diseaseName'] ?? '',
    timeAgo: map['timeAgo'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'district': district,
    'diseaseName': diseaseName,
    'timeAgo': timeAgo,
  };
}

class DistrictModel {
  final String district;
  final int totalCases;
  final String mostCommonDisease;
  final List<RecentCase> recentCases;
  final DateTime lastUpdated;

  DistrictModel({
    required this.district,
    required this.totalCases,
    required this.mostCommonDisease,
    required this.recentCases,
    required this.lastUpdated,
  });

  factory DistrictModel.fromMap(Map<String, dynamic> map) => DistrictModel(
    district: map['district'] ?? '',
    totalCases: map['totalCases'] ?? 0,
    mostCommonDisease: map['mostCommonDisease'] ?? '',
    recentCases: (map['recentCases'] as List? ?? [])
        .map((e) => RecentCase.fromMap(e))
        .toList(),
    lastUpdated: DateTime.parse(map['lastUpdated']),
  );

  Map<String, dynamic> toMap() => {
    'district': district,
    'totalCases': totalCases,
    'mostCommonDisease': mostCommonDisease,
    'recentCases': recentCases.map((e) => e.toMap()).toList(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };
}
