import 'package:flutter/material.dart';
import '../db/schedule_db.dart';
import '../models/schedule.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Schedule> allSchedules = [];
  List<Schedule> filteredSchedules = [];
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'Semua';

  final List<String> categories = [
    'Kuliah',
    'Belajar',
    'Nugas',
    'Kerja',
    'Organisasi',
    'Healing',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadSchedules();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      _applyFilters();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    filteredSchedules = allSchedules.where((s) {
      final matchQuery = s.title.toLowerCase().contains(query) ||
          s.category.toLowerCase().contains(query) ||
          s.location.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query);
      final matchCategory = selectedCategory == 'Semua' || s.category == selectedCategory;
      return matchQuery && matchCategory;
    }).toList();
  }

  Future<void> _loadSchedules() async {
    final data = await ScheduleDB.instance.getAllSchedules();
    final now = DateTime.now();
    
    // Filter hanya agenda yang sudah lewat (terlewat)
    final pastSchedules = data.where((schedule) {
      try {
        final dateParts = schedule.date.split('/');
        final timeParts = schedule.time.split(':');
        if (dateParts.length == 3 && timeParts.length >= 2) {
          final scheduleDateTime = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1].split(' ')[0]),
          );
          return scheduleDateTime.isBefore(now);
        }
      } catch (_) {}
      return false;
    }).toList();
    
    // Buat list tuple (Schedule, DateTime) untuk sorting
    List<MapEntry<Schedule, DateTime>> tuples = [];
    for (final s in pastSchedules) {
      final dateParts = s.date.split('/');
      final timeParts = s.time.split(':');
      if (dateParts.length == 3 && timeParts.length >= 2) {
        try {
          final agendaDateTime = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1].split(' ')[0]),
          );
          tuples.add(MapEntry(s, agendaDateTime));
        } catch (_) {}
      }
    }
    // Urutkan dari yang terbesar ke yang terkecil (paling jauh ke paling dekat)
    tuples.sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      allSchedules = tuples.map((e) => e.key).toList();
      filteredSchedules = allSchedules;
    });
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus semua data history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Hanya clear data tampilan, bukan database
        setState(() {
          allSchedules.clear();
          filteredSchedules.clear();
        });
        
        // Tampilkan feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua data history berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus history: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void showAgendaDetailModal(BuildContext context, Schedule agenda) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final onBackground = Theme.of(context).colorScheme.onBackground;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: accentColor, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${agenda.category}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: onBackground),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "${agenda.title}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: onBackground),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text("${agenda.date} ", style: TextStyle(color: onBackground)),
                  Text("pukul ${agenda.time}", style: TextStyle(color: onBackground)),
                ],
              ),
              const SizedBox(height: 4),
              Text("${agenda.location}", style: TextStyle(color: onBackground)),
              const SizedBox(height: 24),
              Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold, color: onBackground)),
              const SizedBox(height: 4),
              Text("${agenda.description}", style: TextStyle(color: onBackground)),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.background;
    final accentColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    final onBackground = Theme.of(context).colorScheme.onBackground;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep, color: accentColor),
            onPressed: _clearAllHistory,
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari agenda...",
                hintStyle: TextStyle(color: onBackground.withOpacity(0.54)),
                prefixIcon: Icon(Icons.search, color: onBackground.withOpacity(0.54)),
                filled: true,
                fillColor: cardColor,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Semua'),
                      selected: selectedCategory == 'Semua',
                      selectedColor: isDark ? Colors.white : accentColor,
                      backgroundColor: isDark ? cardColor : cardColor,
                      labelStyle: TextStyle(
                        color: selectedCategory == 'Semua'
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white : onBackground),
                        fontWeight: FontWeight.bold,
                      ),
                      side: BorderSide(color: onBackground),
                      onSelected: (_) => _onCategorySelected('Semua'),
                    ),
                  ),
                  ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      selectedColor: isDark ? Colors.white : accentColor,
                      backgroundColor: isDark ? cardColor : cardColor,
                      labelStyle: TextStyle(
                        color: selectedCategory == cat
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white : onBackground),
                        fontWeight: FontWeight.bold,
                      ),
                      side: BorderSide(color: onBackground),
                      onSelected: (_) => _onCategorySelected(cat),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredSchedules.isEmpty
                  ? const Center(child: Text('Belum ada agenda'))
                  : ListView.builder(
                      itemCount: filteredSchedules.length,
                      itemBuilder: (context, index) {
                        final s = filteredSchedules[index];
                        return Card(
                          color: cardColor,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${s.category}, ${s.title}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text("${s.date}", style: TextStyle(color: onBackground)),
                                    const SizedBox(width: 16),
                                    Text("-  ${s.time}", style: TextStyle(color: onBackground)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text("${s.location}", style: TextStyle(color: onBackground)),
                              ],
                            ),
                            onTap: () => showAgendaDetailModal(context, s),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
