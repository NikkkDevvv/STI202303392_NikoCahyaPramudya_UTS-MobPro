import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/event_model.dart';

const Color spotifyGreen = Color(0xFF1DB954);

class EventDetailPage extends StatelessWidget {
  final Event event; // Data event yang akan ditampilkan

  const EventDetailPage({super.key, required this.event});

  // Fungsi pembuka URL Maps/Website (Penting!)
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan gambar jika ada, fallback jika kosong
            if (event.imagePath != null && event.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  File(event.imagePath!),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheHeight: 500,
                  cacheWidth: 500,
                ),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.white54,
                ),
              ),

            const SizedBox(height: 24),

            // Judul Event
            Text(
              event.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Tanggal & Waktu Event
            Row(
              children: [
                Icon(Icons.calendar_today, color: spotifyGreen),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, d MMM yyyy', 'id_ID').format(event.dateTime),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, color: spotifyGreen),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(event.dateTime),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Kategori Event
            Row(
              children: [
                Icon(Icons.category, color: spotifyGreen),
                const SizedBox(width: 8),
                Text(
                  'Kategori: ${event.category}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Deskripsi Event
            if (event.description != null && event.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi Acara',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Tombol buka lokasi di Google Maps (Penting!)
            if (event.locationUrl != null && event.locationUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Buka Lokasi di Google Maps'),
                    onPressed: () => _launchUrl(event.locationUrl!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: spotifyGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
