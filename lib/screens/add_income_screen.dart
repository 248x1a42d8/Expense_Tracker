
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/income.dart';
import '../providers/income_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  final Income? income;

  const AddIncomeScreen({
    super.key,
    this.income,
  });

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedSource;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<String> _sources = [
    'Salary',
    'Business',
    'Freelancing',
    'Pocket Money',
    'Other',
  ];

  bool get _isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();

    if (widget.income != null) {
      _amountController.text =
          widget.income!.amount.toString();
      _noteController.text = widget.income!.note;
      _selectedSource = widget.income!.source;
      _selectedDate = widget.income!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final income = Income(
        id: widget.income?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text.trim()),
        source: _selectedSource!,
        date: _selectedDate,
        note: _noteController.text.trim(),
      );

      final provider = context.read<IncomeProvider>();

      if (_isEditing) {
        await provider.updateIncome(income);
      } else {
        await provider.addIncome(income);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Income updated successfully'
                : 'Income added successfully',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save income. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Income' : 'Add Income'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Income Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  final amount =
                  double.tryParse(value?.trim() ?? '');

                  if (amount == null ||
                      !amount.isFinite ||
                      amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Income Source',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _sources.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Text(source),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSource = value);
                },
                validator: (value) =>
                value == null ? 'Select an income source' : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Income Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Choose Date'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLength: 200,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Enter income description',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a note';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveIncome,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : Text(
                    _isEditing ? 'Update Income' : 'Save Income',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
