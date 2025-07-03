import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String name;
  final String description;
  final int calories;

  MenuItem({required this.name, this.description = '', this.calories = 0});

  factory MenuItem.fromMap(Map<String, dynamic> data) {
    return MenuItem(
      name: data['name'] ?? 'Tidak Diketahui',
      description: data['description'] ?? '',
      calories: data['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'calories': calories};
  }
}

class MenuModel {
  final String id;
  final DateTime date;
  final List<MenuItem> menuItems;

  MenuModel({required this.id, required this.date, required this.menuItems});

  factory MenuModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<MenuItem> items = [];
    if (data['menuItems'] != null) {
      items =
          (data['menuItems'] as List)
              .map((item) => MenuItem.fromMap(item))
              .toList();
    }
    return MenuModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      menuItems: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'menuItems': menuItems.map((item) => item.toMap()).toList(),
    };
  }
}
