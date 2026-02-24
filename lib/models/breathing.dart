import 'dart:convert';

class Breathing {
  final int id;
  final String name;
  final int countIn;
  final int holdIn;
  final int countOut;
  final int holdOut;
  final int reps;

  Breathing({
    required this.id,
    required this.name,
    required this.countIn,
    required this.holdIn,
    required this.countOut,
    required this.holdOut,
    required this.reps,
  });

  Breathing copyWith({
    int? id,
    String? name,
    int? countIn,
    int? holdIn,
    int? countOut,
    int? holdOut,
    int? reps,
  }) {
    return Breathing(
      id: id ?? this.id,
      name: name ?? this.name,
      countIn: countIn ?? this.countIn,
      holdIn: holdIn ?? this.holdIn,
      countOut: countOut ?? this.countOut,
      holdOut: holdOut ?? this.holdOut,
      reps: reps ?? this.reps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'countIn': countIn,
      'holdIn': holdIn,
      'countOut': countOut,
      'holdOut': holdOut,
      'reps': reps,
    };
  }

  factory Breathing.fromMap(Map<String, dynamic> map) {
    return Breathing(
      id: map['id'] as int,
      name: map['name'] as String,
      countIn: map['countIn'] as int,
      holdIn: map['holdIn'] as int,
      countOut: map['countOut'] as int,
      holdOut: map['holdOut'] as int,
      reps: map['reps'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Breathing.fromJson(String source) =>
      Breathing.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Breathing(id: $id, name: $name, countIn: $countIn, holdIn: $holdIn, countOut: $countOut, holdOut: $holdOut, reps: $reps)';
  }

  @override
  bool operator ==(covariant Breathing other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.countIn == countIn &&
        other.holdIn == holdIn &&
        other.countOut == countOut &&
        other.holdOut == holdOut &&
        other.reps == reps;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        countIn.hashCode ^
        holdIn.hashCode ^
        countOut.hashCode ^
        holdOut.hashCode ^
        reps.hashCode;
  }

  String get humanReadable {
    String returnString = "In $countIn";

    if (holdIn > 0) {
      returnString = "$returnString - Hold $holdIn";
    }

    returnString = "$returnString - Out $countOut";

    if (holdOut > 0) {
      returnString = "$returnString - Hold $holdOut";
    }

    return returnString;
  }
}
