# FinTrack — Guia de Git Flow e Organização de Branches

## Modelo de Branches

```
main ───────────────────────────────────────────── (produção estável)
 │
 ├── develop ───────────────────────────────────── (integração contínua)
 │    │
 │    ├── feature/s1-project-setup          [Kayan]
 │    ├── feature/s1-drift-sqlite            [Ryan]
 │    ├── feature/s2-login-screen            [Kayan]
 │    ├── feature/s2-local-auth              [Ryan]
 │    ├── feature/s3-new-transaction         [Kayan]
 │    ├── feature/s4-summary-cards           [Kayan]
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
feature/s1-project-setup          [Kayan]  → setup do Flutter, configs iniciais
feature/s1-drift-sqlite           [Ryan]   → banco de dados + tabelas
feature/s1-architecture           [Ryan]   → estrutura de pastas em camadas
feature/s1-design-system          [Kayan]  → tema, cores, tipografia
feature/s1-responsive-layout      [Kayan]  → breakpoints + componentes adaptativos
feature/s1-navigation             [Ryan]   → rotas principais
```

**Sprint 2 — Autenticação e Categorias**
```
feature/s2-login-screen           [Kayan]  → UI da tela de login
feature/s2-local-auth             [Ryan]   → integração com biometria/Face ID/PIN
feature/s2-crud-categories        [Ryan]   → criar/editar/excluir categorias
feature/s2-default-categories     [Ryan]   → categorias pré-cadastradas
feature/s2-crud-accounts          [Ryan]   → CRUD de contas financeiras
```

**Sprint 3 — Transações**
```
feature/s3-new-transaction        [Kayan]  → tela de nova transação (formulário)
feature/s3-save-transaction       [Ryan]   → persistência no banco via Drift
feature/s3-list-transactions      [Ryan]   → listagem agrupada por dia
feature/s3-edit-transaction       [Ryan]   → edição de campos
feature/s3-delete-transaction     [Ryan]   → exclusão com confirmação
feature/s3-statement-screen       [Kayan]  → tela de extrato com filtros
```

**Sprint 4 — Dashboard**
```
feature/s4-summary-cards          [Kayan]  → 4 cards com variação %
feature/s4-category-chart         [Kayan]  → gráfico de pizza/donut
feature/s4-expense-evolution      [Ryan]   → gráfico de linha (6 meses)
feature/s4-recent-transactions    [Ryan]   → lista das 5 últimas
feature/s4-calculation-formulas   [Kayan]  → fórmulas reutilizáveis em /core
feature/s4-responsive-dashboard   [Kayan]  → grid desktop + cards mobile
```

**Sprint 5 — Análises**
```
feature/s5-analytics-metrics      [Kayan]  → cards de métricas
feature/s5-top-expenses           [Kayan]  → ranking top 5
feature/s5-monthly-comparison     [Ryan]   → gráfico de barras comparativo
feature/s5-month-summary          [Ryan]   → resumo do mês (totais + média)
feature/s5-insights-system        [Kayan]  → cards automáticos de insights
feature/s5-alert-templates        [Kayan]  → textos padronizados reutilizáveis
feature/s5-filters-selector       [Ryan]   → seletor de mês + filtros
```

**Sprint 6 — Orçamento**
```
feature/s6-budget-definition      [Kayan]  → tela de definir orçamento
feature/s6-budget-progress        [Kayan]  → barras de progresso por categoria
feature/s6-budget-alerts          [Kayan]  → avisos de 80% e 100%
feature/s6-budget-remaining       [Ryan]   → saldo restante por categoria
feature/s6-budget-summary         [Ryan]   → card geral (alocado/gasto/disponível)
feature/s6-budget-edit            [Ryan]   → editar valores alocados
```

**Sprint 7 — Metas**
```
feature/s7-create-goal            [Ryan]   → criar meta (nome, alvo, prazo)
feature/s7-add-contribution       [Ryan]   → adicionar aporte
feature/s7-goals-list             [Kayan]  → lista com barras de progresso
feature/s7-goal-details           [Kayan]  → detalhes + histórico de aportes
feature/s7-goal-complete          [Kayan]  → visual de meta concluída
feature/s7-delete-goal            [Ryan]   → exclusão com confirmação
```

**Sprint 8 — Alertas e Polimento**
```
feature/s8-notification-center    [Kayan]  → tela/ícone de notificações
feature/s8-variation-alerts       [Kayan]  → alertas de variação mensal
feature/s8-budget-alerts          [Kayan]  → alertas de limite de orçamento
feature/s8-goal-alerts            [Ryan]   → alertas de meta
feature/s8-savings-alerts         [Kayan]  → alertas de economia
bugfix/s8-responsive-fixes        [Kayan]  → correções de responsividade
feature/s8-performance            [Ryan]   → otimização de queries e paginação
feature/s8-ux-polish              [Ambos]  → animações, empty states, feedback
```

