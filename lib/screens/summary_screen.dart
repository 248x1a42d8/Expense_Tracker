
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../widgets/income_card.dart';
import 'add_income_screen.dart';
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  Future<void> _deleteIncome(
      BuildContext context,
      IncomeProvider provider,
      String id,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Income?'),
        content: const Text(
          'Are you sure you want to delete this income?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await provider.deleteIncome(id);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Income deleted successfully')),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete income')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income & Expense Summary'),
      ),
      body: Consumer2<ExpenseProvider, IncomeProvider>(
        builder: (context, expenseProvider, incomeProvider, child) {
          final expenses = expenseProvider.expenses;
          final incomes = incomeProvider.incomes;

          final totalExpenses = expenses.fold<double>(
            0,
                (sum, expense) => sum + expense.amount,
          );

          final totalIncome = incomeProvider.totalIncome;
          final balance = totalIncome - totalExpenses;

          final Map<String, double> categoryTotals = {};

          for (final expense in expenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) +
                    expense.amount;
          }

          if (expenseProvider.isLoading || incomeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseProvider.errorMessage != null ||
              incomeProvider.errorMessage != null) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  expenseProvider.loadExpenses();
                  incomeProvider.loadIncomes();
                },
                child: const Text('Retry Loading Data'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Income: ₹${totalIncome.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Total Expenses: ₹${totalExpenses.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        Text(
                          'Remaining Balance: ₹${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Income Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (incomes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No income records available.'),
                  )
                else
                  ...incomes.reversed.map(
                        (income) => IncomeCard(
                      income: income,
                      onDelete: () => _deleteIncome(
                        context,
                        incomeProvider,
                        income.id,
                      ),
                      onEdit: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                              builder: (_) => AddIncomeScreen(income: income),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                const Text(
                  'Category-wise Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (categoryTotals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No expenses available for summary.'),
                  )
                else
                  ...categoryTotals.entries.map(
                        (entry) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(entry.key),
                        trailing: Text(
                          '₹${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
