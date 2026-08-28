# FinTrack — Guia de Git Flow e Organização de Branches (Solo)

## Modelo de Branches

```
main ───────────────────────────────────────────── (produção estável)
 │
 ├── develop ───────────────────────────────────── (integração contínua)
 │    │
 │    ├── feature/s1-project-setup
 │    ├── feature/s1-drift-sqlite
 │    ├── feature/s2-login-screen
 │    ├── feature/s2-local-auth
 │    ├── feature/s3-new-transaction
 │    ├── feature/s4-summary-cards
 │    ├── ...
 │    │
 │    └── (merge de volta para develop)
 │
 ├── release/v1.0 ──────────────────────────────── (preparação para release)
 │
 ├── hotfix/bug-login ──────────────────────────── (correções urgentes)
 │
 └── tags/v1.0.0 ──────────────────────────────── (versão publicada)
```

---

## Tipos de Branch

| Tipo | Prefixo | Origem | Merge para | Quando usar |
|---|---|---|---|---|
| **Main** | `main` | — | — | Versão estável em produção |
| **Develop** | `develop` | `main` | `main` | Branch de integração |
| **Feature** | `feature/` | `develop` | `develop` | Nova funcionalidade |
| **Bugfix** | `bugfix/` | `develop` | `develop` | Bug encontrado durante dev |
| **Hotfix** | `hotfix/` | `main` | `main` + `develop` | Bug crítico em produção |
| **Release** | `release/` | `develop` | `main` + `develop` | Preparar versão para deploy |

---

## Nomenclatura de Branches

### Padrão
```
{tipo}/{sprint}-{descricao-curta}
```

### Exemplos por Sprint

**Sprint 1 — Fundação**
```
feature/s1-project-setup          → setup do Flutter, configs iniciais
feature/s1-drift-sqlite           → banco de dados + tabelas
feature/s1-architecture           → estrutura de pastas em camadas
feature/s1-design-system          → tema, cores, tipografia
feature/s1-responsive-layout      → breakpoints + componentes adaptativos
feature/s1-navigation             → rotas principais
```

**Sprint 2 — Autenticação e Categorias**
```
feature/s2-login-screen           → UI da tela de login
feature/s2-local-auth             → integração com biometria/Face ID/PIN
feature/s2-crud-categories        → criar/editar/excluir categorias
feature/s2-default-categories     → categorias pré-cadastradas
feature/s2-crud-accounts          → CRUD de contas financeiras
```

**Sprint 3 — Transações**
```
feature/s3-new-transaction        → tela de nova transação (formulário)
feature/s3-save-transaction       → persistência no banco via Drift
feature/s3-list-transactions      → listagem agrupada por dia
feature/s3-edit-transaction       → edição de campos
feature/s3-delete-transaction     → exclusão com confirmação
feature/s3-statement-screen       → tela de extrato com filtros
```

**Sprint 4 — Dashboard**
```
feature/s4-summary-cards          → 4 cards com variação %
feature/s4-category-chart         → gráfico de pizza/donut
feature/s4-expense-evolution      → gráfico de linha (6 meses)
feature/s4-recent-transactions    → lista das 5 últimas
feature/s4-calculation-formulas   → fórmulas reutilizáveis em /core
feature/s4-responsive-dashboard   → grid desktop + cards mobile
```

**Sprint 5 — Análises**
```
feature/s5-analytics-metrics      → cards de métricas
feature/s5-top-expenses           → ranking top 5
feature/s5-monthly-comparison     → gráfico de barras comparativo
feature/s5-month-summary          → resumo do mês (totais + média)
feature/s5-insights-system        → cards automáticos de insights
feature/s5-alert-templates        → textos padronizados reutilizáveis
feature/s5-filters-selector       → seletor de mês + filtros
```

**Sprint 6 — Orçamento**
```
feature/s6-budget-definition      → tela de definir orçamento
feature/s6-budget-progress        → barras de progresso por categoria
feature/s6-budget-alerts          → avisos de 80% e 100%
feature/s6-budget-remaining       → saldo restante por categoria
feature/s6-budget-summary         → card geral (alocado/gasto/disponível)
feature/s6-budget-edit            → editar valores alocados
```

