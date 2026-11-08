import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'controller/app_controller.dart';
import 'firebase_options.dart';
import 'service/firebase_auth_service.dart';
import 'service/firestore_rateio_service.dart';
import 'service/mock_auth_service.dart';
import 'service/mock_rateio_service.dart';
import 'theme/app_theme.dart';
import 'view/cadastro_usuario_view.dart';
import 'view/configuracoes_rateio_view.dart';
import 'view/criar_rateio_view.dart';
import 'view/login_view.dart';
import 'view/meus_rateios_view.dart';
import 'view/pagamentos_view.dart';
import 'view/participantes_view.dart';
import 'view/perfil_view.dart';
import 'view/rateio_dashboard_view.dart';
import 'view/rateio_mensal_view.dart';
import 'view/recuperar_senha_view.dart';
import 'view/sobre_view.dart';
import 'widget/app_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (error, stackTrace) {
      debugPrint('Erro ao inicializar o Firebase: $error\n$stackTrace');
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Não foi possível iniciar o aplicativo. Tente novamente.',
              ),
            ),
          ),
        ),
      );
      return;
    }
  }
  final firebaseAuthService = kIsWeb ? FirebaseAuthService() : null;
  final controller = AppController(
    authService: firebaseAuthService ?? MockAuthService(),
    rateioService: kIsWeb ? FirestoreRateioService() : MockRateioService(),
  );

  if (firebaseAuthService != null) {
    try {
      final usuario = await firebaseAuthService.restaurarSessao();
      if (usuario != null) await controller.restaurarUsuario(usuario);
    } catch (error, stackTrace) {
      debugPrint('Erro ao restaurar sessão: $error\n$stackTrace');
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Não foi possível recuperar sua sessão. Verifique sua conexão e recarregue a página.',
              ),
            ),
          ),
        ),
      );
      return;
    }
  }

  runApp(MainApp(controller: controller));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<User?>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _sessionSubscription = FirebaseAuth.instance.authStateChanges().listen((
        user,
      ) {
        final current = widget.controller.usuario;
        if (current != null && user?.uid != current.id) {
          widget.controller.limparSessao();
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            'login',
            (_) => false,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  WidgetBuilder _privada(WidgetBuilder builder) {
    return (context) =>
        widget.controller.autenticado ? builder(context) : const LoginView();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Rateio de Viagem',
        theme: AppTheme.dark,
        initialRoute: widget.controller.autenticado ? 'meus_rateios' : 'login',
        routes: <String, WidgetBuilder>{
          'login': (context) => const LoginView(),
          'cadastro_usuario': (context) => const CadastroUsuarioView(),
          'recuperar_senha': (context) => const RecuperarSenhaView(),
          'meus_rateios': _privada((context) => const MeusRateiosView()),
          'criar_rateio': _privada((context) => const CriarRateioView()),
          'rateio_dashboard': _privada(
            (context) => const RateioDashboardView(),
          ),
          'participantes': _privada((context) => const ParticipantesView()),
          'pagamentos': _privada((context) => const PagamentosView()),
          'rateio_mensal': _privada((context) => const RateioMensalView()),
          'configuracoes_rateio': _privada(
            (context) => const ConfiguracoesRateioView(),
          ),
          'perfil': _privada((context) => const PerfilView()),
          'sobre': _privada((context) => const SobreView()),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute<void>(
            builder: (context) => const LoginView(),
          );
        },
      ),
    );
  }
}
