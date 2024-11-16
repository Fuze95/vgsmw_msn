class Label {
  final int? id;
  final String name;
  final String? color;

  Label({
    this.id,
    required this.name,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }
}