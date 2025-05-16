class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String classSection;
  final DateTime dueDate;
  final String attachmentUrl;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.classSection,
    required this.dueDate,
    required this.attachmentUrl,
  });

  /// Factory constructor to create from Firestore or REST API
  factory AssignmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AssignmentModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      classSection: map['classSection'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      attachmentUrl: map['attachmentUrl'] ?? '',
    );
  }

  /// Convert model to Map (for Firestore or API POST/PUT)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'classSection': classSection,
      'dueDate': dueDate.toIso8601String(),
      'attachmentUrl': attachmentUrl,
    };
  }
}
