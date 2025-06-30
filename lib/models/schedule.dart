class Schedule {
  final int? id;
  final String category;
  final String title;
  final String date;
  final String time;
  final String location;
  final String description;

  Schedule({
    this.id,
    required this.category,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'description': description,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      category: map['category'],
      title: map['title'],
      date: map['date'],
      time: map['time'],
      location: map['location'],
      description: map['description'],
    );
  }
} 