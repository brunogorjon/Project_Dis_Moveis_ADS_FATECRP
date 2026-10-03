import 'package:flutter/material.dart';

import '../util/validators.dart';
import 'app_controller.dart';

class CadastroUsuarioController extends ChangeNotifier {
  bool _carregando = false;
  String? _erro;

  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<bool> cadastrar(
    AppController app, {
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String confirmacao,
  }) async {
    _erro = Validators.nome(nome) ??
        Validators.email(email) ??
        (telefone.trim().isEmpty ? 'Informe o telefone.' : null) ??
        Validators.senha(senha);

    if (_erro == null && senha != confirmacao) {
      _erro = 'A confirmação de senha deve ser igual à senha.';
    }

    if (_erro != null) {
      notifyListeners();
      return false;
    }

    _carregando = true;
    notifyListeners();
    _erro = await app.cadastrar(
      nome: nome.trim(),
      email: email.trim(),
      telefone: telefone.trim(),
      senha: senha,
    );
    _carregando = false;
    notifyListeners();
    return _erro == null;
  }
}
