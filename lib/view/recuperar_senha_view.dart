import 'package:flutter/material.dart';

import '../controller/recuperar_senha_controller.dart';
import '../theme/app_theme.dart';
import '../widget/app_scope.dart';
import '../widget/section_card.dart';

class RecuperarSenhaView extends StatefulWidget {
  const RecuperarSenhaView({super.key});

  @override
  State<RecuperarSenhaView> createState() => _RecuperarSenhaViewState();
}

class _RecuperarSenhaViewState extends State<RecuperarSenhaView> {
  final _email = TextEditingController();
  final _controller = RecuperarSenhaController();

  @override
  void dispose() {
    _email.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _recuperar() async {
    await _controller.recuperar(AppScope.of(context), _email.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
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
                      const Icon(Icons.mark_email_read_outlined, size: 62, color: AppTheme.primary),
                      const SizedBox(height: 18),
                      Text(
                        'Esqueceu sua senha?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Informe o e-mail cadastrado. Na integração final com Firebase, as instruções de redefinição serão enviadas para ele.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.muted, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (_) => _recuperar(),
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      if (_controller.erro != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          _controller.erro!,
                          style: const TextStyle(color: AppTheme.danger),
                        ),
                      ],
                      if (_controller.enviado) ...<Widget>[
                        const SizedBox(height: 14),
                        const SectionCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.check_circle_outline, color: AppTheme.success),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Solicitação validada. No Firebase, este ponto chamará o envio real do e-mail de recuperação.',
                                  style: TextStyle(color: AppTheme.success),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _controller.carregando ? null : _recuperar,
                        child: _controller.carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('SOLICITAR RECUPERAÇÃO'),
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
