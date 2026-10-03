import 'package:flutter/material.dart';

import '../controller/perfil_controller.dart';
import '../theme/app_theme.dart';
import '../widget/app_scope.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final _controller = PerfilController();
  TextEditingController? _nome;
  TextEditingController? _telefone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nome != null) return;
    final usuario = AppScope.of(context).usuario;
    _nome = TextEditingController(text: usuario?.nome ?? '');
    _telefone = TextEditingController(text: usuario?.telefone ?? '');
  }

  @override
  void dispose() {
    _nome?.dispose();
    _telefone?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final ok = await _controller.salvar(
      AppScope.of(context),
      nome: _nome?.text ?? '',
      telefone: _telefone?.text ?? '',
    );
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.of(context).usuario;
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Align(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: AppTheme.primaryStrong,
                          child: Icon(Icons.person, color: Colors.white, size: 42),
                        ),
                      ),
                      const SizedBox(height: 26),
                      TextField(
                        controller: _nome,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: usuario?.email ?? '',
                        readOnly: true,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                          helperText: 'O e-mail é utilizado na autenticação e não pode ser alterado aqui.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _telefone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      if (_controller.erro != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(_controller.erro!, style: const TextStyle(color: AppTheme.danger)),
                      ],
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: _controller.carregando ? null : _salvar,
                        child: const Text('SALVAR ALTERAÇÕES'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
