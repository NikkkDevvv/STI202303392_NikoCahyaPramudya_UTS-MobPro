import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/event_model.dart';

class EventService extends ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = true; // Menandakan proses load awal dari file
  // String _promoVideoUrl = 'assets/videos/promo.mp4'; // Rusakkkkk
  String _promoVideoUrl = 'assets/videos/promo.mp4';

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  String get promoVideoUrl => _promoVideoUrl;

  EventService() {
    loadEvents(); // Load event dari file saat service dibuat
  }

  void setPromoVideoUrl(String newUrl) {
    _promoVideoUrl = newUrl.isNotEmpty ? newUrl : 'assets/videos/promo.mp4';
    notifyListeners();
  }

  void deleteEvent(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
    notifyListeners();
    saveEvents(); // Penting: Simpan state baru setelah menghapus
  }

  void updateEvent(Event updatedEvent) {
    final index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
      saveEvents(); // Menyimpan perubahan edit ke file
    }
  }

  // Path direktori tempat file JSON disimpan
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Referensi ke file events.json
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/events.json');
  }

  // Menyimpan event ke file JSON (local persistence)
  Future<void> saveEvents() async {
    try {
      final file = await _localFile;
      final eventsAsMap =
      _events.map((event) => event.toMap()).toList(); // Konversi ke Map
      await file.writeAsString(json.encode(eventsAsMap));
    } catch (e) {
      print('Error saving events: $e');
    }
  }

  // Memuat event dari file JSON
  Future<void> loadEvents() async {
    try {
      final file = await _localFile;

      // Jika pertama kali digunakan, file bisa belum ada
      if (!await file.exists()) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final contents = await file.readAsString();
      final decodedJson = json.decode(contents) as List<dynamic>;

      // Mapping data JSON ke model Event
      _events = decodedJson.map((jsonItem) {
        return Event.fromMap(jsonItem);
      }).toList();
    } catch (e) {
      print('Error loading events: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Penting: memberi tahu UI bahwa loading selesai
    }
  }

  // Menambahkan event baru dan menyimpannya ke file
  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
    saveEvents(); // Penting: agar tidak hilang setelah restart
  }
}
