
import 'package:flutter/material.dart';
import '../models/income.dart';
import '../services/income_service.dart';

class IncomeProvider extends ChangeNotifier {
  final IncomeService _service = IncomeService();

  List<Income> _incomes = [];

  bool isLoading = false;
  String? errorMessage;

  List<Income> get incomes => List.unmodifiable(_incomes);

  double get totalIncome {
    return _incomes.fold(
      0,
          (sum, income) => sum + income.amount,
    );
  }

  Future<void> loadIncomes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _incomes = await _service.loadIncomes();
    } catch (e) {
      debugPrint('INCOME LOADING ERROR: $e');
      errorMessage = 'Unable to load income. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addIncome(Income income) async {
    final updatedIncomes = [..._incomes, income];

    await _service.saveIncomes(updatedIncomes);

    _incomes = updatedIncomes;
    notifyListeners();
  }

  Future<void> deleteIncome(String id) async {
    final updatedIncomes =
    _incomes.where((income) => income.id != id).toList();

    await _service.saveIncomes(updatedIncomes);

    _incomes = updatedIncomes;
    notifyListeners();
  }
}
