import 'package:flutter/material.dart';

import '../model/participante.dart';
import '../theme/app_theme.dart';
import '../util/date_utils.dart';
import '../util/validators.dart';
import '../widget/app_scope.dart';
import '../widget/section_card.dart';

class ParticipanteFormView extends StatefulWidget {
  const ParticipanteFormView({super.key, this.participanteId});

  final String? participanteId;

  @override
  State<ParticipanteFormView> createState() => _ParticipanteFormViewState();
}

class _ParticipanteFormViewState extends State<ParticipanteFormView> {
  final _nome = TextEditingController();
  String? _mesInicialId;
  String? _mesFinalId;
  bool _inicializado = false;
  bool _salvando = false;
  String? _erro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;

    final rateio = AppScope.of(context).rateioSelecionado;
    if (rateio == null) return;
    _mesInicialId = rateio.meses.first.id;
    _mesFinalId = rateio.meses.last.id;

    if (widget.participanteId != null) {
      Participante? participante;
      for (final item in rateio.participantes) {
        if (item.id == widget.participanteId) {
          participante = item;
          break;
        }
      }
      if (participante != null) {
        _nome.text = participante.nome;
        _mesInicialId = participante.mesInicialId;
        _mesFinalId = participante.mesFinalId;
      }
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    if (rateio == null) return;

    final erroNome = Validators.nome(_nome.text);
    if (erroNome != null) {
      setState(() => _erro = erroNome);
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final erro = widget.participanteId == null
        ? await app.adicionarParticipante(
            nome: _nome.text,
            mesInicialId: _mesInicialId!,
            mesFinalId: _mesFinalId!,
          )
        : await app.atualizarParticipante(
            participanteId: widget.participanteId!,
            nome: _nome.text,
            mesInicialId: _mesInicialId!,
            mesFinalId: _mesFinalId!,
          );

    if (!mounted) return;
    setState(() {
      _salvando = false;
      _erro = erro;
    });
    if (erro == null) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    final id = widget.participanteId;
    if (id == null) return;
    final app = AppScope.of(context);
    if (app.participanteTemPagamentos(id)) {
      setState(() => _erro = 'Não é possível excluir uma pessoa que já possui pagamentos confirmados.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir participante?'),
        content: const Text('As parcelas serão recalculadas de acordo com os eventos de entrada restantes.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;
    final erro = await app.excluirParticipante(id);
    if (!mounted) return;
    if (erro == null) {
      Navigator.pop(context);
    } else {
      setState(() => _erro = erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rateio = app.rateioSelecionado;
    final editando = widget.participanteId != null;

    if (rateio == null) {
      return const Scaffold(body: Center(child: Text('Nenhum rateio selecionado.')));
    }

    final temPagamentos = editando && app.participanteTemPagamentos(widget.participanteId!);

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar participante' : 'Novo participante')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _nome,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _mesInicialId,
                    decoration: const InputDecoration(
                      labelText: 'Participa a partir de',
                      prefixIcon: Icon(Icons.login),
                    ),
                    items: rateio.meses
                        .map(
                          (mes) => DropdownMenuItem<String>(
                            value: mes.id,
                            child: Text(formatarMes(mes.data)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _mesInicialId = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _mesFinalId,
                    decoration: const InputDecoration(
                      labelText: 'Participa até',
                      prefixIcon: Icon(Icons.logout),
                    ),
                    items: rateio.meses
                        .map(
                          (mes) => DropdownMenuItem<String>(
                            value: mes.id,
                            child: Text(formatarMes(mes.data)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _mesFinalId = value),
                  ),
                  if (temPagamentos) ...<Widget>[
                    const SizedBox(height: 14),
                    const SectionCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.info_outline, color: AppTheme.warning),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Este participante já possui pagamentos. Alterar o período não apaga o histórico registrado.',
                              style: TextStyle(color: AppTheme.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_erro != null) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(_erro!, style: const TextStyle(color: AppTheme.danger)),
                  ],
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: _salvando ? null : _salvar,
                    child: Text(editando ? 'SALVAR ALTERAÇÕES' : 'ADICIONAR PARTICIPANTE'),
                  ),
                  if (editando) ...<Widget>[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: temPagamentos ? null : _excluir,
                      icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                      label: const Text('EXCLUIR PARTICIPANTE', style: TextStyle(color: AppTheme.danger)),
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
