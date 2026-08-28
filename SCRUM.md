# FinTrack — Organização SCRUM (Solo)

## Visão do Produto

Aplicativo multiplataforma de gerenciamento financeiro pessoal, **offline-first**, com design unificado e responsivo (mobile/desktop), fórmulas padronizadas para cálculos, alertas inteligentes baseados em templates e módulo de alocação de orçamento.

---

## Equipe

| Papel | Responsável | Foco Principal |
|---|---|---|
| **Product Owner / Dev** | **Kayan** | Todo o projeto: UI/UX, banco de dados, arquitetura, features e polimento |

---

## Definição de Sprint

- **Duração:** 2 semanas (flexível no trabalho solo — o ritmo pode ser ajustado conforme a disponibilidade)
- **Cerimônias:** Planning (segunda), auto-check diário (revisar o Kanban), Review + Retro (sexta da última semana)
- **Ferramenta sugerida:** GitHub Projects (Kanban)

---

## Definição de Pronto (DoD)

- [ ] Código implementado e funcional
- [ ] Segue a arquitetura em camadas (Presentation → Domain → Data)
- [ ] UI responsiva (mobile e desktop com o mesmo componente)
- [ ] Fórmulas padronizadas e reutilizáveis (sem lógica hardcoded)
- [ ] Testes unitários das fórmulas de cálculo
- [ ] Sem erros de compilação
- [ ] Commit com mensagem descritiva

---

## Épicos

| ID | Épico | Descrição |
|---|---|---|
| E1 | **Fundação** | Setup do projeto, banco de dados, design system e responsividade |
| E2 | **Autenticação** | Login biométrico, Face ID e PIN |
| E3 | **Transações** | CRUD de receitas e despesas |
| E4 | **Categorias** | Categorias padrão e personalizadas |
| E5 | **Contas** | Contas financeiras do usuário |
| E6 | **Dashboard** | Tela principal com cards de resumo e gráficos |
| E7 | **Extrato** | Consulta de movimentações com filtros |
| E8 | **Análises** | Dashboard analítico com insights |
| E9 | **Orçamento** | Alocação de renda por categoria |
| E10 | **Metas Financeiras** | Definição e acompanhamento de metas |
| E11 | **Alertas Inteligentes** | Sistema de notificações baseadas em templates |
| E12 | **Polimento** | Refinamentos finais, performance e UX |

---

## Sprint 1 — Fundação e Estrutura

**Objetivo:** Projeto rodando, banco de dados funcional, design system responsivo estabelecido.

| ID | História | Critérios de Aceite | Pontos |
|---|---|---|---|
| S1-01 | Setup do projeto Flutter | Projeto criado, `flutter run` funciona no Android e Windows | 3 |
| S1-02 | Configuração do Drift + SQLite | Banco criado com tabelas: usuários, contas, categorias, transações, metas, orçamentos | 5 |
| S1-03 | Arquitetura em camadas | Estrutura de pastas `core/`, `data/`, `domain/`, `presentation/` criada | 3 |
| S1-04 | Design System base | Tema escuro, paleta de cores (roxo, verde, vermelho, azul), tipografia definida | 5 |
| S1-05 | Layout responsivo base | Breakpoints definidos, componentes adaptam entre mobile e desktop sem duplicação | 8 |
| S1-06 | Navegação principal | Rotas: Dashboard, Extrato, Análises, Orçamento, Metas, Configurações | 5 |

> **Ordem sugerida:** setup → banco/arquitetura → design system → layout responsivo → navegação.

**Total:** 29 pontos

---

## Sprint 2 — Autenticação e Categorias

**Objetivo:** Usuário consegue acessar o app e gerenciar categorias.

| ID | História | Critérios de Aceite | Pontos |
|---|---|---|---|
| S2-01 | Tela de login | Interface com opção de biometria/Face ID/PIN (conforme imagens) | 5 |
| S2-02 | Integração local_auth | Autenticação funcional usando recursos nativos do dispositivo | 5 |
| S2-03 | CRUD de categorias | Criar, editar, excluir categorias com ícone e cor | 5 |
| S2-04 | Categorias padrão | Categorias pré-cadastradas: Mercado, Transporte, Lazer, Saúde, Casa, Educação, Compras, Outros | 3 |
| S2-05 | CRUD de contas financeiras | Criar, editar, excluir contas (ex: Conta Corrente, Carteira, Poupança) | 5 |

