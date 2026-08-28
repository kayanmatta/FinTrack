# FinTrack — Setup Pendente no Jira

## Status Atual

- ✅ Projeto Scrum criado (key: FINTRACK)
- ✅ Sprint 1 criado com 6 stories (FINTRACK-7 a FINTRACK-12)
- ✅ 6 Épicos criados no cronograma (Fundação, Autenticação, Transações, Categorias, Contas, Dashboard)
- ✅ Assignees configurados (Kayan e Ryan)
- ✅ Story points atribuídos

---

## Pendente: Configurar Board

### Criar status custom "In Review"

> `Project Settings → Workflows → Edit Workflow → Add Status`

```
To Do → In Progress → In Review → Done
```

---

## Pendente: Criar 6 Épicos restantes

| Epic Name | Summary | Descrição |
|---|---|---|
| FT-E7 | Extrato | Consulta de movimentações com filtros |
| FT-E8 | Análises | Dashboard analítico com insights |
| FT-E9 | Orçamento | Alocação de renda por categoria |
| FT-E10 | Metas Financeiras | Definição e acompanhamento de metas |
| FT-E11 | Alertas Inteligentes | Sistema de notificações baseadas em templates |
| FT-E12 | Polimento | Refinamentos finais, performance e UX |

---

## Pendente: Criar Sprints 2 a 8

> **Ir em:** Backlog → Criar sprint → Adicionar stories

### Sprint 2 — Autenticação e Categorias

| # | Summary | Épico | Assignee | Story Points | Priority | Labels |
|---|---|---|---|---|---|---|
| 1 | Tela de login | Autenticação | Kayan | 5 | High | `frontend`, `auth` |
| 2 | Integração local_auth | Autenticação | Ryan | 5 | High | `backend`, `auth` |
| 3 | CRUD de categorias | Categorias | Ryan | 5 | High | `backend`, `crud` |
| 4 | Categorias padrão | Categorias | Ryan | 3 | Medium | `backend`, `seed` |
| 5 | CRUD de contas financeiras | Contas | Ryan | 5 | High | `backend`, `crud` |

**Total:** 23 pontos (Kayan: 5 | Ryan: 18)

**Descrições para copiar:**

**Tela de login:**
```
Como usuário,
Quero uma tela de login bonita e funcional
Para acessar o app de forma segura.

Critérios de Aceite:
- Interface conforme mockup (tema escuro, logo FinTrack)
- Botão de biometria/Face ID
- Opção de PIN como fallback
- Animação de carregamento durante autenticação
- Responsiva (mobile e desktop)
```

**Integração local_auth:**
```
Como usuário,
Quero usar biometria ou PIN para acessar o app
Para ter segurança sem complicação.

Critérios de Aceite:
- local_auth integrado ao projeto
- Biometria funcional (impressão digital)
- Face ID funcional (em dispositivos compatíveis)
- PIN do dispositivo como opção
- Tratamento de erros (biometria indisponível, cancelamento)
- Autenticação 100% local (sem envio a servidores)
```

**CRUD de categorias:**
```
Como usuário,
Quero criar, editar e excluir categorias
Para organizar minhas finanças do meu jeito.

Critérios de Aceite:
- Tela de listagem de categorias
- Criar categoria com: nome, ícone, cor
- Editar categoria existente
- Excluir categoria com confirmação
- Validação de nome duplicado
- Persistência no banco via Drift
```

**Categorias padrão:**
```
Como usuário,
Quero ter categorias pré-cadastradas
Para não precisar criar tudo do zero.

Critérios de Aceite:
- Categorias criadas no primeiro acesso:
  Mercado, Transporte, Lazer, Saúde, Casa, Educação, Compras, Outros
- Cada uma com ícone e cor definidos
- Usuário pode editar/excluir as padrão
```

**CRUD de contas financeiras:**
```
Como usuário,
Quero gerenciar minhas contas financeiras
Para registrar transações em diferentes lugares.

Critérios de Aceite:
- Tela de listagem de contas
- Criar conta com: nome, tipo (corrente, carteira, poupança, investimento)
- Editar conta existente
- Excluir conta com confirmação (aviso se tiver transações)
- Saldo visível por conta
```

