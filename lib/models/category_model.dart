class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int jobCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.jobCount = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'work',
      jobCount: map['jobCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'jobCount': jobCount,
    };
  }
}