**Sprint 7 — Metas**
```
feature/s7-create-goal            → criar meta (nome, alvo, prazo)
feature/s7-add-contribution       → adicionar aporte
feature/s7-goals-list             → lista com barras de progresso
feature/s7-goal-details           → detalhes + histórico de aportes
feature/s7-goal-complete          → visual de meta concluída
feature/s7-delete-goal            → exclusão com confirmação
```

**Sprint 8 — Alertas e Polimento**
```
feature/s8-notification-center    → tela/ícone de notificações
feature/s8-variation-alerts       → alertas de variação mensal
feature/s8-budget-alerts          → alertas de limite de orçamento
feature/s8-goal-alerts            → alertas de meta
feature/s8-savings-alerts         → alertas de economia
bugfix/s8-responsive-fixes        → correções de responsividade
feature/s8-performance            → otimização de queries e paginação
feature/s8-ux-polish              → animações, empty states, feedback
```

---

## Fluxo de Trabalho (Passo a Passo)

### 1. Começar uma nova feature
```bash
# Sempre partir da develop atualizada
git checkout develop
git pull origin develop

# Criar branch da feature
git checkout -b feature/s4-summary-cards
```

### 2. Desenvolver e commitar
```bash
# Commits frequentes e descritivos
git add .
git commit -m "feat: criar componente de cards de resumo financeiro"

git add .
git commit -m "feat: implementar variação percentual vs mês anterior"
```

### 3. Manter atualizado com develop
```bash
# Fazer rebase periodicamente para evitar conflitos grandes
git fetch origin
git rebase origin/develop

# Se houver conflito, resolver e continuar
git add .
git rebase --continue
```

### 4. Subir a branch e criar Pull Request
```bash
git push -u origin feature/s4-summary-cards
```
Depois abrir o Pull Request no GitHub:
- **De:** `feature/s4-summary-cards`
- **Para:** `develop`
- **Título:** `[S4] Dashboard — Cards de Resumo`
- **Descrição:** O que foi feito, como testar, screenshots

> Mesmo trabalhando solo, manter o hábito de abrir PR ajuda a organizar o que foi entregue em cada história e deixa o histórico do repositório legível.

### 5. Auto Review
- Antes de mergear, revisar o próprio PR passando pelo **checklist do template** e pela **DoD** da sprint
- Testar no mobile e no desktop (quando aplicável)
- Após o auto review → merge via **Squash and Merge**

### 6. Limpar após merge
```bash
# Voltar para develop e atualizar
git checkout develop
git pull origin develop

# Deletar branch local
git branch -d feature/s4-summary-cards

# Deletar branch remota (automático se configurar no GitHub)
git push origin --delete feature/s4-summary-cards
```

---

## Convenção de Commits

### Formato
```
{tipo}: {descrição curta no imperativo}
```

### Tipos

| Tipo | Quando usar | Exemplo |
|---|---|---|
| `feat` | Nova funcionalidade | `feat: criar tela de nova transação` |
| `fix` | Correção de bug | `fix: corrigir cálculo de saldo negativo` |
| `refactor` | Refatoração sem mudar comportamento | `refactor: extrair fórmula de variação %` |
| `style` | Formatação, espaçamento, etc. | `style: ajustar indentação do dashboard` |
| `docs` | Documentação | `docs: atualizar README com setup` |
| `test` | Testes | `test: adicionar testes de cálculo de orçamento` |
| `chore` | Configuração, dependências | `chore: atualizar drift para v2.0` |
| `perf` | Melhoria de performance | `perf: otimizar query de extrato` |
| `ui` | Mudanças visuais | `ui: ajustar responsividade do gráfico de pizza` |

### Regras
- Descrição no **imperativo** ("criar" não "criei")
- Máximo **72 caracteres** na primeira linha
- Sem ponto final no título
- Commit em **português** (idioma do projeto)

