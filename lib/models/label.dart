class Label {
  final int? id;
  final String name;

  Label({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'],
      name: map['name'],
    );
  }
}