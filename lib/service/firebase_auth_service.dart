import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../model/usuario.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Usuario? _usuario;

  @override
  Usuario? get usuarioAtual => _usuario;

  Future<Usuario?> restaurarSessao() async {
    final user = await _auth.authStateChanges().first;
    if (user == null) return null;
    return _usuario = await _lerPerfil(user);
  }

  Future<Usuario> _lerPerfil(firebase.User user) async {
    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    final data = doc.data();
    if (data == null) {
      throw const AuthException(
        'Seu perfil não foi encontrado. Entre em contato com o suporte.',
      );
    }
    return Usuario(
      id: user.uid,
      nome: data['nome'] as String,
      email: user.email ?? '',
      telefone: data['telefone'] as String,
    );
  }

  String _mensagem(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'E-mail ou senha inválidos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      default:
        return 'Não foi possível concluir a autenticação. Tente novamente.';
    }
  }

  @override
  Future<Usuario> entrar({required String email, required String senha}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      try {
        return _usuario = await _lerPerfil(credential.user!);
      } catch (_) {
        await _auth.signOut();
        rethrow;
      }
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(_mensagem(e));
    }
  }

  @override
  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    firebase.User? user;
    try {
      user = (await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      )).user!;
      await _firestore.collection('usuarios').doc(user.uid).set({
        'nome': nome.trim(),
        'email': user.email,
        'telefone': telefone.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      return _usuario = Usuario(
        id: user.uid,
        nome: nome.trim(),
        email: user.email!,
        telefone: telefone.trim(),
      );
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(_mensagem(e));
    } catch (_) {
      if (user != null) {
        try {
          await user.delete();
        } catch (_) {
          await _auth.signOut();
          throw const AuthException(
            'A conta foi criada, mas o perfil não pôde ser salvo. Entre em contato com o suporte antes de tentar novamente.',
          );
        }
      }
      throw const AuthException(
        'Não foi possível salvar seu cadastro. Tente novamente.',
      );
    }
  }

  @override
  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(_mensagem(e));
    }
  }

  @override
  Future<Usuario> atualizarPerfil({
    required String nome,
    required String telefone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Usuário não autenticado.');
    await _firestore.collection('usuarios').doc(user.uid).update({
      'nome': nome.trim(),
      'telefone': telefone.trim(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
    return _usuario = Usuario(
      id: user.uid,
      nome: nome.trim(),
      email: user.email ?? '',
      telefone: telefone.trim(),
    );
  }

  @override
  Future<void> sair() async {
    await _auth.signOut();
    _usuario = null;
  }
}