---

### Sprint 3 — Transações

| # | Summary | Épico | Assignee | Story Points | Priority | Labels |
|---|---|---|---|---|---|---|
| 1 | Tela Nova Transação | Transações | Kayan | 8 | High | `frontend`, `form` |
| 2 | Salvar transação | Transações | Ryan | 5 | High | `backend`, `persist` |
| 3 | Listar transações | Transações | Ryan | 5 | High | `backend`, `list` |
| 4 | Editar transação | Transações | Ryan | 3 | Medium | `backend`, `crud` |
| 5 | Excluir transação | Transações | Ryan | 3 | Medium | `backend`, `crud` |
| 6 | Tela de Extrato | Extrato | Kayan | 8 | High | `frontend`, `filters` |

**Total:** 32 pontos (Kayan: 16 | Ryan: 16)

**Descrições para copiar:**

**Tela Nova Transação:**
```
Como usuário,
Quero um formulário intuitivo para registrar transações
Para registrar receitas e despesas rapidamente.

Critérios de Aceite:
- Toggle Despesa (vermelho) / Receita (verde)
- Campo de valor com máscara monetária (R$)
- Grade de ícones de categorias (8 ícones visíveis)
- Seletor de data (padrão: hoje)
- Campo de descrição (opcional)
- Seletor de conta financeira
- Botão "Salvar transação" (roxo)
- Responsiva (mobile e desktop)
```

**Salvar transação:**
```
Como usuário,
Quero que minha transação seja salva corretamente
Para manter meu controle financeiro atualizado.

Critérios de Aceite:
- Dados persistidos no SQLite via Drift
- Validação: valor obrigatório, categoria obrigatória
- Feedback visual de sucesso (snackbar)
- Redirecionamento para tela anterior após salvar
```

**Listar transações:**
```
Como usuário,
Quero ver minhas transações organizadas por data
Para entender meu histórico financeiro.

Critérios de Aceite:
- Transações ordenadas por data (mais recente primeiro)
- Agrupadas por dia: "Hoje", "Ontem", data formatada
- Ícone da categoria + nome + valor + horário
- Receita em verde, despesa em vermelho
- Scroll suave
```

**Editar transação:**
```
Como usuário,
Quero editar uma transação existente
Para corrigir informações erradas.

Critérios de Aceite:
- Clicar na transação abre tela de edição
- Todos os campos editáveis
- Salvar atualiza o banco
- Feedback visual de sucesso
```

**Excluir transação:**
```
Como usuário,
Quero excluir uma transação
Para remover lançamentos incorretos.

Critérios de Aceite:
- Opção de excluir (ícone ou swipe)
- Diálogo de confirmação: "Excluir esta transação?"
- Remoção do banco após confirmação
- Atualização automática da lista
```

**Tela de Extrato:**
```
Como usuário,
Quero uma tela completa para consultar movimentações
Para analisar meu histórico detalhadamente.

Critérios de Aceite:
- Campo de busca instantânea
- Filtro por categoria (dropdown)
- Filtro por conta (dropdown)
- Filtro por período (data início/fim)
- Filtro por tipo: Todas, Receitas, Despesas (tabs)
- Ordenação (data, valor)
- Visualização em lista e tabela (toggle)
- Resumo: total filtrado + quantidade de lançamentos
- Responsiva
```

---

### Sprint 4 — Dashboard Principal

| # | Summary | Épico | Assignee | Story Points | Priority | Labels |
|---|---|---|---|---|---|---|
| 1 | Cards de resumo | Dashboard | Kayan | 8 | High | `frontend`, `cards` |
| 2 | Gráfico de pizza — Gastos por categoria | Dashboard | Kayan | 8 | High | `frontend`, `chart` |
| 3 | Gráfico de linha — Evolução de despesas | Dashboard | Ryan | 5 | Medium | `frontend`, `chart` |
| 4 | Últimas transações | Dashboard | Ryan | 3 | Medium | `frontend`, `list` |
| 5 | Fórmulas de cálculo padronizadas | Dashboard | Kayan | 8 | High | `core`, `formulas` |
| 6 | Dashboard responsivo | Dashboard | Kayan | 5 | High | `frontend`, `responsive` |

