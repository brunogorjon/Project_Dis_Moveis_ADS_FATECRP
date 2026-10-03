import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';

import 'controller/app_controller.dart';
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

void main() {
  final controller = AppController(
    authService: MockAuthService(),
    rateioService: MockRateioService(),
  );

  runApp(
    DevicePreview(
      builder: (context) => MainApp(controller: controller),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rateio de Viagem',
        theme: AppTheme.dark,
        initialRoute: 'login',
        routes: <String, WidgetBuilder>{
          'login': (context) => const LoginView(),
          'cadastro_usuario': (context) => const CadastroUsuarioView(),
          'recuperar_senha': (context) => const RecuperarSenhaView(),
          'meus_rateios': (context) => const MeusRateiosView(),
          'criar_rateio': (context) => const CriarRateioView(),
          'rateio_dashboard': (context) => const RateioDashboardView(),
          'participantes': (context) => const ParticipantesView(),
          'pagamentos': (context) => const PagamentosView(),
          'rateio_mensal': (context) => const RateioMensalView(),
          'configuracoes_rateio': (context) => const ConfiguracoesRateioView(),
          'perfil': (context) => const PerfilView(),
          'sobre': (context) => const SobreView(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute<void>(builder: (context) => const LoginView());
        },
      ),
    );
  }
}
