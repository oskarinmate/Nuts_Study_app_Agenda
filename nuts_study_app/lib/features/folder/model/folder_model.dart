import 'package:flutter/material.dart';

class Folder {
  final int? id;
  final String name;
  final int colorValue; // Guardamos el color como entero

  Folder({
    this.id,
    required this.name,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      colorValue: map['colorValue'],
    );
  }
}