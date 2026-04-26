class ScanModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String diseaseName;
  final String botanicalName;
  final String scientificName;
  final double confidence;
  final String severity; // 'low', 'medium', 'high'
  final String description;
  final List<String> symptoms;
  final String district;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final bool isSynced; // false = saved offline, not yet on Firebase

  ScanModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.diseaseName,
    required this.botanicalName,
    required this.scientificName,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.symptoms,
    required this.district,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.isSynced = false,
  });

  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      diseaseName: map['diseaseName'] ?? '',
      botanicalName: map['botanicalName'] ?? '',
      scientificName: map['scientificName'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      severity: map['severity'] ?? 'low',
      description: map['description'] ?? '',
      symptoms: List<String>.from(map['symptoms'] ?? []),
      district: map['district'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      isSynced: map['isSynced'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'diseaseName': diseaseName,
      'botanicalName': botanicalName,
      'scientificName': scientificName,
      'confidence': confidence,
      'severity': severity,
      'description': description,
      'symptoms': symptoms,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  ScanModel copyWith({bool? isSynced, String? imageUrl}) {
    return ScanModel(
      id: id,
      userId: userId,
      imageUrl: imageUrl ?? this.imageUrl,
      diseaseName: diseaseName,
      botanicalName: botanicalName,
      scientificName: scientificName,
      confidence: confidence,
      severity: severity,
      description: description,
      symptoms: symptoms,
      district: district,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
