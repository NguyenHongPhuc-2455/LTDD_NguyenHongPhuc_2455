import 'package:flutter/material.dart';
import '../services/event_service.dart';
import 'add_event_screen.dart';

class AdminAllEventsScreen extends StatefulWidget {
  final String token;

  const AdminAllEventsScreen({super.key, required this.token});

  @override
  _AdminAllEventsScreenState createState() => _AdminAllEventsScreenState();
}

class _AdminAllEventsScreenState extends State<AdminAllEventsScreen> {
  final _eventService = EventService(); // Stateless service
  List<dynamic> _events = []; // Use dynamic list matching service return type
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _eventService.getEvents(widget.token);
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load events: $e')));
      }
    }
  }

  Future<void> _deleteEvent(int id) async {
    if (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Event'),
            content: Text('Are you sure you want to delete this event?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false) {
      try {
        await _eventService.deleteEvent(widget.token, id);
        _fetchEvents();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Event deleted successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete event: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage All Events')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(event['Title'] ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['Description'] ?? ''),
                        Text(
                          'Start: ${event['StartTime']} - End: ${event['EndTime']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'User ID: ${event['UserID']} - Status: ${event['Status']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(event['EventID']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
