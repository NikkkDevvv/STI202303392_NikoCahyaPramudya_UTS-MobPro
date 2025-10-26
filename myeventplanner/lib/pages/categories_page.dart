import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myeventplanner/pages/all_events_page.dart';
import '../services/event_service.dart';

const Color spotifyGreen = Color(0xFF1DB954);

class CategoriesPage extends StatefulWidget {
  // Digunakan jika ingin langsung membuka kategori tertentu
  final String? initialCategory;

  const CategoriesPage({super.key, this.initialCategory});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // Menyimpan kategori yang sedang dipilih
  late String _selectedCategory;

  // List kategori unik (diambil dari seluruh event)
  late final List<String> _categories;

  @override
  void initState() {
    super.initState();

    // Default kategori = "Semua"
    _selectedCategory = widget.initialCategory ?? 'Semua';

    final allEvents = Provider.of<EventService>(context, listen: false).events;

    // Mengambil kategori unik menggunakan Set
    final uniqueCategories = allEvents.map((e) => e.category).toSet().toList();
    _categories = ['Semua', ...uniqueCategories];
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = Provider.of<EventService>(context).events;

    // Filter event berdasarkan kategori
    final filteredEvents = _selectedCategory == 'Semua'
        ? allEvents
        : allEvents.where((event) => event.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kategori Event"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal category selector
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
                      setState(() => _selectedCategory = category);
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
            ),
          ),

          // Menampilkan event yang sudah difilter
          Expanded(
            child: AllEventsPage(events: filteredEvents),
          ),
        ],
      ),
    );
  }
}
