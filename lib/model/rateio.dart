import 'mes_rateio.dart';
import 'pagamento.dart';
import 'participante.dart';

class Rateio {
  Rateio({
    required this.id,
    required this.ownerId,
    required this.nome,
    required this.valorTotalCentavos,
    required this.capacidade,
    required this.meses,
    List<Participante>? participantes,
    List<Pagamento>? pagamentos,
    this.concluido = false,
    DateTime? criadoEm,
  })  : participantes = participantes ?? <Participante>[],
        pagamentos = pagamentos ?? <Pagamento>[],
        criadoEm = criadoEm ?? DateTime.now();

  final String id;
  final String ownerId;
  String nome;
  int valorTotalCentavos;
  int capacidade;
  List<MesRateio> meses;
  List<Participante> participantes;
  List<Pagamento> pagamentos;
  bool concluido;
  final DateTime criadoEm;

  DateTime get mesInicial => meses.first.data;
  DateTime get mesFinal => meses.last.data;

  Rateio deepCopy() {
    return Rateio(
      id: id,
      ownerId: ownerId,
      nome: nome,
      valorTotalCentavos: valorTotalCentavos,
      capacidade: capacidade,
      meses: meses
          .map(
            (m) => MesRateio(
              id: m.id,
              data: m.data,
              valorDevidoCentavos: m.valorDevidoCentavos,
            ),
          )
          .toList(),
      participantes: participantes.map((p) => p.copy()).toList(),
      pagamentos: pagamentos
          .map(
            (p) => Pagamento(
              id: p.id,
              participanteId: p.participanteId,
              mesId: p.mesId,
              valorCentavos: p.valorCentavos,
              pagoEm: p.pagoEm,
              observacao: p.observacao,
            ),
          )
          .toList(),
      concluido: concluido,
      criadoEm: criadoEm,
    );
  }
}