> **Ordem sugerida:** integração local_auth → tela de login → CRUDs → categorias padrão.

**Total:** 23 pontos

---

## Sprint 3 — Transações

**Objetivo:** Usuário consegue registrar e visualizar receitas e despesas.

| ID | História | Critérios de Aceite | Pontos |
|---|---|---|---|
| S3-01 | Tela Nova Transação | Formulário com: tipo (receita/despesa), valor, categoria (grade de ícones), data, descrição, conta | 8 |
| S3-02 | Salvar transação | Dados persistidos no banco via Drift | 5 |
| S3-03 | Listar transações | Transações listadas por data (mais recente primeiro), agrupadas por dia (Hoje, Ontem, data) | 5 |
| S3-04 | Editar transação | Usuário pode editar qualquer campo de uma transação existente | 3 |
| S3-05 | Excluir transação | Usuário pode excluir com confirmação | 3 |
| S3-06 | Tela de Extrato | Extrato com: busca, filtros (categoria, conta, período, tipo), ordenação, visualização lista e tabela | 8 |

> **Ordem sugerida:** salvar transação → tela nova transação → listagem → edição/exclusão → extrato.

**Total:** 32 pontos

---

## Sprint 4 — Dashboard Principal

**Objetivo:** Dashboard funcional com resumo financeiro e gráficos.

| ID | História | Critérios de Aceite | Pontos |
|---|---|---|---|
| S4-01 | Cards de resumo | 4 cards: Saldo atual, Receitas, Despesas, Economia — com variação % vs mês anterior | 8 |
| S4-02 | Gráfico de pizza — Gastos por categoria | Donut chart com legenda e valores absolutos + percentuais | 8 |
| S4-03 | Gráfico de linha — Evolução de despesas | Linha dos últimos 6 meses com ponto destacado no mês atual | 5 |
| S4-04 | Últimas transações | Lista das 5 transações mais recentes no dashboard | 3 |
| S4-05 | Fórmulas de cálculo padronizadas | Todas as métricas usam fórmulas determinísticas e reutilizáveis em `/core` | 8 |
| S4-06 | Dashboard responsivo | Grid layout no desktop, cards empilhados no mobile — mesmos componentes | 5 |

> **Ordem sugerida:** fórmulas em `/core` primeiro — cards e gráficos dependem delas.

**Total:** 37 pontos

---

## Sprint 5 — Dashboard Analítico

**Objetivo:** Tela de análises completa com insights automáticos.

| ID | História | Critérios de Aceite | Pontos |
|---|---|---|---|
| S5-01 | Cards de métricas analíticos | Receitas, Despesas, Saldo, Economia com % variação vs mês anterior | 5 |
| S5-02 | Ranking de maiores gastos | Top 5 despesas do mês com valor e % do total | 5 |
| S5-03 | Comparativo mensal | Gráfico de barras comparando últimos 6 meses | 5 |
| S5-04 | Resumo do mês | Total de transações, maior/menor despesa, média diária de gastos | 5 |
| S5-05 | Sistema de Insights | 3 cards automáticos baseados nos dados (ex: "Você gastou X% a mais em Y") | 8 |
| S5-06 | Templates de alertas | Textos padronizados: "{categoria}: {variação}% vs mês anterior" — reutilizáveis | 5 |
| S5-07 | Filtros e seletor de mês | Seletor de mês + filtros funcionais na tela de análises | 5 |

> **Ordem sugerida:** templates de alertas → filtros → cards/ranking → comparativo/resumo → insights.

**Total:** 38 pontos

---

## Sprint 6 — Orçamento (Alocação de Renda)

**Objetivo:** Usuário consegue dividir sua renda em categorias e acompanhar.

| ID | História | Critérios de Aceite | Pontos |
|---|---|---|---|
| S6-01 | Definir orçamento mensal | Usuário informa renda total e distribui entre categorias | 8 |
| S6-02 | Visualização do orçamento | Barras de progresso: valor gasto vs. valor definido por categoria | 8 |
| S6-03 | Alertas de orçamento | Aviso quando gasto atinge 80% e 100% do limite definido | 5 |
| S6-04 | Saldo restante por categoria | Mostra quanto ainda pode gastar em cada categoria no mês | 5 |
| S6-05 | Resumo do orçamento | Card geral: total alocado, total gasto, total disponível | 5 |
| S6-06 | Ajuste de orçamento | Usuário pode editar os valores alocados a qualquer momento | 3 |