**Total:** 37 pontos (Kayan: 29 | Ryan: 8)

**Descrições para copiar:**

**Cards de resumo:**
```
Como usuário,
Quero ver cards com meu resumo financeiro
Para ter uma visão rápida da minha situação.

Critérios de Aceite:
- 4 cards: Saldo atual, Receitas, Despesas, Economia
- Cada card mostra valor atual + variação % vs mês anterior
- Variação positiva em verde, negativa em vermelho
- Ícones distintos por card
- Animação ao carregar valores
- Responsivo: grid 4 colunas (desktop), 2 colunas (mobile)
```

**Gráfico de pizza — Gastos por categoria:**
```
Como usuário,
Quero ver um gráfico de pizza dos meus gastos
Para entender para onde meu dinheiro está indo.

Critérios de Aceite:
- Gráfico donut chart com segmentos coloridos
- Total centralizado no gráfico
- Legenda com: categoria, %, valor absoluto
- Cores por categoria (mesmas do cadastro)
- Interação: clicar no segmento destaca a categoria
```

**Fórmulas de cálculo padronizadas:**
```
Como desenvolvedor,
Quero todas as fórmulas centralizadas em /core
Para garantir consistência e facilitar manutenção.

Critérios de Aceite:
- Classe FinancialFormulas criada em core/
- Fórmula: variação percentual = ((atual - anterior) / anterior) * 100
- Fórmula: % por categoria = (gasto_categoria / total) * 100
- Fórmula: economia % = ((receitas - despesas) / receitas) * 100
- Fórmula: média diária = total_despesas / dias_do_mes
- Testes unitários para cada fórmula
- Sem lógica hardcoded nas telas
```

---

### Sprint 5 — Dashboard Analítico

| # | Summary | Épico | Assignee | Story Points | Priority | Labels |
|---|---|---|---|---|---|---|
| 1 | Cards de métricas analíticos | Análises | Kayan | 5 | High | `frontend`, `analytics` |
| 2 | Ranking de maiores gastos | Análises | Kayan | 5 | Medium | `frontend`, `analytics` |
| 3 | Comparativo mensal | Análises | Ryan | 5 | Medium | `frontend`, `chart` |
| 4 | Resumo do mês | Análises | Ryan | 5 | Medium | `frontend`, `analytics` |
| 5 | Sistema de Insights | Análises | Kayan | 8 | High | `core`, `insights` |
| 6 | Templates de alertas | Análises | Kayan | 5 | High | `core`, `templates` |
| 7 | Filtros e seletor de mês | Análises | Ryan | 5 | Medium | `frontend`, `filters` |

**Total:** 38 pontos (Kayan: 23 | Ryan: 15)

**Descrições para copiar:**

**Sistema de Insights:**
```
Como usuário,
Quero receber insights automáticos sobre meus gastos
Para descobrir padrões e melhorar minhas finanças.

Critérios de Aceite:
- 3 cards de insights visíveis na tela
- Insight 1: Variação de categoria (ex: "Você gastou 12% a mais em Alimentação")
- Insight 2: Padrão temporal (ex: "Sábado é o dia que você mais gasta")
- Insight 3: Destaque positivo/negativo (ex: "Menor gasto com Transporte em 6 meses")
- Insights gerados por fórmulas determinísticas
- Templates de texto reutilizáveis
- Atualizados ao mudar o mês selecionado
```

**Templates de alertas:**
```
Como desenvolvedor,
Quero templates de texto padronizados para alertas e insights
Para manter consistência e facilitar traduções futuras.

Critérios de Aceite:
- Classe AlertTemplates criada em core/
- Template: "{categoria}: {variação}% vs mês anterior"
- Template: "Você gastou {X}% a mais em {categoria}"
- Template: "Seu maior gasto foi {nome} R$ {valor}"
- Template: "Este foi seu menor gasto com {categoria} nos últimos {N} meses"
- Suporte a pluralização (mês/meses)
- Textos em português
```

