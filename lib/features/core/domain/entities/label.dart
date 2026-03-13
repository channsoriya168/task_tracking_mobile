class Label {
  final String id;
  final String name;
  final String? color;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Label({
    required this.id,
    required this.name,
    this.color,
    this.description,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
