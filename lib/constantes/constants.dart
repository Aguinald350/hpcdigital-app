// lib/constantes/constants.dart

/// Lista oficial de classes/públicos-alvo para eventos
const List<String> kListaClassesEventos = [
  'criancas',
  'JIMUA',
  'OJA',
  'Org.Mulheres',
  'Org.Homens',
  'Jovens',
  'Jovens Adultos',
  'Gerais',
];

/// Adiciona dinamicamente valores "legados" que não estão na lista oficial
List<String> gerarListaComValorLegado(String? valorSalvo) {
  final lista = List<String>.from(kListaClassesEventos);

  if (valorSalvo != null &&
      valorSalvo.trim().isNotEmpty &&
      !lista.contains(valorSalvo)) {
    lista.add(valorSalvo); // mantém valor original para edição
  }

  return lista;
}
