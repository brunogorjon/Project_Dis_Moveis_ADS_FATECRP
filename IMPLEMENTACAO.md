# Mapa da implementação

## Requisitos obrigatórios

| Requisito | Implementação |
|---|---|
| RF001 Login | `lib/view/login_view.dart` + `lib/controller/login_controller.dart` |
| RF002 Cadastro | `lib/view/cadastro_usuario_view.dart` + `lib/controller/cadastro_usuario_controller.dart` |
| RF003 Recuperação de senha | `lib/view/recuperar_senha_view.dart` + `lib/controller/recuperar_senha_controller.dart` |
| RF004 Sobre | `lib/view/sobre_view.dart` + `lib/controller/sobre_controller.dart` |
| RF005 Perfil | `lib/view/perfil_view.dart` + `lib/controller/perfil_controller.dart` |
| RF006 Funcionalidades específicas | Meus Rateios, criação/configuração, participantes, rateio mensal, pagamentos e visão individual |
| RF007 Listagem | `ListView` em Meus Rateios, Participantes, Pagamentos e Rateio Mensal |

## ChangeNotifier

O estado global está em `lib/controller/app_controller.dart`, que estende `ChangeNotifier`.
As telas obrigatórias também utilizam controllers com `ChangeNotifier` para estados de carregamento e validação.

## Arquitetura

```text
View
  -> Controller / ChangeNotifier
      -> Regras de negócio
          -> Service
              -> Mock atual / Firebase futuramente
```

## Regra central de rateio

`lib/business/rateio_calculator.dart`

Essa classe concentra o cálculo monetário e não depende de Flutter UI, Supabase ou Firebase.
