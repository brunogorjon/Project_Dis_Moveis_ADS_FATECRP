import 'package:flutter/material.dart';

import '../controller/cadastro_usuario_controller.dart';
import '../theme/app_theme.dart';
import '../widget/app_scope.dart';

class CadastroUsuarioView extends StatefulWidget {
  const CadastroUsuarioView({super.key});

  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}

class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  final _controller = CadastroUsuarioController();
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final ok = await _controller.cadastrar(
      AppScope.of(context),
      nome: _nome.text,
      email: _email.text,
      telefone: _telefone.text,
      senha: _senha.text,
      confirmacao: _confirmacao.text,
    );
    if (!mounted || !ok) return;
    Navigator.pushNamedAndRemoveUntil(context, 'meus_rateios', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
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
                      Text(
                        'Cadastre seus dados',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Depois do cadastro você já poderá criar seu primeiro rateio.',
                        style: TextStyle(color: AppTheme.muted),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nome,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
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
                      const SizedBox(height: 12),
                      TextField(
                        controller: _senha,
                        obscureText: _ocultarSenha,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                            icon: Icon(
                              _ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmacao,
                        obscureText: _ocultarSenha,
                        onSubmitted: (_) => _cadastrar(),
                        decoration: const InputDecoration(
                          labelText: 'Confirmação de senha',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      if (_controller.erro != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          _controller.erro!,
                          style: const TextStyle(color: AppTheme.danger),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _controller.carregando ? null : _cadastrar,
                        child: _controller.carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('CADASTRAR'),
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
