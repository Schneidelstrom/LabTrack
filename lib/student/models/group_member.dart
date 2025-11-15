class GroupMember {
  final String upmail;
  final String name;

  const GroupMember({
    required this.upmail,
    required this.name,
  });

  @override
  bool operator == (Object other) => identical(this, other) || other is GroupMember && runtimeType == other.runtimeType && upmail == other.upmail;

  @override
  int get hashCode => upmail.hashCode;
}