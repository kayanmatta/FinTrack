# FinTrack — Organização SCRUM

## Visão do Produto

Aplicativo multiplataforma de gerenciamento financeiro pessoal, **offline-first**, com design unificado e responsivo (mobile/desktop), fórmulas padronizadas para cálculos, alertas inteligentes baseados em templates e módulo de alocação de orçamento.

---

## Equipe

| Papel | Responsável | Foco Principal |
|---|---|---|
| **Product Owner / Dev** | **Kayan** | UI/UX, Dashboard, Análises, Orçamento, Alertas |
| **Dev** | **Ryan** | Banco de Dados, Arquitetura, CRUDs, Extrato, Metas |

---

## Definição de Sprint

- **Duração:** 2 semanas
- **Cerimônias:** Planning (segunda), Daily (assíncrono via chat), Review + Retro (sexta da última semana)
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

| ID | História | Responsável | Critérios de Aceite | Pontos |
|---|---|---|---|---|
| S1-01 | Setup do projeto Flutter | 🟣 Kayan | Projeto criado, `flutter run` funciona no Android e Windows | 3 |
| S1-02 | Configuração do Drift + SQLite | 🔵 Ryan | Banco criado com tabelas: usuários, contas, categorias, transações, metas, orçamentos | 5 |
| S1-03 | Arquitetura em camadas | 🔵 Ryan | Estrutura de pastas `core/`, `data/`, `domain/`, `presentation/` criada | 3 |
| S1-04 | Design System base | 🟣 Kayan | Tema escuro, paleta de cores (roxo, verde, vermelho, azul), tipografia definida | 5 |
| S1-05 | Layout responsivo base | 🟣 Kayan | Breakpoints definidos, componentes adaptam entre mobile e desktop sem duplicação | 8 |
| S1-06 | Navegação principal | 🔵 Ryan | Rotas: Dashboard, Extrato, Análises, Orçamento, Metas, Configurações | 5 |

> **Paralelismo:** Kayan trabalha no design system e layout enquanto Ryan configura o banco e arquitetura. Ambos se encontram na navegação principal.

**Total:** 29 pontos (Kayan: 16 | Ryan: 13)

---

## Sprint 2 — Autenticação e Categorias

**Objetivo:** Usuário consegue acessar o app e gerenciar categorias.

| ID | História | Responsável | Critérios de Aceite | Pontos |
|---|---|---|---|---|
| S2-01 | Tela de login | 🟣 Kayan | Interface com opção de biometria/Face ID/PIN (conforme imagens) | 5 |
| S2-02 | Integração local_auth | 🔵 Ryan | Autenticação funcional usando recursos nativos do dispositivo | 5 |
| S2-03 | CRUD de categorias | 🔵 Ryan | Criar, editar, excluir categorias com ícone e cor | 5 |
| S2-04 | Categorias padrão | 🔵 Ryan | Categorias pré-cadastradas: Mercado, Transporte, Lazer, Saúde, Casa, Educação, Compras, Outros | 3 |
| S2-05 | CRUD de contas financeiras | 🔵 Ryan | Criar, editar, excluir contas (ex: Conta Corrente, Carteira, Poupança) | 5 |

> **Paralelismo:** Kayan cuida da tela de login (UI) enquanto Ryan implementa toda a camada de autenticação e CRUDs.

**Total:** 23 pontos (Kayan: 5 | Ryan: 18)

---

## Sprint 3 — Transações

**Objetivo:** Usuário consegue registrar e visualizar receitas e despesas.

| ID | História | Responsável | Critérios de Aceite | Pontos |
|---|---|---|---|---|
| S3-01 | Tela Nova Transação | 🟣 Kayan | Formulário com: tipo (receita/despesa), valor, categoria (grade de ícones), data, descrição, conta | 8 |
| S3-02 | Salvar transação | 🔵 Ryan | Dados persistidos no banco via Drift | 5 |
| S3-03 | Listar transações | 🔵 Ryan | Transações listadas por data (mais recente primeiro), agrupadas por dia (Hoje, Ontem, data) | 5 |
| S3-04 | Editar transação | 🔵 Ryan | Usuário pode editar qualquer campo de uma transação existente | 3 |
| S3-05 | Excluir transação | 🔵 Ryan | Usuário pode excluir com confirmação | 3 |
| S3-06 | Tela de Extrato | 🟣 Kayan | Extrato com: busca, filtros (categoria, conta, período, tipo), ordenação, visualização lista e tabela | 8 |

> **Paralelismo:** Kayan faz as telas (Nova Transação + Extrato) e Ryan implementa a lógica de persistência e listagem.

**Total:** 32 pontos (Kayan: 16 | Ryan: 16)

