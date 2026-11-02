
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'detail_screen.dart';
import 'summary_screen.dart';
import 'setting_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ExpenseProvider>().loadExpenses();
      context.read<IncomeProvider>().loadIncomes();
    });
  }

  Widget _summaryCard(
      String title,
      String amount,
      IconData icon,
      Color color,
      ) {
    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) {
      if (mounted) setState(() => _selectedIndex = 0);
    });
  }

  Future<void> _confirmDeleteExpense(
      BuildContext context,
      ExpenseProvider provider,
      String expenseId,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: const Text(
            'Are you sure you want to delete this expense?',
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
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await provider.deleteExpense(expenseId);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete expense. Please try again.'),
          ),
        );
      }
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.add_circle,
                  color: Colors.greenAccent,
                ),
                title: const Text('Add Income'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openPage(const AddIncomeScreen());
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.remove_circle,
                  color: Colors.redAccent,
                ),
                title: const Text('Add Expense'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openPage(const AddExpenseScreen());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onNavigationTap(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        _openPage(const SummaryScreen());
        break;
      case 2:
        _showAddOptions();
        break;
      case 3:
        _openPage(const SettingsScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expence Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _openPage(const SummaryScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<ExpenseProvider, IncomeProvider>(
        builder: (context, expenseProvider, incomeProvider, child) {
          final expenses = expenseProvider.expenses;

          final totalExpenses = expenses.fold<double>(
            0,
                (sum, expense) => sum + expense.amount,
          );

          final totalIncome = incomeProvider.totalIncome;
          final balance = totalIncome - totalExpenses;

          if (expenseProvider.isLoading || incomeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (expenseProvider.errorMessage != null ||
              incomeProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Unable to load your data.'),
                  ElevatedButton(
                    onPressed: () {
                      expenseProvider.loadExpenses();
                      incomeProvider.loadIncomes();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Total Income',
                        '₹${totalIncome.toStringAsFixed(2)}',
                        Icons.trending_up,
                        Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        'Expenses',
                        '₹${totalExpenses.toStringAsFixed(2)}',
                        Icons.trending_down,
                        Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: _summaryCard(
                    'Remaining Balance',
                    '₹${balance.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    Colors.lightBlueAccent,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Expenses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openPage(const SummaryScreen()),
                      child: const Text('View Reports'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (expenses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        'No expenses yet.\nAdd your first expense!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...expenses.reversed.map(
                        (expense) => ExpenseCard(
                      expense: expense,
                      onTap: () => _openPage(
                        DetailScreen(expense: expense),
                      ),
                      onDelete: () => _confirmDeleteExpense(
                        context,
                        expenseProvider,
                        expense.id,
                      ),
                      onEdit: () => _openPage(
                        AddExpenseScreen(expense: expense),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigationTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
