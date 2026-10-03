import '../model/usuario.dart';
import '../util/id_utils.dart';
import 'auth_service.dart';

class MockAuthService implements AuthService {
  final Map<String, _MockAccount> _contas = <String, _MockAccount>{
    'demo@rateio.app': _MockAccount(
      usuario: const Usuario(
        id: 'user_demo',
        nome: 'Usuário Demo',
        email: 'demo@rateio.app',
        telefone: '(16) 99999-9999',
      ),
      senha: '123456',
    ),
  };

  Usuario? _usuarioAtual;

  @override
  Usuario? get usuarioAtual => _usuarioAtual;

  @override
  Future<Usuario> entrar({required String email, required String senha}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final chave = email.trim().toLowerCase();
    final conta = _contas[chave];
    if (conta == null || conta.senha != senha) {
      throw const AuthException('E-mail ou senha inválidos.');
    }
    _usuarioAtual = conta.usuario;
    return conta.usuario;
  }

  @override
  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final chave = email.trim().toLowerCase();
    if (_contas.containsKey(chave)) {
      throw const AuthException('Já existe uma conta com este e-mail.');
    }

    final usuario = Usuario(
      id: IdUtils.next('user'),
      nome: nome.trim(),
      email: chave,
      telefone: telefone.trim(),
    );
    _contas[chave] = _MockAccount(usuario: usuario, senha: senha);
    _usuarioAtual = usuario;
    return usuario;
  }

  @override
  Future<void> recuperarSenha(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final chave = email.trim().toLowerCase();
    if (!_contas.containsKey(chave)) {
      throw const AuthException('Nenhuma conta foi encontrada para este e-mail.');
    }
  }

  @override
  Future<Usuario> atualizarPerfil({
    required String nome,
    required String telefone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final atual = _usuarioAtual;
    if (atual == null) {
      throw const AuthException('Usuário não autenticado.');
    }

    final atualizado = atual.copyWith(
      nome: nome.trim(),
      telefone: telefone.trim(),
    );
    final conta = _contas[atual.email];
    if (conta != null) {
      conta.usuario = atualizado;
    }
    _usuarioAtual = atualizado;
    return atualizado;
  }

  @override
  Future<void> sair() async {
    _usuarioAtual = null;
  }
}

class _MockAccount {
  _MockAccount({required this.usuario, required this.senha});

  Usuario usuario;
  final String senha;
}
