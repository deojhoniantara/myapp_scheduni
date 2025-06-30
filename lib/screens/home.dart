import 'package:flutter/material.dart';
import 'dart:ui';
import 'add_schedule_form.dart';
import '../db/schedule_db.dart';
import '../models/schedule.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showMenu = false;
  List<Schedule> schedules = [];
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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    filteredSchedules = schedules.where((s) {
      final matchQuery = s.title.toLowerCase().contains(query) ||
          s.category.toLowerCase().contains(query) ||
          s.location.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query);
      final matchCategory = selectedCategory == 'Semua' || s.category == selectedCategory;
      return matchQuery && matchCategory;
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      _applyFilters();
    });
  }

  Future<void> _loadSchedules() async {
    final data = await ScheduleDB.instance.getAllSchedules();
    final now = DateTime.now();
    List<Schedule> upcoming = [];
    for (final s in data) {
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
          if (agendaDateTime.isAfter(now) || agendaDateTime.isAtSameMomentAs(now)) {
            upcoming.add(s);
          }
        } catch (_) {}
      }
    }
    setState(() {
      schedules = upcoming;
      filteredSchedules = upcoming;
    });
  }

  Future<void> _deleteSchedule(int id) async {
    await ScheduleDB.instance.deleteSchedule(id);
    _loadSchedules();
  }

  Future<void> _editSchedule(Schedule schedule) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddScheduleForm(
          category: schedule.category,
          schedule: schedule,
        ),
      ),
    );
    _loadSchedules();
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
    final cardColor = Theme.of(context).colorScheme.surface;
    final onBackground = Theme.of(context).colorScheme.onBackground;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fabBg = isDark ? Colors.white : accentColor;
    final fabIcon = isDark ? Colors.black : Colors.white;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              "SchedUni.",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: accentColor,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                    border: OutlineInputBorder(
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
                          label: Text('Semua'),
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
                                        Text("pukul  ${s.time}", style: TextStyle(color: onBackground)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text("${s.location}", style: TextStyle(color: onBackground)),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      await _deleteSchedule(s.id!);
                                    } else if (value == 'edit') {
                                      await _editSchedule(s);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 18, color: accentColor),
                                            const SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: onBackground)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18, color: accentColor),
                                            const SizedBox(width: 8),
                                            Text('Edit', style: TextStyle(color: onBackground)),
                                          ],
                                        ),
                                      ),
                                    ),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: fabBg,
            onPressed: () {
              setState(() {
                showMenu = !showMenu;
              });
            },
            child: Icon(showMenu ? Icons.close : Icons.add, color: fabIcon),
          ),
        ),
        if (showMenu)
                  Positioned(
                    bottom: 100,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...categories.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddScheduleForm(category: item),
                          ),
                        );
                        setState(() {
                          showMenu = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: fabBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: fabIcon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                ],
            ),
          ),
      ],
    );
  }
}
