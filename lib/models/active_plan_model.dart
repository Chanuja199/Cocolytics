class PlanStep {
  final String id;
  final String text;
  final bool isDone;
  final String category; // 'short_term', 'long_term', 'chemical'

  PlanStep({
    required this.id,
    required this.text,
    required this.isDone,
    required this.category,
  });

  factory PlanStep.fromMap(Map<String, dynamic> map) => PlanStep(
    id: map['id'] ?? '',
    text: map['text'] ?? '',
    isDone: map['isDone'] ?? false,
    category: map['category'] ?? 'short_term',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'isDone': isDone,
    'category': category,
  };

  PlanStep copyWith({bool? isDone}) => PlanStep(
    id: id,
    text: text,
    isDone: isDone ?? this.isDone,
    category: category,
  );
}

class ActivePlanModel {
  final String id;
  final String userId;
  final String diseaseId;
  final String diseaseName;
  final String scanImageUrl;
  final String severity;
  final List<PlanStep> steps;
  final DateTime createdAt;
  final DateTime? completedAt;

  ActivePlanModel({
    required this.id,
    required this.userId,
    required this.diseaseId,
    required this.diseaseName,
    required this.scanImageUrl,
    required this.severity,
    required this.steps,
    required this.createdAt,
    this.completedAt,
  });

  int get doneCount => steps.where((s) => s.isDone).length;
  int get totalCount => steps.length;
  double get progressPercent => totalCount == 0 ? 0 : doneCount / totalCount;
  bool get isCompleted => doneCount == totalCount && totalCount > 0;

  List<PlanStep> get shortTermSteps =>
      steps.where((s) => s.category == 'short_term').toList();
  List<PlanStep> get longTermSteps =>
      steps.where((s) => s.category == 'long_term').toList();
  List<PlanStep> get chemicalSteps =>
      steps.where((s) => s.category == 'chemical').toList();

  factory ActivePlanModel.fromMap(Map<String, dynamic> map) => ActivePlanModel(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    diseaseId: map['diseaseId'] ?? '',
    diseaseName: map['diseaseName'] ?? '',
    scanImageUrl: map['scanImageUrl'] ?? '',
    severity: map['severity'] ?? 'medium',
    steps: (map['steps'] as List? ?? [])
        .map((e) => PlanStep.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    createdAt: DateTime.parse(map['createdAt']),
    completedAt: map['completedAt'] != null
        ? DateTime.parse(map['completedAt'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'diseaseId': diseaseId,
    'diseaseName': diseaseName,
    'scanImageUrl': scanImageUrl,
    'severity': severity,
    'steps': steps.map((s) => s.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  ActivePlanModel copyWith({List<PlanStep>? steps, DateTime? completedAt}) =>
      ActivePlanModel(
        id: id,
        userId: userId,
        diseaseId: diseaseId,
        diseaseName: diseaseName,
        scanImageUrl: scanImageUrl,
        severity: severity,
        steps: steps ?? this.steps,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
      );
}
