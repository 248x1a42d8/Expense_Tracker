
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/income.dart';

class IncomeService {
  static const String _storageKey = 'incomes';

  Future<List<Income>> loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(_storageKey);

    if (data == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(data);

    return decodedData
        .map((item) => Income.fromJson(item))
        .toList();
  }

  Future<void> saveIncomes(List<Income> incomes) async {
    final prefs = await SharedPreferences.getInstance();

    final String data = jsonEncode(
      incomes.map((income) => income.toJson()).toList(),
    );

    await prefs.setString(_storageKey, data);
  }
}
