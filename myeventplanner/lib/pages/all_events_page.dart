import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myeventplanner/pages/event_detail_page.dart';
import 'package:myeventplanner/pages/add_event_page.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

// Warna tema Spotify digunakan pada avatar icon event
const Color spotifyGreen = Color(0xFF1DB954);

class AllEventsPage extends StatelessWidget {
  final List<Event>? events;

  const AllEventsPage({super.key, this.events});

  // Menampilkan dialog konfirmasi hapus (PENTING: mencegah user hapus tanpa sengaja)
  Future<void> _showDeleteConfirmationDialog(BuildContext context, Event event) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus event "${event.title}"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<EventService>(context, listen: false).deleteEvent(event.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Navigasi ke form edit (PENTING: reuse AddEventPage)
  void _editEvent(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage(eventToEdit: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil list event dari Provider jika tidak dikirim lewat parameter
    final eventList = events ?? Provider.of<EventService>(context).events;

    return Scaffold(
      // Tidak tampil AppBar jika halaman dipanggil dalam kategori
      appBar: events == null ? AppBar(title: const Text("Semua Event")) : null,
      body: eventList.isEmpty
          ? const Center(
        child: Text(
          'Tidak ada event yang ditemukan.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: eventList.length,
        itemBuilder: (context, index) {
          final event = eventList[index];

          return Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              leading: CircleAvatar(
                backgroundColor: spotifyGreen.withOpacity(0.2),
                child: const Icon(Icons.calendar_month_outlined, color: spotifyGreen),
              ),
              title: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
              ),
              subtitle: Text(
                DateFormat('EEEE, d MMM yyyy \'pukul\' HH:mm', 'id_ID').format(event.dateTime),
                style: TextStyle(color: Colors.grey.shade400),
              ),

              // PopupMenuButton untuk aksi Edit & Hapus (PENTING)
              trailing: PopupMenuButton<String>(
                iconColor: Colors.grey.shade400,
                color: Theme.of(context).colorScheme.surface,
                onSelected: (value) {
                  if (value == 'edit') {
                    _editEvent(context, event);
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, event);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit', style: TextStyle(color: Colors.white)),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(event: event),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
