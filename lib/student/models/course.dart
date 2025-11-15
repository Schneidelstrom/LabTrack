class Course {
  final String code;
  final String title;

  const Course({
    required this.code,
    required this.title,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Course && other.code == code && other.title == title;
  }

  @override
  int get hashCode => code.hashCode ^ title.hashCode;
}