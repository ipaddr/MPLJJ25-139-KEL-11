class TestModel {
  final String id;
  final String title;
  final String subject;
  final String classSection;
  final DateTime testDate;
  final String gradingType; // Misalnya: 'Marks', 'Grade', 'Pass/Fail'
  final int? maximumMarks;
  final int? minimumMarks;

  TestModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.classSection,
    required this.testDate,
    required this.gradingType,
    this.maximumMarks,
    this.minimumMarks,
  });

  /// Membuat TestModel dari Map (misalnya dari Firestore atau API)
  factory TestModel.fromMap(Map<String, dynamic> map, String id) {
    return TestModel(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      classSection: map['classSection'] ?? '',
      testDate: DateTime.parse(map['testDate']),
      gradingType: map['gradingType'] ?? '',
      maximumMarks: map['maximumMarks'],
      minimumMarks: map['minimumMarks'],
    );
  }

  /// Mengubah TestModel menjadi Map (untuk Firestore atau REST API)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'classSection': classSection,
      'testDate': testDate.toIso8601String(),
      'gradingType': gradingType,
      'maximumMarks': maximumMarks,
      'minimumMarks': minimumMarks,
    };
  }
}
