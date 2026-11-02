
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Summary'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final expenses = provider.expenses;

          final double total = expenses.fold(
            0,
                (sum, expense) => sum + expense.amount,
          );

          final Map<String, double> categoryTotals = {};

          for (final expense in expenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) +
                    expense.amount;
          }

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.loadExpenses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (expenses.isEmpty) {
            return const Center(
              child: Text('No expenses available for summary.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('Total Expenses'),
                        const SizedBox(height: 12),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${expenses.length} expenses recorded',
                        ),
                      ],
                    ),
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
                const SizedBox(height: 12),
                ...categoryTotals.entries.map((entry) {
                  return Card(
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
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
