class Participante {
  Participante({
    required this.id,
    required this.nome,
    required this.mesInicialId,
    required this.mesFinalId,
    this.ativo = true,
    DateTime? criadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

  final String id;
  String nome;
  String mesInicialId;
  String mesFinalId;
  bool ativo;
  final DateTime criadoEm;

  Participante copy() {
    return Participante(
      id: id,
      nome: nome,
      mesInicialId: mesInicialId,
      mesFinalId: mesFinalId,
      ativo: ativo,
      criadoEm: criadoEm,
    );
  }
}