---

### Sprint 6 — Orçamento (Alocação de Renda)

| # | Summary | Épico | Assignee | Story Points | Priority | Labels |
|---|---|---|---|---|---|---|
| 1 | Definir orçamento mensal | Orçamento | Kayan | 8 | High | `frontend`, `budget` |
| 2 | Visualização do orçamento | Orçamento | Kayan | 8 | High | `frontend`, `budget` |
| 3 | Alertas de orçamento | Orçamento | Kayan | 5 | Medium | `core`, `alerts` |
| 4 | Saldo restante por categoria | Orçamento | Ryan | 5 | Medium | `backend`, `budget` |
| 5 | Resumo do orçamento | Orçamento | Ryan | 5 | Medium | `frontend`, `budget` |
| 6 | Ajuste de orçamento | Orçamento | Ryan | 3 | Low | `frontend`, `budget` |

**Total:** 34 pontos (Kayan: 21 | Ryan: 13)

**Descrições para copiar:**

**Definir orçamento mensal:**
```
Como usuário,
Quero definir quanto vou gastar em cada categoria
Para controlar melhor meu dinheiro.

Critérios de Aceite:
- Tela de orçamento com campo de renda total
- Lista de categorias com campo de valor para cada
- Soma parcial visível (quanto já alocou)
- Validação: soma não pode ultrapassar renda total
- Botão "Salvar orçamento"
- Persistência mensal (renova a cada mês)
```

**Visualização do orçamento:**
```
Como usuário,
Quero ver visualmente como estou em relação ao orçamento
Para saber se estou dentro ou fora do planejado.

Critérios de Aceite:
- Barras de progresso por categoria (gasto / definido)
- Barra verde (<60%), amarela (60-80%), vermelha (>80%)
- Valor gasto e valor definido visíveis
- Percentual de utilização
- Atualização em tempo real ao registrar transações
```

**Alertas de orçamento:**
```
Como usuário,
Quero ser avisado quando estou perto de estourar o orçamento
Para evitar gastos excessivos.

Critérios de Aceite:
- Aviso visual quando atinge 80% do limite
- Alerta destacado quando atinge 100%
- Badge na central de notificações
- Mensagem: "Você atingiu {X}% do limite de {categoria}"
```

---

### Sprint 7 — Metas Financeiras

| # | Summary | Épico | Assignee | Story Points | Priority | Labels |
|---|---|---|---|---|---|---|
| 1 | Criar meta | Metas Financeiras | Ryan | 5 | High | `backend`, `crud` |
| 2 | Adicionar aporte | Metas Financeiras | Ryan | 5 | High | `backend`, `crud` |
| 3 | Lista de metas | Metas Financeiras | Kayan | 5 | High | `frontend`, `goals` |
| 4 | Detalhes da meta | Metas Financeiras | Kayan | 5 | Medium | `frontend`, `goals` |
| 5 | Meta concluída | Metas Financeiras | Kayan | 3 | Low | `frontend`, `goals` |
| 6 | Excluir meta | Metas Financeiras | Ryan | 3 | Medium | `backend`, `crud` |

**Total:** 26 pontos (Kayan: 13 | Ryan: 13)

**Descrições para copiar:**

**Criar meta:**
```
Como usuário,
Quero criar metas financeiras
Para ter objetivos claros de economia.

Critérios de Aceite:
- Formulário: nome, valor alvo, prazo, ícone, cor
- Validação: valor > 0, nome obrigatório
- Meta criada com valor atual = R$ 0,00
- Persistência no banco
```

**Adicionar aporte:**
```
Como usuário,
Quero adicionar valores à minha meta ao longo do tempo
Para acompanhar minha evolução.

Critérios de Aceite:
- Botão "Adicionar aporte" na meta
- Campo de valor com máscara monetária
- Histórico de aportes salvo
- Valor atual atualizado automaticamente
- Barra de progresso recalculada
```

