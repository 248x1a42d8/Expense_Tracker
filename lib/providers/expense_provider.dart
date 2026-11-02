
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service = ExpenseService();

  List<Expense> _expenses = [];

  bool isLoading = false;
  String? errorMessage;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  Future<void> loadExpenses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _service.loadExpenses();
    } catch (e) {
      debugPrint('EXPENSE LOADING ERROR: $e');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    final updatedExpenses = [..._expenses, expense];

    await _service.saveExpenses(updatedExpenses);

    _expenses = updatedExpenses;
    notifyListeners();
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    final updatedExpenses = _expenses.map((expense) {
      return expense.id == updatedExpense.id
          ? updatedExpense
          : expense;
    }).toList();

    await _service.saveExpenses(updatedExpenses);

    _expenses = updatedExpenses;
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    final updatedExpenses =
    _expenses.where((expense) => expense.id != id).toList();

    await _service.saveExpenses(updatedExpenses);

    _expenses = updatedExpenses;
    notifyListeners();
  }
}
