class GroupMember {
  final String email;
  final String name;

  GroupMember({
    required this.email,
    required this.name
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is GroupMember && runtimeType == other.runtimeType && email == other.email;

  @override
  int get hashCode => email.hashCode;
}