**Lista de metas:**
```
Como usuário,
Quero ver todas as minhas metas em cards visuais
Para acompanhar o progresso de cada uma.

Critérios de Aceite:
- Cards com: nome, ícone, cor, barra de progresso
- Valor atual / valor alvo formatado (R$)
- Percentual concluído
- Prazo restante
- Botão "Ver todas as metas" no dashboard
```

---

### Sprint 8 — Alertas Inteligentes e Polimento

| # | Summary | Épico | Assignee | Story Points | Priority | Labels |
|---|---|---|---|---|---|---|
| 1 | Central de notificações | Alertas Inteligentes | Kayan | 5 | High | `frontend`, `notifications` |
| 2 | Alertas de variação | Alertas Inteligentes | Kayan | 5 | High | `core`, `alerts` |
| 3 | Alertas de orçamento | Alertas Inteligentes | Kayan | 3 | Medium | `core`, `alerts` |
| 4 | Alertas de meta | Alertas Inteligentes | Ryan | 3 | Medium | `core`, `alerts` |
| 5 | Alertas de economia | Alertas Inteligentes | Kayan | 3 | Medium | `core`, `alerts` |
| 6 | Responsividade final | Polimento | Kayan | 8 | High | `frontend`, `responsive` |
| 7 | Performance | Polimento | Ryan | 5 | High | `backend`, `performance` |
| 8 | Ajustes de UX | Polimento | Ambos | 5 | Medium | `frontend`, `ux` |

**Total:** 37 pontos (Kayan: 24 | Ryan: 8 | Ambos: 5)

**Descrições para copiar:**

**Central de notificações:**
```
Como usuário,
Quero um lugar para ver todos os alertas
Para não perder avisos importantes.

Critérios de Aceite:
- Ícone de sino no header com badge de contagem
- Tela de notificações com lista de alertas
- Alerta com: ícone, texto, data/hora, lido/não lido
- Marcar como lido ao clicar
- "Limpar todas" opção
```

**Ajustes de UX:**
```
Como usuário,
Quero uma experiência polida e agradável
Para usar o app com prazer.

Critérios de Aceite:
- Animações de transição entre telas
- Skeleton loading em listas e gráficos
- Empty states ilustrados (sem transações, sem metas, etc.)
- Feedback háptico em ações principais (mobile)
- Snackbars para ações rápidas
- Pull-to-refresh em listas
```

---

## Pendente: Backlog V2 (Futuro)

> Criar como itens no Backlog, sem sprint atribuído.

| Summary | Tipo | Priority | Labels |
|---|---|---|---|
| Criptografia SQLCipher | Story | High | `security`, `v2` |
| Backup manual | Story | High | `data`, `v2` |
| Exportação CSV | Story | Medium | `data`, `v2` |
| Importação CSV | Story | Medium | `data`, `v2` |
| Relatórios em PDF | Story | Low | `reports`, `v2` |
| Tema claro | Story | Low | `frontend`, `v2` |
| Widgets para home screen | Story | Low | `mobile`, `v2` |

---

## Pendente: Labels

> Criar em: `Project Settings → Labels`

| Label | Cor | Uso |
|---|---|---|
| `frontend` | Verde | Tasks de UI |
| `backend` | Azul | Lógica, banco, persistência |
| `core` | Roxo | Fórmulas, templates, lógica central |
| `chart` | Amarelo | Gráficos |
| `crud` | Cinza | Operações CRUD |
| `responsive` | Ciano | Responsividade |
| `v2` | Vermelho | Backlog futuro |

---

## Checklist Final

- [ ] Status "In Review" criado no workflow
- [ ] 6 Épicos restantes criados (Extrato, Análises, Orçamento, Metas, Alertas, Polimento)
- [ ] Sprints 2 a 8 criados com stories
- [ ] Labels criadas e aplicadas
- [ ] Datas definidas no cronograma
- [ ] Notification scheme configurado (avisar assignee)
