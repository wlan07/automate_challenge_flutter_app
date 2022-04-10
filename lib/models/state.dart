import 'package:automate_challenge_flutter_app/enum/state_enum.dart';
import 'package:flutter/material.dart';

class Etat {
  final StateType type;
  final int id;
  final Offset offset;
  final String? label;

  Etat({
    this.label,
    required this.type,
    required this.id,
    required this.offset,
  });

  Etat copyWith({Offset? offset, int? id, String? label}) {
    return Etat(
      type: type,
      id: id ?? this.id,
      label: label ?? this.label,
      offset: offset ?? this.offset,
    );
  }

  String get image {
    return states[type.index];
  }

  static String imageByType(StateType t) {
    return states[t.index];
  }

  static const List<String> states = [
    "assets/simple_state.png",
    "assets/final_state.png",
    "assets/simple_start_state.png",
    "assets/end_start_state.png",
    "assets/initial_boucle.png",
    "assets/end_boucle.png",
    "assets/simple_boucle.png",
    "assets/initial_final_boucle.png",
  ];
}