---

## Sprint 4 — Dashboard Principal

**Objetivo:** Dashboard funcional com resumo financeiro e gráficos.

| ID | História | Responsável | Critérios de Aceite | Pontos |
|---|---|---|---|---|
| S4-01 | Cards de resumo | 🟣 Kayan | 4 cards: Saldo atual, Receitas, Despesas, Economia — com variação % vs mês anterior | 8 |
| S4-02 | Gráfico de pizza — Gastos por categoria | 🟣 Kayan | Donut chart com legenda e valores absolutos + percentuais | 8 |
| S4-03 | Gráfico de linha — Evolução de despesas | 🔵 Ryan | Linha dos últimos 6 meses com ponto destacado no mês atual | 5 |
| S4-04 | Últimas transações | 🔵 Ryan | Lista das 5 transações mais recentes no dashboard | 3 |
| S4-05 | Fórmulas de cálculo padronizadas | 🟣 Kayan | Todas as métricas usam fórmulas determinísticas e reutilizáveis em `/core` | 8 |
| S4-06 | Dashboard responsivo | 🟣 Kayan | Grid layout no desktop, cards empilhados no mobile — mesmos componentes | 5 |

> **Paralelismo:** Kayan foca nos gráficos e fórmulas core, Ryan complementa com o gráfico de evolução e lista de transações.

**Total:** 37 pontos (Kayan: 29 | Ryan: 8)

---

## Sprint 5 — Dashboard Analítico

**Objetivo:** Tela de análises completa com insights automáticos.

| ID | História | Responsável | Critérios de Aceite | Pontos |
|---|---|---|---|---|
| S5-01 | Cards de métricas analíticos | 🟣 Kayan | Receitas, Despesas, Saldo, Economia com % variação vs mês anterior | 5 |
| S5-02 | Ranking de maiores gastos | 🟣 Kayan | Top 5 despesas do mês com valor e % do total | 5 |
| S5-03 | Comparativo mensal | 🔵 Ryan | Gráfico de barras comparando últimos 6 meses | 5 |
| S5-04 | Resumo do mês | 🔵 Ryan | Total de transações, maior/menor despesa, média diária de gastos | 5 |
| S5-05 | Sistema de Insights | 🟣 Kayan | 3 cards automáticos baseados nos dados (ex: "Você gastou X% a mais em Y") | 8 |
| S5-06 | Templates de alertas | 🟣 Kayan | Textos padronizados: "{categoria}: {variação}% vs mês anterior" — reutilizáveis | 5 |
| S5-07 | Filtros e seletor de mês | 🔵 Ryan | Seletor de mês + filtros funcionais na tela de análises | 5 |

> **Paralelismo:** Kayan domina este sprint com insights e templates, Ryan assume o comparativo e filtros.

**Total:** 38 pontos (Kayan: 23 | Ryan: 15)

---

## Sprint 6 — Orçamento (Alocação de Renda)

**Objetivo:** Usuário consegue dividir sua renda em categorias e acompanhar.

| ID | História | Responsável | Critérios de Aceite | Pontos |
|---|---|---|---|---|
| S6-01 | Definir orçamento mensal | 🟣 Kayan | Usuário informa renda total e distribui entre categorias | 8 |
| S6-02 | Visualização do orçamento | 🟣 Kayan | Barras de progresso: valor gasto vs. valor definido por categoria | 8 |
| S6-03 | Alertas de orçamento | 🟣 Kayan | Aviso quando gasto atinge 80% e 100% do limite definido | 5 |
| S6-04 | Saldo restante por categoria | 🔵 Ryan | Mostra quanto ainda pode gastar em cada categoria no mês | 5 |
| S6-05 | Resumo do orçamento | 🔵 Ryan | Card geral: total alocado, total gasto, total disponível | 5 |
| S6-06 | Ajuste de orçamento | 🔵 Ryan | Usuário pode editar os valores alocados a qualquer momento | 3 |

> **Paralelismo:** Kayan cria a UI principal e alertas, Ryan implementa saldo restante e ajustes.

**Total:** 34 pontos (Kayan: 21 | Ryan: 13)

---

## Sprint 7 — Metas Financeiras

**Objetivo:** Usuário cria e acompanha metas de economia.

| ID | História | Responsável | Critérios de Aceite | Pontos |
|---|---|---|---|---|
| S7-01 | Criar meta | 🔵 Ryan | Nome, valor alvo, prazo, ícone/cor | 5 |
| S7-02 | Adicionar aporte | 🔵 Ryan | Usuário adiciona valores à meta ao longo do tempo | 5 |
| S7-03 | Lista de metas | 🟣 Kayan | Cards com: nome, barra de progresso (valor atual / alvo), % concluído, prazo | 5 |
| S7-04 | Detalhes da meta | 🟣 Kayan | Histórico de aportes, previsão de conclusão baseada na média | 5 |
| S7-05 | Meta concluída | 🟣 Kayan | Quando atinge 100%, card muda visual e mostra mensagem de parabéns | 3 |
| S7-06 | Excluir meta | 🔵 Ryan | Com confirmação | 3 |

