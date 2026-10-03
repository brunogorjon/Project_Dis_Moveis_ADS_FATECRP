import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../util/currency_utils.dart';
import '../util/date_utils.dart';
import '../widget/app_scope.dart';

class CriarRateioView extends StatefulWidget {
  const CriarRateioView({super.key});

  @override
  State<CriarRateioView> createState() => _CriarRateioViewState();
}

class _CriarRateioViewState extends State<CriarRateioView> {
  final _nome = TextEditingController();
  final _valor = TextEditingController();
  final _capacidade = TextEditingController(text: '8');
  late final List<DateTime> _opcoes;
  late DateTime _inicio;
  late DateTime _fim;
  String? _erro;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _opcoes = proximosMeses(quantidade: 36);
    _inicio = _opcoes.first;
    _fim = _opcoes[5];
  }

  @override
  void dispose() {
    _nome.dispose();
    _valor.dispose();
    _capacidade.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    final nome = _nome.text.trim();
    final valor = converterParaCentavos(_valor.text);
    final capacidade = int.tryParse(_capacidade.text.trim());

    if (nome.length < 3) {
      setState(() => _erro = 'Informe um nome com ao menos 3 caracteres.');
      return;
    }
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe um valor total válido.');
      return;
    }
    if (_fim.isBefore(_inicio)) {
      setState(() => _erro = 'O mês da viagem não pode ser anterior ao início.');
      return;
    }
    if (capacidade == null || capacidade <= 0) {
      setState(() => _erro = 'Informe uma capacidade válida.');
      return;
    }

    setState(() {
      _erro = null;
      _salvando = true;
    });

    await AppScope.of(context).criarRateio(
      nome: nome,
      valorTotalCentavos: valor,
      mesInicial: _inicio,
      mesFinal: _fim,
      capacidade: capacidade,
    );

    if (!mounted) return;
    setState(() => _salvando = false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      'rateio_dashboard',
      ModalRoute.withName('meus_rateios'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quantidadeMeses = mesesEntre(_inicio, _fim).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Novo rateio')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Planeje sua próxima viagem',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Defina o valor e o período. Os compromissos mensais serão distribuídos inicialmente de forma igual e poderão ser ajustados depois.',
                    style: TextStyle(color: AppTheme.muted, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nome,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome do rateio',
                      hintText: 'Ex.: Ubatuba 2027',
                      prefixIcon: Icon(Icons.luggage_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _valor,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor total',
                      hintText: '12000,00',
                      prefixText: 'R\$ ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DateTime>(
                    value: _inicio,
                    decoration: const InputDecoration(
                      labelText: 'Início dos pagamentos',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    items: _opcoes
                        .map(
                          (data) => DropdownMenuItem<DateTime>(
                            value: data,
                            child: Text(formatarMes(data)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _inicio = value;
                        if (_fim.isBefore(_inicio)) _fim = _inicio;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DateTime>(
                    value: _fim,
                    decoration: const InputDecoration(
                      labelText: 'Mês da viagem / mês final',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: _opcoes
                        .where((data) => !data.isBefore(_inicio))
                        .map(
                          (data) => DropdownMenuItem<DateTime>(
                            value: data,
                            child: Text(formatarMes(data)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _fim = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _capacidade,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Limite de participantes',
                      prefixIcon: Icon(Icons.groups_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$quantidadeMeses ${quantidadeMeses == 1 ? 'mês' : 'meses'} no planejamento',
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                  if (_erro != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(_erro!, style: const TextStyle(color: AppTheme.danger)),
                  ],
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: _salvando ? null : _criar,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('CRIAR RATEIO'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
