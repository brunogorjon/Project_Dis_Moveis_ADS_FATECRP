import 'package:flutter/material.dart';

import '../controller/app_controller.dart';
import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import '../widget/app_scope.dart';
import '../widget/section_card.dart';

class RegistrarPagamentoView extends StatefulWidget {
  const RegistrarPagamentoView({
    super.key,
    this.participanteIdInicial,
    this.mesIdInicial,
  });

  final String? participanteIdInicial;
  final String? mesIdInicial;

  @override
  State<RegistrarPagamentoView> createState() => _RegistrarPagamentoViewState();
}

class _RegistrarPagamentoViewState extends State<RegistrarPagamentoView> {
  final _valor = TextEditingController();
  final _observacao = TextEditingController();
  String? _participanteId;
  String? _mesId;
  String? _erro;
  bool _inicializado = false;
  bool _salvando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    if (rateio == null) return;

    _participanteId = widget.participanteIdInicial ??
        (rateio.participantes.isNotEmpty ? rateio.participantes.first.id : null);
    _mesId = widget.mesIdInicial ?? (rateio.meses.isNotEmpty ? rateio.meses.first.id : null);
    _atualizarValorSugerido(app);
  }

  @override
  void dispose() {
    _valor.dispose();
    _observacao.dispose();
    super.dispose();
  }

  void _atualizarValorSugerido(AppController app) {
    if (_participanteId == null || _mesId == null) return;
    final rateio = app.rateioSelecionado;
    final calculo = app.calculoSelecionado;
    if (rateio == null || calculo == null) return;
    final planejado = calculo.valorPlanejado(_participanteId!, _mesId!);
    final pago = rateio.pagamentos
        .where((p) => p.participanteId == _participanteId && p.mesId == _mesId)
        .fold<int>(0, (a, b) => a + b.valorCentavos);
    final falta = planejado - pago;
    _valor.text = centavosParaCampo(falta > 0 ? falta : 0);
  }

  Future<void> _registrar() async {
    final valor = converterParaCentavos(_valor.text);
    if (_participanteId == null || _mesId == null) {
      setState(() => _erro = 'Selecione um participante e um mês.');
      return;
    }
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe um valor maior que zero.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final erro = await AppScope.of(context).registrarPagamento(
      participanteId: _participanteId!,
      mesId: _mesId!,
      valorCentavos: valor,
      observacao: _observacao.text,
    );

    if (!mounted) return;
    setState(() {
      _salvando = false;
      _erro = erro;
    });
    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pagamento registrado com sucesso.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    final calculo = app.calculoSelecionado;

    if (rateio == null || calculo == null) {
      return const Scaffold(body: Center(child: Text('Nenhum rateio selecionado.')));
    }

    final planejado = _participanteId != null && _mesId != null
        ? calculo.valorPlanejado(_participanteId!, _mesId!)
        : 0;
    final pago = _participanteId != null && _mesId != null
        ? rateio.pagamentos
            .where((p) => p.participanteId == _participanteId && p.mesId == _mesId)
            .fold<int>(0, (a, b) => a + b.valorCentavos)
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pagamento')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (rateio.participantes.isEmpty)
                    const SectionCard(
                      child: Text(
                        'Adicione pelo menos um participante antes de registrar pagamentos.',
                        style: TextStyle(color: AppTheme.warning),
                      ),
                    )
                  else ...<Widget>[
                    DropdownButtonFormField<String>(
                      value: _participanteId,
                      decoration: const InputDecoration(
                        labelText: 'Participante',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: rateio.participantes
                          .where((p) => p.ativo)
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(p.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _participanteId = value);
                        _atualizarValorSugerido(app);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _mesId,
                      decoration: const InputDecoration(
                        labelText: 'Mês',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      items: rateio.meses
                          .map(
                            (m) => DropdownMenuItem<String>(
                              value: m.id,
                              child: Text(formatarMes(m.data)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _mesId = value);
                        _atualizarValorSugerido(app);
                      },
                    ),
                    const SizedBox(height: 12),
                    SectionCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _Info(label: 'PREVISTO', value: formatarCentavos(planejado)),
                          ),
                          Expanded(
                            child: _Info(label: 'JÁ PAGO', value: formatarCentavos(pago), color: AppTheme.success),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _valor,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Valor pago agora',
                        prefixText: 'R\$ ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _observacao,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        labelText: 'Observação',
                        hintText: 'Opcional',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    if (_erro != null) ...<Widget>[
                      Text(_erro!, style: const TextStyle(color: AppTheme.danger)),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton.icon(
                      onPressed: _salvando ? null : _registrar,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('REGISTRAR PAGAMENTO'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
        ),
      ],
    );
  }
}