> **Ordem sugerida:** definição → saldo restante → resumo → visualização → ajuste → alertas.

**Total:** 34 pontos

---

## Sprint 7 — Metas Financeiras

**Objetivo:** Usuário cria e acompanha metas de economia.

| ID | História | Critérios de Aceite | Pontos |
|---|---|---|---|
| S7-01 | Criar meta | Nome, valor alvo, prazo, ícone/cor | 5 |
| S7-02 | Adicionar aporte | Usuário adiciona valores à meta ao longo do tempo | 5 |
| S7-03 | Lista de metas | Cards com: nome, barra de progresso (valor atual / alvo), % concluído, prazo | 5 |
| S7-04 | Detalhes da meta | Histórico de aportes, previsão de conclusão baseada na média | 5 |
| S7-05 | Meta concluída | Quando atinge 100%, card muda visual e mostra mensagem de parabéns | 3 |
| S7-06 | Excluir meta | Com confirmação | 3 |

> **Ordem sugerida:** criar meta → adicionar aporte → lista → detalhes → concluída → exclusão.

**Total:** 26 pontos

---

## Sprint 8 — Alertas Inteligentes e Polimento

**Objetivo:** Sistema de notificações completo e refinamentos finais.

| ID | História | Critérios de Aceite | Pontos |
|---|---|---|---|
| S8-01 | Central de notificações | Tela/ícone com badge mostrando alertas pendentes | 5 |
| S8-02 | Alertas de variação | "Você gastou {X}% a mais em {categoria} em relação ao mês anterior" | 5 |
| S8-03 | Alertas de orçamento | "Você atingiu {X}% do limite de {categoria}" | 3 |
| S8-04 | Alertas de meta | "Faltam R$ {X} para atingir a meta {nome}" | 3 |
| S8-05 | Alertas de economia | "Sua economia do mês é de {X}% — {mensagem motivacional baseada em limiar}" | 3 |
| S8-06 | Responsividade final | Testar e corrigir todas as telas em mobile e desktop | 8 |
| S8-07 | Performance | Otimizar queries do Drift, listas com paginação | 5 |
| S8-08 | Ajustes de UX | Animações suaves, feedback visual em ações, empty states | 5 |

> **Ordem sugerida:** central de notificações → alertas → performance → responsividade → UX.

**Total:** 37 pontos

---

## Backlog do Produto (V2 — Futuro)

| Item | Descrição | Prioridade |
|---|---|---|
| SQLCipher | Criptografia completa do banco | Alta |
| Exportação CSV | Exportar transações para arquivo CSV | Média |
| Importação CSV | Importar transações de planilhas | Média |
| Backup manual | Exportar/importar backup completo | Alta |
| Relatórios PDF | Gerar relatórios mensais em PDF | Baixa |
| Temas | Tema claro + personalização de cores | Baixa |
| Widgets | Widgets para tela inicial do celular | Baixa |

---

## Resumo Visual

```
Sprint 1 ── Fundação e Estrutura           (29 pts)
Sprint 2 ── Autenticação e Categorias      (23 pts)
Sprint 3 ── Transações                     (32 pts)
Sprint 4 ── Dashboard Principal            (37 pts)
Sprint 5 ── Dashboard Analítico            (38 pts)
Sprint 6 ── Orçamento (Alocação)           (34 pts)
Sprint 7 ── Metas Financeiras              (26 pts)
Sprint 8 ── Alertas e Polimento            (37 pts)
                                          ─────────
                                  Total: 256 pontos
```

> No ritmo solo, a duração de cada sprint pode variar — o importante é entregar as histórias com qualidade (DoD) em vez de cumprir prazo fixo.

---

## Ritmo de Trabalho Solo

- **Uma história por vez**, priorizando dependências (banco antes das telas que o consomem).
- **Branch de feature por história**, com PR para `develop` usando o template do [GIT_FLOW.md](GIT_FLOW.md).
- **Auto-review:** antes do merge, passar pelo checklist do PR e pela DoD como se fosse outra pessoa revisando.
- **Retro ao final de cada sprint:** revisar o que foi entregue, o que travou e ajustar a próxima sprint.

---

## Colunas do Kanban (GitHub Projects)

```
📋 Backlog  →  📌 To Do  →  🔨 In Progress  →  👀 Review  →  ✅ Done
```
