import 'dart:convert';

/// A user-defined guided breathing exercise.
///
/// A [Breathing] exercise is built from up to four timed phases:
/// - **Inhale** – breathe in for [countIn] seconds.
/// - **Hold (in)** – pause at full lungs for [holdIn] seconds (optional).
/// - **Exhale** – breathe out for [countOut] seconds.
/// - **Hold (out)** – pause at empty lungs for [holdOut] seconds (optional).
///
/// The complete sequence is repeated [reps] times. Set any phase to `0` to
/// skip it. Exercises are managed via [BreathingNotifier] and persisted through
/// [SqliteBreathingRepository].
///
/// Example:
/// ```dart
/// final boxBreathing = Breathing(
///   id: 1, name: 'Box Breathing',
///   countIn: 4, holdIn: 4, countOut: 4, holdOut: 4,
///   reps: 4,
/// );
/// ```
class Breathing {
  /// Unique identifier (assigned by the database on insert).
  final int id;

  /// Display name shown in lists and headings.
  final String name;

  /// Duration in seconds for the inhale phase. Use `0` to skip.
  final int countIn;

  /// Duration in seconds to hold after inhaling. Use `0` to skip.
  final int holdIn;

  /// Duration in seconds for the exhale phase. Use `0` to skip.
  final int countOut;

  /// Duration in seconds to hold after exhaling. Use `0` to skip.
  final int holdOut;

  /// Number of times the full inhale/hold/exhale/hold cycle is repeated.
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

  /// Returns a copy of this breathing exercise with the given fields replaced.
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

  /// Serialises this breathing exercise to a [Map] suitable for SQLite insertion.
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

  /// Deserialises a [Breathing] from a SQLite row [Map].
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

  /// Serialises this breathing exercise to a JSON string.
  String toJson() => json.encode(toMap());

  /// Deserialises a [Breathing] from a JSON string produced by [toJson].
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

  /// A short human-readable summary of the breathing pattern, e.g. `In 4 - Hold 4 - Out 4 - Hold 4`.
  ///
  /// Phases with a duration of `0` are omitted from the string.
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
