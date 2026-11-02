
import 'package:flutter/material.dart';
import '../models/expense.dart';

class DetailScreen extends StatelessWidget {
  final Expense expense;

  const DetailScreen({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.account_balance_wallet,
                size: 70,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '₹${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _detailItem('Category', expense.category),
            _detailItem(
              'Date',
              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
            ),
            _detailItem('Note', expense.note),
            _detailItem('Expense ID', expense.id),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
