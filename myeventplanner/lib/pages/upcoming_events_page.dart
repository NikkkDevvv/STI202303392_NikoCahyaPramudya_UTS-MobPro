import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myeventplanner/pages/event_detail_page.dart';
import '../models/event_model.dart';

/// Menampilkan event yang akan datang (sudah diurutkan berdasarkan dateTime)
class UpcomingEventsPage extends StatelessWidget {
  final List<Event> events;

  const UpcomingEventsPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Segera Tiba"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 16.0,
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1DB954).withOpacity(0.2),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF1DB954),
                ),
              ),
              title: Text(
                event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              // Penting: format tanggal lokal Indonesia + jam
              subtitle: Text(
                DateFormat(
                  'EEEE, d MMM yyyy \'pukul\' HH:mm',
                  'id_ID',
                ).format(event.dateTime),
                style: TextStyle(color: Colors.grey.shade400),
              ),
              // Penting: navigasi ke halaman detail event
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailPage(event: event),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
