import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myeventplanner/pages/event_detail_page.dart';
import 'package:myeventplanner/pages/all_events_page.dart';
import 'package:myeventplanner/pages/categories_page.dart';
import 'package:myeventplanner/pages/upcoming_events_page.dart';

import '../models/event_model.dart';
import '../services/event_service.dart';

const Color spotifyGreen = Color(0xFF1DB954);

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventService>(
      builder: (context, eventService, child) {
        Widget content;

        if (eventService.isLoading) {
          content = const Center(
            key: ValueKey('loading'),
            heightFactor: 10,
            child: CircularProgressIndicator(color: spotifyGreen),
          );
        } else {
          final allEvents = eventService.events;
          final now = DateTime.now();

          // Penting: filter event yang belum lewat (upcoming)
          final upcomingEvents = allEvents
              .where((event) => event.dateTime.isAfter(now))
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          content = ListView(
            key: ValueKey('content-${allEvents.length}'),
            children: [
              const SizedBox(height: 24),

              _SectionHeader(
                title: "Kategori",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesPage()),
                ),
              ),

              const SizedBox(height: 16),
              _InteractiveCategoryPreview(allEvents: allEvents),
              const SizedBox(height: 24),

              if (upcomingEvents.isNotEmpty) ...[
                _SectionHeader(
                  title: "Segera Tiba",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpcomingEventsPage(events: upcomingEvents),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _FeaturedEventCard(event: upcomingEvents.first),
              ],

              const SizedBox(height: 24),

              if (allEvents.isNotEmpty) ...[
                _SectionHeader(
                  title: "Semua Event",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllEventsPage()),
                  ),
                ),
                const SizedBox(height: 16),
                _HorizontalEventList(events: allEvents),
              ],

              if (allEvents.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Text(
                      'Belum ada event ditambahkan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 750),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: content,
        );
      },
    );
  }
}

// ================== UI SECTIONS ==================

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _SectionHeader({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Lihat Semua",
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  final Event event;
  const _FeaturedEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (event.imagePath != null && event.imagePath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16.0),
                    ),
                    child: Image.file(
                      File(event.imagePath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheHeight: 500,
                      cacheWidth: 500,
                    ),
                  )
                else
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                    ),
                    child: const Icon(Icons.music_note,
                        color: Colors.white54, size: 60),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('d MMM').format(event.dateTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(event.category,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalEventList extends StatelessWidget {
  final List<Event> events;
  const _HorizontalEventList({required this.events});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
            ),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                image: event.imagePath != null && event.imagePath!.isNotEmpty
                    ? DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(File(event.imagePath!)),
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                )
                    : null,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InteractiveCategoryPreview extends StatefulWidget {
  final List<Event> allEvents;
  const _InteractiveCategoryPreview({required this.allEvents});

  @override
  State<_InteractiveCategoryPreview> createState() =>
      _InteractiveCategoryPreviewState();
}

class _InteractiveCategoryPreviewState
    extends State<_InteractiveCategoryPreview> {
  late final List<String> _categories;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    final uniqueCategories =
    widget.allEvents.map((e) => e.category).toSet().toList();

    // Penting: kategori dinamis berdasarkan data user
    _categories = ['Semua', ...uniqueCategories];
    _selectedCategory = 'Semua';
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _selectedCategory == 'Semua'
        ? widget.allEvents
        : widget.allEvents
        .where((event) => event.category == _selectedCategory)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return Container(
                margin: const EdgeInsets.only(right: 10),
                child: ActionChip(
                  label: Text(category),
                  backgroundColor: isSelected
                      ? spotifyGreen
                      : Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        if (filteredEvents.isNotEmpty)
          _HorizontalEventList(events: filteredEvents.take(2).toList())
        else
          SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'Tidak ada event di kategori "$_selectedCategory".',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}
