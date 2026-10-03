String formatarCentavos(int centavos) {
  final negativo = centavos < 0;
  final absoluto = centavos.abs();
  final reais = absoluto ~/ 100;
  final centavosRestantes = (absoluto % 100).toString().padLeft(2, '0');

  final texto = reais.toString();
  final grupos = <String>[];
  for (var fim = texto.length; fim > 0; fim -= 3) {
    final inicio = fim - 3 < 0 ? 0 : fim - 3;
    grupos.insert(0, texto.substring(inicio, fim));
  }
  final reaisFormatados = grupos.join('.');
  return '${negativo ? '-' : ''}R\$ $reaisFormatados,$centavosRestantes';
}

int? converterParaCentavos(String entrada) {
  var texto = entrada
      .trim()
      .replaceAll(RegExp(r'R\$', caseSensitive: false), '')
      .replaceAll(' ', '');

  if (texto.isEmpty) return null;

  if (texto.contains(',') && texto.contains('.')) {
    texto = texto.replaceAll('.', '').replaceAll(',', '.');
  } else if (texto.contains(',')) {
    texto = texto.replaceAll(',', '.');
  }

  final valor = double.tryParse(texto);
  if (valor == null) return null;
  return (valor * 100).round();
}

String centavosParaCampo(int centavos) {
  final inteiro = centavos ~/ 100;
  final decimal = (centavos.abs() % 100).toString().padLeft(2, '0');
  return '$inteiro,$decimal';
}
