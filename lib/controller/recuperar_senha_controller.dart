import 'package:flutter/material.dart';

import '../util/validators.dart';
import 'app_controller.dart';

class RecuperarSenhaController extends ChangeNotifier {
  bool _carregando = false;
  String? _erro;
  bool _enviado = false;

  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get enviado => _enviado;

  Future<bool> recuperar(AppController app, String email) async {
    _erro = Validators.email(email);
    _enviado = false;
    if (_erro != null) {
      notifyListeners();
      return false;
    }

    _carregando = true;
    notifyListeners();
    _erro = await app.recuperarSenha(email.trim());
    _carregando = false;
    _enviado = _erro == null;
    notifyListeners();
    return _enviado;
  }
}
