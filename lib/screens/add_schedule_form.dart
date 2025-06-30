import 'package:flutter/material.dart';
import '../db/schedule_db.dart';
import '../models/schedule.dart';

class AddScheduleForm extends StatefulWidget {
  final String category;
  final Schedule? schedule;
  const AddScheduleForm({Key? key, required this.category, this.schedule}) : super(key: key);

  @override
  State<AddScheduleForm> createState() => _AddScheduleFormState();
}

class _AddScheduleFormState extends State<AddScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _locationController.text = widget.schedule!.location;
      _descController.text = widget.schedule!.description;
      // Parse date
      final dateParts = widget.schedule!.date.split('/');
      if (dateParts.length == 3) {
        _selectedDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
      }
      // Parse time
      final timeParts = widget.schedule!.time.split(":");
      if (timeParts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1].split(' ')[0]) ?? 0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.background;
    final accentColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).colorScheme.surface;
    final onBackground = Theme.of(context).colorScheme.onBackground;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, size: 32, color: accentColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${widget.category}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Judul', onBackground),
                    _buildTextField(_titleController, 'Judul kegiatan', accentColor, onBackground, cardColor, isRequired: true),
                    _buildLabel('Tanggal', onBackground),
                    _buildDateField(context, accentColor, onBackground),
                    _buildLabel('Jam', onBackground),
                    _buildTimeField(context, accentColor, onBackground),
                    _buildLabel('Lokasi', onBackground),
                    _buildTextField(_locationController, 'Lokasi', accentColor, onBackground, cardColor, isRequired: true),
                    _buildLabel('Deskripsi', onBackground),
                    _buildTextField(_descController, 'Deskripsi (opsional)', accentColor, onBackground, cardColor, maxLines: 2, isRequired: false),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
                            try {
                              final schedule = Schedule(
                                id: widget.schedule?.id,
                                category: widget.category,
                                title: _titleController.text.trim(),
                                date: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                time: _selectedTime!.format(context),
                                location: _locationController.text.trim(),
                                description: _descController.text.trim(),
                              );
                              
                              // Simpan ke database
                              if (widget.schedule != null) {
                                await ScheduleDB.instance.updateSchedule(schedule);
                              } else {
                                await ScheduleDB.instance.insertSchedule(schedule);
                              }
                              
                              // Tampilkan feedback sukses
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Agenda berhasil disimpan!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                              
                              // Kembali ke halaman sebelumnya
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              print('Error saving schedule: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menyimpan agenda: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            // Tampilkan pesan jika ada field yang belum diisi
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mohon lengkapi semua field yang wajib diisi'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color onBackground) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: onBackground,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color accentColor, Color onBackground, Color cardColor, {int maxLines = 1, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15, color: onBackground),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: onBackground.withOpacity(0.5)),
        filled: true,
        fillColor: cardColor,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: onBackground.withOpacity(0.3)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        isDense: true,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context, Color accentColor, Color onBackground) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          builder: (context, child) {
            final theme = Theme.of(context);
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: accentColor,
                  onPrimary: theme.colorScheme.onPrimary,
                  onSurface: theme.colorScheme.onSurface,
                  background: theme.colorScheme.background,
                ),
                dialogBackgroundColor: theme.colorScheme.background,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: onBackground.withOpacity(0.3))),
        ),
        child: Text(
          _selectedDate == null
              ? 'Pilih tanggal'
              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          style: TextStyle(
            color: _selectedDate == null ? onBackground.withOpacity(0.5) : accentColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, Color accentColor, Color onBackground) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
          builder: (context, child) {
            final theme = Theme.of(context);
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: accentColor,
                  onPrimary: theme.colorScheme.onPrimary,
                  onSurface: theme.colorScheme.onSurface,
                  background: theme.colorScheme.background,
                ),
                dialogBackgroundColor: theme.colorScheme.background,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => _selectedTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: onBackground.withOpacity(0.3))),
        ),
        child: Text(
          _selectedTime == null
              ? 'Pilih jam'
              : _selectedTime!.format(context),
          style: TextStyle(
            color: _selectedTime == null ? onBackground.withOpacity(0.5) : accentColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 