import 'package:flutter/material.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  final List<Map<String, dynamic>> weeklyMeals = const [
    {
      'day': 'Monday',
      'menu': 'Grilled Chicken with Garden Salad',
      'calories': 650,
      'protein': 35,
      'carbs': 75,
      'fat': 22,
    },
    {
      'day': 'Tuesday',
      'menu': 'Whole Grain Pasta',
      'calories': 600,
      'protein': 30,
      'carbs': 80,
      'fat': 20,
    },
    {
      'day': 'Wednesday',
      'menu': 'Baked Fish',
      'calories': 620,
      'protein': 32,
      'carbs': 70,
      'fat': 18,
    },
    {
      'day': 'Thursday',
      'menu': 'Vegetable Stir Fry',
      'calories': 580,
      'protein': 25,
      'carbs': 75,
      'fat': 15,
    },
    {
      'day': 'Friday',
      'menu': 'Rice and Beans',
      'calories': 610,
      'protein': 28,
      'carbs': 77,
      'fat': 20,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Plan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: weeklyMeals.length,
        itemBuilder: (context, index) {
          final meal = weeklyMeals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('${meal['day']} - ${meal['menu']}'),
              subtitle: Text(
                'Calories: ${meal['calories']} kcal\n'
                'Protein: ${meal['protein']} g, Carbs: ${meal['carbs']} g, Fat: ${meal['fat']} g',
              ),
            ),
          );
        },
      ),
    );
  }
}
