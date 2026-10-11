# Rateio de Viagem — Flutter

Aplicativo Flutter/Dart adaptado do protótipo web `rateio_apartamento-main` e estruturado sobre o pré-projeto fornecido para a disciplina.

## Estado atual

Nesta etapa o projeto está focado em **front-end, navegação, ChangeNotifier e regras de negócio**.

A camada de autenticação já está isolada por uma interface (`AuthService`). Hoje ela usa `MockAuthService`; depois pode ser trocada por `FirebaseAuthService` sem reescrever as telas.

### Acesso de demonstração

- E-mail: `demo@rateio.app`
- Senha: `123456`

Também é possível cadastrar uma nova conta durante a execução. Como os serviços atuais são mockados em memória, os dados são reiniciados ao fechar completamente o aplicativo.

## Fluxo do aplicativo

```text
Login
├── Cadastro
└── Recuperar senha
     ↓
Meus Rateios
├── Criar Rateio
└── Abrir Rateio
      ↓
Dashboard
├── Participantes
├── Rateio Mensal
├── Pagamentos
├── Visão individual por participante
└── Configurações

Menu geral
├── Meus Rateios
├── Perfil
├── Sobre
└── Sair
```

## Funcionalidades do tema

1. Gerenciamento de múltiplos rateios por usuário (`meus_rateios_view.dart`).
2. Criação e configuração de rateio (`criar_rateio_view.dart` e `configuracoes_rateio_view.dart`).
3. Gerenciamento de participantes (`participantes_view.dart` e `participante_form_view.dart`).
4. Planejamento mensal (`rateio_mensal_view.dart`).
5. Registro e histórico de pagamentos (`pagamentos_view.dart` e `registrar_pagamento_view.dart`).
6. Acompanhamento individual (`participante_detalhes_view.dart`).

## Regras de negócio

- Valores monetários são tratados em **centavos (`int`)**, evitando erros de ponto flutuante.
- A cota total é dividida entre os participantes ativos e eventuais centavos restantes são distribuídos deterministicamente.
- Cada participante possui mês inicial e final de participação.
- Quando um participante entra posteriormente, os meses anteriores permanecem congelados e o planejamento é recalculado a partir do evento de entrada.
- No último mês disponível de uma pessoa, o algoritmo tenta absorver todo o saldo restante dela.
- Se não houver meses suficientes para concluir uma cota, o sistema gera um aviso.
- Pagamentos atualizam o realizado, porém **não redistribuem automaticamente as parcelas planejadas**.
- Pagamentos parciais são permitidos e ficam no histórico.
- Pagamentos acima da cota são tratados como crédito.
- Um participante com pagamentos registrados não pode ser excluído.
- A capacidade do rateio não pode ser menor que a quantidade atual de participantes.
- A soma dos compromissos mensais deve ser igual ao valor total do rateio.

A lógica principal está isolada em:

```text
lib/business/rateio_calculator.dart
```

## Gerenciamento de estado

O estado global do aplicativo utiliza `ChangeNotifier` em:

```text
lib/controller/app_controller.dart
```

As telas de autenticação e perfil também possuem controllers baseados em `ChangeNotifier` para estados de carregamento, validação e mensagens.

O `AppScope` é um `InheritedNotifier<AppController>` nativo do Flutter, portanto não é necessário adicionar Provider nesta etapa.

## Preparação para Firebase

A estrutura atual é:

```text
View
  ↓
Controller / ChangeNotifier
  ↓
Service
  ↓
Mock atual / Firebase futuramente
```

Para integrar o Firebase posteriormente, a ideia é criar uma implementação de `AuthService` usando `FirebaseAuth`, configurar o projeto com as credenciais e trocar a instância criada em `main.dart`.

Os dados dos rateios também estão abstraídos por `RateioService`, permitindo migrar o mock para Firestore/Realtime Database posteriormente sem mover a regra de cálculo para o backend.

## Estrutura principal

```text
lib/
├── business/
├── controller/
├── model/
├── service/
├── theme/
├── util/
├── view/
├── widget/
└── main.dart
```

## Antes da entrega final

- Substituir os nomes genéricos da equipe em `lib/controller/sobre_controller.dart`.
- Preencher instituição, disciplina e professor na tela Sobre, se desejado.
- Inserir a configuração Firebase fornecida pelo professor.
- Executar `flutter pub get` e `flutter analyze` no ambiente Flutter da equipe.
- Testar Android/Web conforme os dispositivos que serão demonstrados no vídeo.
