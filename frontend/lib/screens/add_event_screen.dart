import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/event_service.dart';
import '../services/priority_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));
  final _eventService = EventService();
  final _priorityService = PriorityService();
  bool _isLoading = false;
  bool _isEditMode = false;
  int? _eventId;
  String _eventStatus = 'Pending';
  int _selectedPriorityId = 2; // Default: Medium
  List<dynamic> _priorities = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final token = args['token'];

    // Load priorities
    _loadPriorities(token);

    // Check if we're editing an existing event
    if (args['event'] != null) {
      final event = args['event'];
      _isEditMode = true;
      _eventId = event['EventID'];
      _titleController.text = event['Title'];
      _descriptionController.text = event['Description'] ?? '';
      // Backend sends formatted string: "2026-01-06 20:59:00"
      _startTime = DateTime.parse(event['StartTime']);
      _endTime = DateTime.parse(event['EndTime']);
      _eventStatus = event['Status'] ?? 'Pending';
      _selectedPriorityId = event['PriorityID'] ?? 2;
    } else if (args['selectedDate'] != null) {
      final selectedDate = args['selectedDate'] as DateTime;
      _startTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      );
      _endTime = _startTime.add(Duration(hours: 1));
    }
  }

  Future<void> _loadPriorities(String token) async {
    try {
      final priorities = await _priorityService.getPriorities(token);
      setState(() {
        _priorities = priorities;
      });
    } catch (e) {
      print('Error loading priorities: $e');
    }
  }

  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
      );
      if (time != null) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        print('Selected ${isStart ? "START" : "END"} time: $newDateTime');

        setState(() {
          if (isStart) {
            _startTime = newDateTime;
            print('Updated _startTime to: $_startTime');
          } else {
            _endTime = newDateTime;
            print('Updated _endTime to: $_endTime');
          }
        });
      }
    }
  }

  void _saveEvent() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final token = args['token'];

    setState(() => _isLoading = true);

    bool success;
    if (_isEditMode && _eventId != null) {
      success = await _eventService.updateEvent(
        token,
        _eventId!,
        _titleController.text,
        _descriptionController.text,
        _startTime,
        _endTime,
        _eventStatus,
        _selectedPriorityId,
      );
    } else {
      success = await _eventService.createEvent(
        token,
        _titleController.text,
        _descriptionController.text,
        _startTime,
        _endTime,
        _selectedPriorityId,
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Failed to update event' : 'Failed to create event',
            ),
          ),
        );
      }
    }
  }

  Color _getPriorityColor(String colorCode) {
    return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Event' : 'Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            // Priority Dropdown
            if (_priorities.isNotEmpty)
              DropdownButtonFormField<int>(
                value: _selectedPriorityId,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.flag),
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem<int>(
                    value: priority['PriorityID'],
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority['ColorCode']),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(priority['LevelName']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriorityId = value!;
                  });
                },
              ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDateTime(true),
                    child: Text(
                      'Start: ${DateFormat('yyyy-MM-dd HH:mm').format(_startTime)}',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDateTime(false),
                    child: Text(
                      'End: ${DateFormat('yyyy-MM-dd HH:mm').format(_endTime)}',
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveEvent,
                    child: Text(_isEditMode ? 'Update Event' : 'Save Event'),
                  ),
          ],
        ),
      ),
    );
  }
}
