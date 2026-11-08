import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/mes_rateio.dart';
import '../model/pagamento.dart';
import '../model/participante.dart';
import '../model/rateio.dart';

/// Conversão isolada do domínio para os documentos do Firestore.
class RateioFirestoreMapper {
  const RateioFirestoreMapper();

  Map<String, dynamic> toMap(Rateio rateio) => {
    'ownerId': rateio.ownerId,
    'nome': rateio.nome,
    'valorTotalCentavos': rateio.valorTotalCentavos,
    'capacidade': rateio.capacidade,
    'concluido': rateio.concluido,
    'criadoEm': Timestamp.fromDate(rateio.criadoEm),
    'meses': rateio.meses
        .map(
          (mes) => {
            'id': mes.id,
            'data': Timestamp.fromDate(mes.data),
            'valorDevidoCentavos': mes.valorDevidoCentavos,
          },
        )
        .toList(),
    'participantes': rateio.participantes
        .map(
          (p) => {
            'id': p.id,
            'nome': p.nome,
            'mesInicialId': p.mesInicialId,
            'mesFinalId': p.mesFinalId,
            'ativo': p.ativo,
            'criadoEm': Timestamp.fromDate(p.criadoEm),
          },
        )
        .toList(),
    'pagamentos': rateio.pagamentos
        .map(
          (p) => {
            'id': p.id,
            'participanteId': p.participanteId,
            'mesId': p.mesId,
            'valorCentavos': p.valorCentavos,
            'pagoEm': Timestamp.fromDate(p.pagoEm),
            'observacao': p.observacao,
          },
        )
        .toList(),
  };

  Rateio fromMap(String id, Map<String, dynamic> data) {
    final meses = _lista(data, 'meses');
    if (meses.isEmpty) throw const FormatException('Rateio sem meses.');
    return Rateio(
      id: id,
      ownerId: _string(data, 'ownerId'),
      nome: _string(data, 'nome'),
      valorTotalCentavos: _inteiro(data, 'valorTotalCentavos'),
      capacidade: _inteiro(data, 'capacidade'),
      concluido: _boolean(data, 'concluido', false),
      criadoEm: _data(data, 'criadoEm'),
      meses: meses
          .map(
            (m) => MesRateio(
              id: _string(m, 'id'),
              data: _data(m, 'data'),
              valorDevidoCentavos: _inteiro(m, 'valorDevidoCentavos'),
            ),
          )
          .toList(),
      participantes: _lista(data, 'participantes', optional: true)
          .map(
            (p) => Participante(
              id: _string(p, 'id'),
              nome: _string(p, 'nome'),
              mesInicialId: _string(p, 'mesInicialId'),
              mesFinalId: _string(p, 'mesFinalId'),
              ativo: _boolean(p, 'ativo', true),
              criadoEm: _data(p, 'criadoEm'),
            ),
          )
          .toList(),
      pagamentos: _lista(data, 'pagamentos', optional: true)
          .map(
            (p) => Pagamento(
              id: _string(p, 'id'),
              participanteId: _string(p, 'participanteId'),
              mesId: _string(p, 'mesId'),
              valorCentavos: _inteiro(p, 'valorCentavos'),
              pagoEm: _data(p, 'pagoEm'),
              observacao: p.containsKey('observacao')
                  ? _string(p, 'observacao')
                  : '',
            ),
          )
          .toList(),
    );
  }

  String _string(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String) return value;
    throw FormatException('Campo $key deve ser texto.');
  }

  int _inteiro(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is int) return value;
    throw FormatException('Campo $key deve ser inteiro.');
  }

  bool _boolean(Map<String, dynamic> map, String key, bool fallback) {
    if (!map.containsKey(key)) return fallback;
    final value = map[key];
    if (value is bool) return value;
    throw FormatException('Campo $key deve ser booleano.');
  }

  DateTime _data(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw FormatException('Campo $key deve ser uma data.');
  }

  List<Map<String, dynamic>> _lista(
    Map<String, dynamic> map,
    String key, {
    bool optional = false,
  }) {
    if (optional && !map.containsKey(key)) return [];
    final value = map[key];
    if (value is! List) throw FormatException('Campo $key deve ser uma lista.');
    return value.map((item) {
      if (item is! Map) throw FormatException('Item de $key deve ser um mapa.');
      try {
        return Map<String, dynamic>.from(item);
      } catch (_) {
        throw FormatException('Item inválido em $key.');
      }
    }).toList();
  }
}
