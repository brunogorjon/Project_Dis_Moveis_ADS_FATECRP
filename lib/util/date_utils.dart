const _meses = <String>[
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

DateTime inicioDoMes(DateTime value) => DateTime(value.year, value.month);

DateTime adicionarMeses(DateTime value, int quantidade) {
  return DateTime(value.year, value.month + quantidade);
}

String chaveMes(DateTime value) {
  final mes = value.month.toString().padLeft(2, '0');
  return '${value.year}-$mes';
}

String formatarMes(DateTime value) => '${_meses[value.month - 1]}/${value.year}';

String formatarMesCurto(DateTime value) {
  final nome = _meses[value.month - 1].substring(0, 3);
  return '$nome/${value.year.toString().substring(2)}';
}

List<DateTime> mesesEntre(DateTime inicio, DateTime fim) {
  final primeiro = inicioDoMes(inicio);
  final ultimo = inicioDoMes(fim);
  final meses = <DateTime>[];
  var atual = primeiro;
  while (!atual.isAfter(ultimo)) {
    meses.add(atual);
    atual = adicionarMeses(atual, 1);
  }
  return meses;
}

List<DateTime> proximosMeses({int quantidade = 36}) {
  final hoje = inicioDoMes(DateTime.now());
  return List<DateTime>.generate(
    quantidade,
    (index) => adicionarMeses(hoje, index),
  );
}
