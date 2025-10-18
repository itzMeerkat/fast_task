// Widget for recording progress on a task

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/progress_record.dart';
import '../models/enums.dart';
import '../providers/progress_provider.dart';
import '../providers/task_provider.dart';

/// Card widget for recording progress on a single task
class ProgressCard extends StatefulWidget {
  final Task task;
  final VoidCallback onNext;

  const ProgressCard({
    super.key,
    required this.task,
    required this.onNext,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> with SingleTickerProviderStateMixin {
  HoursOption? _selectedOption;
  final _customHoursController = TextEditingController();
  bool _markCompleted = false;
  late DateTime _selectedDate;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize with today's date
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Scale animation (shrink effect)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Fade animation
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _customHoursController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Show date picker to select progress date
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      });
    }
  }

  /// Submit the progress record
  Future<void> _submit() async {
    double? hoursSpent;

    // Check if option is selected
    if (_selectedOption != null) {
      hoursSpent = _selectedOption!.toDouble();
    }
    // Check if custom hours entered
    else if (_customHoursController.text.isNotEmpty) {
      final customHours = double.tryParse(_customHoursController.text);
      if (customHours == null || customHours < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid number of hours')),
        );
        return;
      }
      hoursSpent = customHours;
    }

    // Validate that something was entered
    if (hoursSpent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an option or enter hours spent')),
      );
      return;
    }

    // Create progress record with selected date
    final record = ProgressRecord(
      taskId: widget.task.id!,
      date: _selectedDate,
      hoursSpent: hoursSpent,
    );

    await context.read<ProgressProvider>().addProgress(record);

    // Mark task as completed if checkbox is checked
    if (_markCompleted) {
      await context.read<TaskProvider>().markTaskComplete(widget.task.id!);
    }

    // Play completion animation
    await _animationController.forward();

    // Clear the form
    setState(() {
      _selectedOption = null;
      _customHoursController.clear();
      _markCompleted = false;
      // Reset to today for next task
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
    });

    // Reset animation
    _animationController.reset();

    // Call the onNext callback
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.task.brief,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Date selector
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  isToday 
                    ? 'Today - ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'
                    : DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isToday 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isToday 
                  ? 'How many hours did you spend on this task today?'
                  : 'How many hours did you spend on this task?',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            // Hour option buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: HoursOption.values.map((option) {
                final isSelected = _selectedOption == option;
                return ChoiceChip(
                  label: Text(option.displayName),
                  selected: isSelected,
                  onSelected: (selected) async {
                    if (selected) {
                      setState(() {
                        _selectedOption = option;
                        _customHoursController.clear();
                      });
                      // Auto-submit when option is selected
                      await _submit();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Or enter exact hours:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customHoursController,
              decoration: const InputDecoration(
                labelText: 'Hours',
                border: OutlineInputBorder(),
                suffixText: 'hrs',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _selectedOption = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Task completed today'),
              value: _markCompleted,
              onChanged: (value) {
                setState(() {
                  _markCompleted = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

