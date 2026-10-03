class Pagamento {
  Pagamento({
    required this.id,
    required this.participanteId,
    required this.mesId,
    required this.valorCentavos,
    required this.pagoEm,
    this.observacao = '',
  });

  final String id;
  final String participanteId;
  final String mesId;
  final int valorCentavos;
  final DateTime pagoEm;
  final String observacao;
}
