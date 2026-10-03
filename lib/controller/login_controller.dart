import 'package:flutter/material.dart';

import '../util/validators.dart';
import 'app_controller.dart';

class LoginController extends ChangeNotifier {
  bool _carregando = false;
  String? _erro;

  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<bool> entrar(
    AppController app, {
    required String email,
    required String senha,
  }) async {
    _erro = Validators.email(email) ?? Validators.senha(senha);
    if (_erro != null) {
      notifyListeners();
      return false;
    }

    _carregando = true;
    _erro = null;
    notifyListeners();
    _erro = await app.entrar(email: email.trim(), senha: senha);
    _carregando = false;
    notifyListeners();
    return _erro == null;
  }
}
