# FinTrack — Guia de Onboarding para Desenvolvedores

## Pré-requisitos

- **Flutter SDK** instalado ([instalar aqui](https://docs.flutter.dev/install/manual))
- **Git** instalado ([baixar aqui](https://git-scm.com/download/win))
- **VS Code** com extensão **Flutter** instalada
- Conta no **GitHub** com acesso ao repositório

---

## 1. Instalar Flutter SDK

### Windows

1. Baixe o SDK em: https://docs.flutter.dev/install/manual
2. Extraia em `C:\Users\{seu-usuario}\develop\flutter`
3. Adicione ao PATH:
   - **Windows + Pause** → Configurações avançadas → Variáveis de Ambiente
   - Em "Variáveis do usuário" → editar **Path** → novo → cole:
     ```
     C:\Users\{seu-usuario}\develop\flutter\bin
     ```
4. Reinicie o terminal
5. Teste:
   ```bash
   flutter --version
   flutter doctor
   ```

### Git Bash (extra)

Se usar Git Bash, adicione ao PATH manualmente:
```bash
echo 'export PATH="/c/Users/{seu-usuario}/develop/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 2. Clonar o Projeto

```bash
git clone https://github.com/ParceirosDev/FinTrack.git
cd FinTrack
git checkout develop
```

---

## 3. Instalar Dependências

```bash
flutter pub get
```

> Este comando baixa todas as dependências listadas no `pubspec.yaml`.
> Rode este comando **sempre** que fizer `git pull` ou trocar de branch.

---

## 4. Gerar Arquivos do Drift (Banco de Dados)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

> ⚠️ **IMPORTANTE:** Este comando gera os arquivos do banco de dados (`.g.dart`).
> Rode sempre que:
> - Clonar o projeto pela primeira vez
> - Fizer `git pull` e tiver mudanças no banco
> - Criar ou modificar entidades/tabelas

---

## 5. Rodar o Projeto

### Windows Desktop
```bash
flutter run -d windows
```

### Android (emulador ou dispositivo conectado)
```bash
flutter run -d android
```

### Ver dispositivos disponíveis
```bash
flutter devices
```

---

## 6. Estrutura do Projeto

```
lib/
│
├── core/                    ← Lógica central, fórmulas, constantes, tema
│   ├── theme/               ← Cores, tipografia, espaçamentos
│   ├── formulas/            ← Fórmulas financeiras reutilizáveis
│   ├── constants/           ← Constantes do app
│   └── utils/               ← Funções utilitárias
│
├── data/                    ← Camada de dados
│   ├── database/            ← Tabelas Drift + DAOs
│   ├── models/              ← Modelos de dados (DTOs)
│   ├── repositories/        ← Implementação dos repositórios
│   └── services/            ← Serviços externos (local_auth, etc.)
│
├── domain/                  ← Regras de negócio
│   ├── entities/            ← Entidades puras
│   ├── repositories/        ← Contratos/interfaces dos repositórios
│   └── usecases/            ← Casos de uso
│
├── presentation/            ← Interface do usuário
│   ├── screens/             ← Telas do app
│   ├── widgets/             ← Widgets reutilizáveis
│   ├── providers/           ← Riverpod providers (state management)
│   └── components/          ← Componentes visuais
│
└── main.dart                ← Ponto de entrada
```

---

## 7. Fluxo de Trabalho com Git

### Iniciar uma nova tarefa

```bash
# 1. Atualizar develop
git checkout develop
git pull origin develop

# 2. Criar branch da feature
git checkout -b feature/s{N}-nome-da-task
# Exemplo: git checkout -b feature/s2-crud-categories
```

### Durante o desenvolvimento

```bash
# Commitar frequentemente
git add .
git commit -m "feat: descrição curta no imperativo"
```

### Tipos de commit

| Tipo | Quando usar |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `refactor` | Refatoração sem mudar comportamento |
| `style` | Formatação, espaçamento |
| `docs` | Documentação |
| `test` | Testes |
| `chore` | Configuração, dependências |
| `perf` | Performance |
| `ui` | Mudanças visuais |

### Finalizar e enviar

```bash
# 1. Push da branch
git push -u origin feature/s{N}-nome-da-task

# 2. Abrir Pull Request no GitHub
#    De: feature/s{N}-nome-da-task
#    Para: develop

# 3. Outro dev revisa e aprova

# 4. Após merge, limpar:
git checkout develop
git pull origin develop
git branch -d feature/s{N}-nome-da-task
```

---

## 8. Dependências do Projeto

### Produção (`dependencies`)
| Pacote | Função |
|---|---|
| `flutter_riverpod` | Gerenciamento de estado |
| `drift` | ORM para SQLite |
| `sqlite3_flutter_libs` | SQLite nativo no dispositivo |
| `local_auth` | Biometria / Face ID / PIN |
| `intl` | Formatação de datas e números |
| `path_provider` | Caminhos de pastas do sistema |
| `path` | Manipulação de caminhos |

### Desenvolvimento (`dev_dependencies`)
| Pacote | Função |
|---|---|
| `flutter_lints` | Regras de lint |
| `drift_dev` | Geração de código do Drift |
| `build_runner` | Executor de code generation |

---

## 9. Comandos Úteis (Consulta Rápida)

| Comando | O que faz |
|---|---|
| `flutter pub get` | Instala dependências |
| `flutter pub run build_runner build --delete-conflicting-outputs` | Gera arquivos do Drift |
| `flutter run` | Roda o app (dispositivo padrão) |
| `flutter run -d windows` | Roda no Windows |
| `flutter run -d android` | Roda no Android |
| `flutter devices` | Lista dispositivos disponíveis |
| `flutter doctor` | Verifica ambiente |
| `flutter clean` | Limpa build cache (use quando tiver problemas) |
| `flutter pub upgrade` | Atualiza dependências |
| `dart analyze` | Analisa código em busca de erros |

---

## 10. Resolução de Problemas Comuns

### `flutter: command not found`
- Verifique se o PATH está configurado (Passo 1)
- No Git Bash: `source ~/.bashrc`
- No Windows: reinicie o terminal

### `Running pub upgrade...` travado
```bash
flutter clean
flutter pub get
```

### Erro no build_runner
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### App não abre / tela branca
```bash
flutter clean
flutter pub get
flutter run
```

### Erro de dependência conflitante
```bash
flutter pub upgrade --major-versions
```

---

## 11. Nomenclatura de Branches por Sprint

```
Sprint 1: feature/s1-project-setup, feature/s1-drift-sqlite, ...
Sprint 2: feature/s2-login-screen, feature/s2-local-auth, ...
Sprint 3: feature/s3-new-transaction, feature/s3-statement-screen, ...
Sprint 4: feature/s4-summary-cards, feature/s4-category-chart, ...
Sprint 5: feature/s5-analytics-metrics, feature/s5-insights-system, ...
Sprint 6: feature/s6-budget-definition, feature/s6-budget-progress, ...
Sprint 7: feature/s7-create-goal, feature/s7-goals-list, ...
Sprint 8: feature/s8-notification-center, feature/s8-ux-polish, ...
```

> Consulte o arquivo **GIT_FLOW.md** para a lista completa de branches.

---

## 12. Links Importantes

| Recurso | Link |
|---|---|
| Repositório | https://github.com/ParceirosDev/FinTrack |
| Jira (Kanban) | https://kayandevweb.atlassian.net/jira/software/projects/FINTRACK |
| Flutter Docs | https://docs.flutter.dev |
| Riverpod Docs | https://riverpod.dev |
| Drift Docs | https://drift.simonbinder.eu |

---

## Checklist de Primeiro Dia

- [ ] Flutter instalado (`flutter --version` funciona)
- [ ] Projeto clonado (`git clone`)
- [ ] Branch `develop` selecionada (`git checkout develop`)
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] Arquivos Drift gerados (`build_runner`)
- [ ] App rodando (`flutter run -d windows`)
- [ ] VS Code com extensão Flutter instalada
- [ ] Acesso ao Jira e GitHub confirmado