---

## Fluxo de Trabalho (Passo a Passo)

### 1. Iniciar o projeto
```bash
# Criar o repositório
git init
git checkout -b develop
git push -u origin main develop
```

### 2. Começar uma nova feature
```bash
# Sempre partir da develop atualizada
git checkout develop
git pull origin develop

# Criar branch da feature
git checkout -b feature/s4-summary-cards
```

### 3. Desenvolver e commitar
```bash
# Commits frequentes e descritivos
git add .
git commit -m "feat: criar componente de cards de resumo financeiro"

git add .
git commit -m "feat: implementar variação percentual vs mês anterior"
```

### 4. Manter atualizado com develop
```bash
# Fazer rebase periodicamente para evitar conflitos grandes
git fetch origin
git rebase origin/develop

# Se houver conflito, resolver e continuar
git add .
git rebase --continue
```

### 5. Subir a branch e criar Pull Request
```bash
git push -u origin feature/s4-summary-cards
```
Depois abrir o Pull Request no GitHub:
- **De:** `feature/s4-summary-cards`
- **Para:** `develop`
- **Título:** `[S4] Dashboard — Cards de Resumo`
- **Descrição:** O que foi feito, como testar, screenshots

### 6. Code Review
- **Kayan** faz PR → **Ryan** revisa e aprova
- **Ryan** faz PR → **Kayan** revisa e aprova
- Aprova ou pede alterações
- Após aprovação → merge via **Squash and Merge**

### 7. Limpar após merge
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

### `main`
- ✅ Require pull request before merging
- ✅ Require 2 approvals (Kayan + Ryan aprovam)
- ✅ Require status checks (build passing)
- ❌ No direct push

### `develop`
- ✅ Require pull request before merging
- ✅ Require 1 approval (o outro dev aprova)
- ❌ No direct push

### Como configurar
```
GitHub → Settings → Branches → Add rule
```

---

## Tags e Releases

### Criar tag ao final de cada versão
```bash
# Ao final do Sprint 4 (MVP funcional)
# Responsável: Ryan (infraestrutura)
git checkout main
git merge develop
git tag -a v0.1.0 -m "MVP — Dashboard + Transações + Extrato"
git push origin v0.1.0

# Ao final do Sprint 8 (V1 completa)
# Responsável: Kayan (product owner)
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
5. Code Review     →  o outro dev aprova (Kayan ↔ Ryan)
6. Merge           →  squash and merge
7. Limpar          →  deletar branch local e remota
8. Release         →  develop → release/vX → main + tag
```

---

## Resumo de Branches por Responsável

| Sprint | 🟣 Kayan (UI/UX + Análises) | 🔵 Ryan (Dados + CRUDs) |
|---|---|---|
| **S1** | `feature/s1-project-setup` | `feature/s1-drift-sqlite` |
| | `feature/s1-design-system` | `feature/s1-architecture` |
| | `feature/s1-responsive-layout` | `feature/s1-navigation` |
| **S2** | `feature/s2-login-screen` | `feature/s2-local-auth` |
| | | `feature/s2-crud-categories` |
| | | `feature/s2-default-categories` |
| | | `feature/s2-crud-accounts` |
| **S3** | `feature/s3-new-transaction` | `feature/s3-save-transaction` |
| | `feature/s3-statement-screen` | `feature/s3-list-transactions` |
| | | `feature/s3-edit-transaction` |
| | | `feature/s3-delete-transaction` |
| **S4** | `feature/s4-summary-cards` | `feature/s4-expense-evolution` |
| | `feature/s4-category-chart` | `feature/s4-recent-transactions` |
| | `feature/s4-calculation-formulas` | |
| | `feature/s4-responsive-dashboard` | |
| **S5** | `feature/s5-analytics-metrics` | `feature/s5-monthly-comparison` |
| | `feature/s5-top-expenses` | `feature/s5-month-summary` |
| | `feature/s5-insights-system` | `feature/s5-filters-selector` |
| | `feature/s5-alert-templates` | |
| **S6** | `feature/s6-budget-definition` | `feature/s6-budget-remaining` |
| | `feature/s6-budget-progress` | `feature/s6-budget-summary` |
| | `feature/s6-budget-alerts` | `feature/s6-budget-edit` |
| **S7** | `feature/s7-goals-list` | `feature/s7-create-goal` |
| | `feature/s7-goal-details` | `feature/s7-add-contribution` |
| | `feature/s7-goal-complete` | `feature/s7-delete-goal` |
| **S8** | `feature/s8-notification-center` | `feature/s8-goal-alerts` |
| | `feature/s8-variation-alerts` | `feature/s8-performance` |
| | `feature/s8-budget-alerts` | |
| | `feature/s8-savings-alerts` | |
| | `bugfix/s8-responsive-fixes` | |
| | `feature/s8-ux-polish` *(ambos)* | `feature/s8-ux-polish` *(ambos)* |
