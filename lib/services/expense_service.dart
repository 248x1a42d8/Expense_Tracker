
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpenseService {
  static const String _storageKey = 'expenses';

  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(_storageKey);

    if (data == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(data);

    return decodedData
        .map((item) => Expense.fromJson(item))
        .toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();

    final String data = jsonEncode(
      expenses.map((expense) => expense.toJson()).toList(),
    );

    await prefs.setString(_storageKey, data);
  }
}
