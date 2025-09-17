class CountdownEvent {
  final String id;
  final String name;
  final DateTime date;
  final DateTime? time;
  final String icon;
  final bool notificationEnabled;

  const CountdownEvent({
    required this.id,
    required this.name,
    required this.date,
    this.time,
    required this.icon,
    this.notificationEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'icon': icon,
      'notificationEnabled': notificationEnabled,
    };
  }

  factory CountdownEvent.fromMap(Map<String, dynamic> map) {
    return CountdownEvent(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      time: map['time'] != null ? DateTime.parse(map['time']) : null,
      icon: map['icon'],
      notificationEnabled: map['notificationEnabled'] ?? false,
    );
  }

  CountdownEvent copyWith({
    String? id,
    String? name,
    DateTime? date,
    DateTime? time,
    String? icon,
    bool? notificationEnabled,
  }) {
    return CountdownEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }
}