> **Paralelismo:** Ryan cuida do CRUD completo de metas, Kayan faz a UI da lista, detalhes e feedback visual.

**Total:** 26 pontos (Kayan: 13 | Ryan: 13)

---

## Sprint 8 — Alertas Inteligentes e Polimento

**Objetivo:** Sistema de notificações completo e refinamentos finais.

| ID | História | Responsável | Critérios de Aceite | Pontos |
|---|---|---|---|---|
| S8-01 | Central de notificações | 🟣 Kayan | Tela/ícone com badge mostrando alertas pendentes | 5 |
| S8-02 | Alertas de variação | 🟣 Kayan | "Você gastou {X}% a mais em {categoria} em relação ao mês anterior" | 5 |
| S8-03 | Alertas de orçamento | 🟣 Kayan | "Você atingiu {X}% do limite de {categoria}" | 3 |
| S8-04 | Alertas de meta | 🔵 Ryan | "Faltam R$ {X} para atingir a meta {nome}" | 3 |
| S8-05 | Alertas de economia | 🟣 Kayan | "Sua economia do mês é de {X}% — {mensagem motivacional baseada em limiar}" | 3 |
| S8-06 | Responsividade final | 🟣 Kayan | Testar e corrigir todas as telas em mobile e desktop | 8 |
| S8-07 | Performance | 🔵 Ryan | Otimizar queries do Drift, listas com paginação | 5 |
| S8-08 | Ajustes de UX | Ambos | Animações suaves, feedback visual em ações, empty states | 5 |

> **Paralelismo:** Sprint colaborativo. Kayan lidera alertas e responsividade, Ryan cuida de performance e ajuda com alertas de meta.

**Total:** 37 pontos (Kayan: 24 | Ryan: 8 | Ambos: 5)

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
                                ~16 semanas (4 meses)
```

---

## Divisão de Trabalho — Kayan vs Ryan

### 🟣 Kayan (Product Owner / Dev)
| Área | Responsabilidades |
|---|---|
| **UI/UX** | Design System, layout responsivo, todas as telas principais |
| **Dashboard** | Cards de resumo, gráficos (pizza/donut), fórmulas de cálculo |
| **Análises** | Insights automáticos, templates de alertas, métricas |
| **Orçamento** | Tela de alocação, barras de progresso, alertas de limite |
| **Alertas** | Central de notificações, alertas de variação e economia |
| **Polimento** | Responsividade final, ajustes visuais |

**Total estimado:** ~147 pontos

### 🔵 Ryan (Dev)
| Área | Responsabilidades |
|---|---|
| **Infraestrutura** | Banco de dados (Drift/SQLite), arquitetura em camadas |
| **Autenticação** | Login biométrico, Face ID, PIN, integração local_auth |
| **CRUDs** | Categorias, contas, transações (lógica de persistência) |
| **Extrato** | Listagem, filtros, busca, ordenação, paginação |
| **Metas** | CRUD completo, aporte, exclusão |
| **Performance** | Otimização de queries, paginação, alertas de meta |

**Total estimado:** ~109 pontos

---

### Resumo por Sprint

| Sprint | 🟣 Kayan | 🔵 Ryan | Ambos |
|---|---|---|---|
| S1 — Fundação | 16 pts | 13 pts | — |
| S2 — Auth e Categorias | 5 pts | 18 pts | — |
| S3 — Transações | 16 pts | 16 pts | — |
| S4 — Dashboard | 29 pts | 8 pts | — |
| S5 — Análises | 23 pts | 15 pts | — |
| S6 — Orçamento | 21 pts | 13 pts | — |
| S7 — Metas | 13 pts | 13 pts | — |
| S8 — Alertas e Polimento | 24 pts | 8 pts | 5 pts |
| **Total** | **147** | **104** | **5** |

> *Nota: A divisão não é 50/50 porque Kayan tem mais tarefas de UI (que tendem a ser mais pontuadas). Ryan cuida da infraestrutura e lógica de dados. O importante é que cada sprint tenha trabalho para os dois em paralelo, e ambos façam code review um do outro.*

---

## Colunas do Kanban (GitHub Projects)

```
📋 Backlog  →  📌 To Do  →  🔨 In Progress  →  👀 Review  →  ✅ Done
```
