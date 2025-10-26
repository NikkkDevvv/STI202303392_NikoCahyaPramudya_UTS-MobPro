import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import '../models/event_model.dart';
import '../services/event_service.dart';

class AddEventPage extends StatefulWidget {
  final Event? eventToEdit;
  const AddEventPage({super.key, this.eventToEdit});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationUrlController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  String? _selectedImagePath;

  // Kategori untuk dropdown
  final List<String> _categories = [
    'Konser',
    'Seminar',
    'Olahraga',
    'Kampus',
    'Lainnya'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationUrlController.dispose();
    super.dispose();
  }

  // Picker untuk tanggal acara
  Future<void> _pickDate() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (newDate != null) setState(() => _selectedDate = newDate);
  }

  // Picker untuk waktu acara
  Future<void> _pickTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (newTime != null) setState(() => _selectedTime = newTime);
  }

  // Ambil gambar dari kamera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _selectedImagePath = image.path);
  }

  @override
  void initState() {
    super.initState();
    final event = widget.eventToEdit;

    // PENTING: Mode Edit → isi nilai lama ke input form
    if (event != null) {
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _selectedImagePath = event.imagePath;

      _selectedDate = event.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(event.dateTime);
      _selectedCategory = event.category;
    }
  }

  // Simpan Event (Add / Update)
  void _saveEvent() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null &&
        _selectedCategory != null) {

      final eventService = Provider.of<EventService>(context, listen: false);

      final fullDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final String? finalLocationUrl =
      _locationUrlController.text.isNotEmpty ? _locationUrlController.text : null;

      final String? finalDescription =
      _descriptionController.text.isNotEmpty ? _descriptionController.text : null;

      final newEvent = Event(
        id: widget.eventToEdit?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: finalDescription,
        dateTime: fullDateTime,
        category: _selectedCategory!,
        imagePath: _selectedImagePath,
        locationUrl: finalLocationUrl,
      );

      // Tentukan mode ADD atau UPDATE
      if (widget.eventToEdit == null) {
        eventService.addEvent(newEvent);
      } else {
        eventService.updateEvent(newEvent);
      }

      // Navigator.pop(context);
      // Navigasi yang aman: Pop halaman setelah operasi selesai
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Event berhasil disimpan!'),
        backgroundColor: Colors.green,
      ));

      // Cleanup hanya dilakukan jika ini adalah mode TAMBAH BARU dan tidak di-pop
      if (widget.eventToEdit == null) {
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _locationUrlController.clear();
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _selectedCategory = null;
          _selectedImagePath = null;
        });
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap lengkapi semua data.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Event' : 'Tambah Event Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleField(controller: _titleController),
              const SizedBox(height: 16),

              _CategoryDropdown(
                categories: _categories,
                selectedValue: _selectedCategory,
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),

              _DescriptionField(controller: _descriptionController),
              const SizedBox(height: 16),

              _LocationUrlField(controller: _locationUrlController),
              const SizedBox(height: 16),

              _DateTimePickerRow(
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
              ),
              const SizedBox(height: 16),

              _ImagePickerSection(
                imagePath: _selectedImagePath,
                onPickImage: _pickImage,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Event'),
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

// ================== SUB WIDGET ==================

class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  const _TitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Judul Acara',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) =>
      (value == null || value.isEmpty) ? 'Judul acara tidak boleh kosong' : null,
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.categories,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: const InputDecoration(
        labelText: 'Kategori',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Silakan pilih kategori' : null,
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Deskripsi (Opsional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
    );
  }
}

class _DateTimePickerRow extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const _DateTimePickerRow({
    this.selectedDate,
    this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(selectedDate == null
                  ? 'Pilih Tanggal'
                  : 'Tanggal: ${DateFormat.yMMMd('id_ID').format(selectedDate!)}'),
            ),
            TextButton(onPressed: onPickDate, child: const Text('Pilih')),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(selectedTime == null
                  ? 'Pilih Waktu'
                  : 'Waktu: ${selectedTime!.format(context)}'),
            ),
            TextButton(onPressed: onPickTime, child: const Text('Pilih')),
          ],
        ),
      ],
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPickImage;

  const _ImagePickerSection({this.imagePath, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        children: [
          if (imagePath == null)
            const Text('Belum ada foto dipilih.')
          else
            Image.file(File(imagePath!), height: 150, fit: BoxFit.cover),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Ambil Foto Acara'),
            onPressed: onPickImage,
          ),
        ],
      ),
    );
  }
}

class _LocationUrlField extends StatelessWidget {
  final TextEditingController controller;
  const _LocationUrlField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Link Lokasi Google Maps (Opsional)',
        hintText: 'https://maps.app.goo.gl/...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pin_drop),
      ),
    );
  }
}
