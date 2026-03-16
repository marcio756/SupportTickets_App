class Team {
  final String id;
  final String name;
  final String shift;

  Team({required this.id, required this.name, required this.shift});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'].toString(),
      name: json['name'],
      shift: json['shift'],
    );
  }
}