---

## Pull Request — Template

```markdown
## Sprint
Sprint X — Nome do Sprint

## O que foi feito
- Descrição das mudanças

## Como testar
1. Passo 1
2. Passo 2

## Screenshots
(se aplicável, adicionar imagens)

## Checklist
- [ ] Funciona no mobile
- [ ] Funciona no desktop
- [ ] Sem erros de compilação
- [ ] Fórmulas padronizadas (se aplicável)
- [ ] Testes unitários (se aplicável)
- [ ] Responsivo (se aplicável)
```

---

## Proteção de Branches (Configurar no GitHub)

No trabalho solo, as proteções servem como **disciplina pessoal** — como admin você pode passar por cima delas quando precisar.

### `main`
- ✅ Require pull request before merging
- ✅ Require status checks (build passing, se configurar CI)
- ❌ No direct push

### `develop`
- ✅ Require pull request before merging (força passar pelo checklist do PR)
- Merge direto permitido apenas para correções triviais (docs, README)

### Como configurar
```
GitHub → Settings → Branches → Add rule
```

---

## Tags e Releases

### Criar tag ao final de cada versão
```bash
# Ao final do Sprint 4 (MVP funcional)
git checkout main
git merge develop
git tag -a v0.1.0 -m "MVP — Dashboard + Transações + Extrato"
git push origin v0.1.0

# Ao final do Sprint 8 (V1 completa)
git tag -a v1.0.0 -m "Versão 1.0 — FinTrack completo"
git push origin v1.0.0
```

### Versionamento Semântico
```
v{major}.{minor}.{patch}

v1.0.0 → Versão 1 completa
v1.1.0 → Nova feature (ex: exportação CSV)
v1.1.1 → Bugfix
v2.0.0 → Mudança grande (ex: SQLCipher + redesign)
```

---

## Fluxo Completo do Projeto

```
INÍCIO
  │
  ▼
main ──────────●─────────────────────────────────────────────●──
               │                                             │
develop ───────●─────────────────────────────────────────●──●──
               │         │         │         │           │
Sprint 1  ─────●──●──●──●         │         │           │
  feature/s1-*     │    │          │         │           │
                   ▼    ▼          │         │           │
              (PR + merge)         │         │           │
                                   │         │           │
Sprint 2  ─────────────────────────●──●──●──●           │
  feature/s2-*                       │    │              │
                                     ▼    ▼              │
                                (PR + merge)             │
                                                         │
Sprint 3-7 ──────────────────────────────────────────●──●
  feature/s[3-7]-*                                     │
                                                       ▼
                                                  (PR + merge)
                                                         │
Sprint 8  ───────────────────────────────────────────────●──●
  feature/s8-* + bugfix/s8-*                              │
                                                          ▼
                                                     (PR + merge)
                                                          │
Release   ────────────────────────────────────────────────●──●
  release/v1.0 ──→ testes ──→ merge para main + develop
                                  │
                                  ▼
                             tag v1.0.0
```

---

## Configuração Inicial do Repositório

### `.gitignore` para Flutter
```gitignore
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.g.dart

# IDE
.idea/
.vscode/
*.iml

# Platform
android/.gradle/
android/app/build/
ios/Pods/
windows/flutter/ephemeral/

# OS
.DS_Store
Thumbs.db

# Drift
*.g.dart
*.drift.dart
```

### Configurar para deletar branch remota após merge
```bash
# No GitHub: Settings → General → Pull Requests
# ✅ Automatically delete head branches
```

---

## Resumo Rápido

```
1. Feature nova    →  branch a partir de develop
2. Commitar        →  tipo: descrição curta (português)
3. Atualizar       →  rebase com develop frequentemente
4. Pull Request    →  de feature → develop, com template
5. Auto Review     →  passar pelo checklist do PR e pela DoD
6. Merge           →  squash and merge
7. Limpar          →  deletar branch local e remota
8. Release         →  develop → release/vX → main + tag
```
