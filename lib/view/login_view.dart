import 'package:flutter/material.dart';

import '../controller/login_controller.dart';
import '../theme/app_theme.dart';
import '../widget/app_logo.dart';
import '../widget/app_scope.dart';
import '../widget/section_card.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _controller = LoginController();
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final app = AppScope.of(context);
    final ok = await _controller.entrar(
      app,
      email: _email.text,
      senha: _senha.text,
    );
    if (!mounted || !ok) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      'meus_rateios',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Align(child: AppLogo()),
                      const SizedBox(height: 22),
                      Text(
                        'RatAPP',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Faça o rateio das sua viagens, organizando os valores, os participantes e os pagamentos de forma simples e prática.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.muted, height: 1.4),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _senha,
                        obscureText: _ocultarSenha,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _entrar(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _ocultarSenha = !_ocultarSenha),
                            icon: Icon(
                              _ocultarSenha
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, 'recuperar_senha'),
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ),
                      if (_controller.erro != null) ...<Widget>[
                        Text(
                          _controller.erro!,
                          style: const TextStyle(color: AppTheme.danger),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton(
                        onPressed: _controller.carregando ? null : _entrar,
                        child: _controller.carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('ENTRAR'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _controller.carregando
                            ? null
                            : () => Navigator.pushNamed(
                                context,
                                'cadastro_usuario',
                              ),
                        child: const Text('CRIAR CONTA'),
                      ),
                      const SizedBox(height: 22),
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text(
                              'Acesso de demonstração',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'demo@rateio.app  •  senha: 123456',
                              style: TextStyle(color: AppTheme.muted),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'A autenticação está mockada, pensando em uma api de autenticação futura. Para acessar a aplicação, utilize o e-mail e senha acima.',
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
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
