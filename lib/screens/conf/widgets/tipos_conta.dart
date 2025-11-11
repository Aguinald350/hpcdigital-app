// lib/screens/conf/widgets/tipos_conta.dart
import 'package:flutter/material.dart';

class TipoContaResumo {
  final String label;
  final Color color;
  TipoContaResumo(this.label, this.color);
}

class TipoContaDetalhe {
  final String label;
  final String descricao;
  final Color color;
  final int diasRestantes;
  final bool isTrial;
  TipoContaDetalhe({
    required this.label,
    required this.descricao,
    required this.color,
    required this.diasRestantes,
    required this.isTrial,
  });
}
