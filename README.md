# FinTrack

<div align="center">

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
<img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
<img src="https://img.shields.io/badge/Offline--First-10B981?style=for-the-badge" alt="Offline First" />
<img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="MIT License" />

</div>

<br>

FinTrack é um aplicativo multiplataforma para gerenciamento financeiro pessoal desenvolvido em Flutter com foco em simplicidade, privacidade e desempenho.

Diferente de aplicações que dependem de servidores ou sincronização em nuvem, o FinTrack foi projetado para funcionar completamente offline. Todas as informações permanecem armazenadas exclusivamente no dispositivo do usuário, eliminando dependências de conexão com a internet e oferecendo uma experiência rápida e responsiva.

O projeto busca oferecer uma maneira prática de registrar receitas e despesas, acompanhar indicadores financeiros e entender exatamente para onde o dinheiro está sendo destinado através de gráficos, relatórios e consultas detalhadas.

---

# Principais Recursos

### Controle Financeiro

- Cadastro de receitas
- Cadastro de despesas
- Contas financeiras personalizadas
- Categorias personalizadas
- Metas financeiras

---

### Dashboard

- Saldo atual
- Total de receitas
- Total de despesas
- Economia mensal
- Últimas movimentações
- Indicadores financeiros
- Gráficos de evolução

---

### Extrato Financeiro

Tela dedicada para consulta de todas as movimentações registradas.

Recursos disponíveis:

- Pesquisa instantânea
- Filtro por categoria
- Filtro por conta
- Filtro por período
- Filtro por tipo de movimentação
- Ordenação
- Visualização em lista
- Visualização em tabela

---

### Dashboard Analítico

Todos os indicadores são gerados localmente utilizando consultas ao banco de dados.

Exemplos:

- Categoria com maior gasto
- Comparação entre meses
- Média diária de despesas
- Evolução financeira
- Gastos por categoria
- Maiores despesas
- Estabelecimentos mais utilizados

---

### Segurança

O aplicativo utiliza os recursos de autenticação disponíveis no próprio dispositivo.

Suporte para:

- Impressão Digital
- Face ID
- PIN do dispositivo

A autenticação é realizada localmente, sem necessidade de envio de informações para serviços externos.

---

### Funcionamento Offline

O FinTrack foi desenvolvido seguindo a abordagem **Offline First**.

Isso significa que:

- Não existe dependência de internet.
- Não existem servidores remotos.
- Não existe sincronização em nuvem.
- Todas as consultas são executadas localmente.
- Todos os dados permanecem no dispositivo.

Esse modelo garante maior privacidade e tempos de resposta praticamente instantâneos.

---

# Tecnologias

## Flutter

Framework responsável pelo desenvolvimento da interface da aplicação.

Permite gerar executáveis nativos para:

- Android
- iOS
- Windows
- macOS
- Linux

---

## Riverpod

Responsável pelo gerenciamento de estado da aplicação.

Foi escolhido por oferecer:

- Código previsível
- Reatividade
- Fácil manutenção
- Baixo acoplamento

---

## SQLite

Toda persistência de dados acontece utilizando SQLite.

O banco armazena informações como:

- Usuários
- Contas
- Categorias
- Transações
- Metas

Como todo o armazenamento é local, não existe necessidade de infraestrutura em nuvem.

---

## Drift

ORM utilizado para comunicação entre o Flutter e o SQLite.

Principais vantagens:

- Queries tipadas
- Segurança durante o desenvolvimento
- Migrações
- Facilidade de manutenção

---

## local_auth

Utilizado para integração com os métodos de autenticação do sistema operacional.

Compatível com:

- Biometria
- Face ID
- PIN

---

# Arquitetura

O projeto segue uma arquitetura baseada em camadas para facilitar manutenção, organização e evolução da aplicação.

```
Presentation
       │
       ▼
Domain
       │
       ▼
Data
       │
       ▼
SQLite (Drift)
```

Cada camada possui responsabilidades específicas:

- **Presentation**: Interface do usuário, telas, widgets e gerenciamento de estado.
- **Domain**: Regras de negócio, entidades e contratos.
- **Data**: Persistência de dados, repositórios e acesso ao banco.

---

# Estrutura do Projeto

```
lib/
│
├── core/
│
├── data/
│   ├── database/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── providers/
│   └── components/
│
└── main.dart
```

---

# Modelo de Segurança

O projeto foi pensado para manter todos os dados sob controle do próprio usuário.

Princípios adotados:

- Armazenamento exclusivamente local.
- Dados isolados no armazenamento do aplicativo.
- Autenticação utilizando recursos nativos do sistema operacional.
- Arquitetura preparada para criptografia do banco de dados utilizando SQLCipher em versões futuras.
- Processo de build preparado para ofuscação do código compilado.

---

# Como Executar

## Pré-requisitos

- Flutter SDK instalado
- Android Studio ou VS Code
- Emulador ou dispositivo físico

---

## Clonar o projeto

```bash
git clone https://github.com/kayanmatta/FinTrack.git
```

---

## Instalar dependências

```bash
flutter pub get
```

---

## Gerar arquivos do Drift

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Executar

```bash
flutter run
```

Para executar no Desktop, habilite o suporte correspondente:

```bash
flutter config --enable-windows-desktop
```

---

# Roadmap

## Versão 1

- Login biométrico
- Dashboard
- Receitas
- Despesas
- Categorias
- Contas
- Extrato
- Dashboard Analítico
- Metas Financeiras
- Funcionamento Offline

---

## Versão 2

- Criptografia completa do banco utilizando SQLCipher
- Exportação de dados
- Importação de arquivos CSV
- Backup manual
- Relatórios em PDF
- Melhorias na experiência de uso

---

# Screenshots

As capturas de tela serão adicionadas conforme o desenvolvimento da aplicação.

| Dashboard | Extrato | Dashboard Analítico |
|----------|----------|---------------------|
| Em desenvolvimento | Em desenvolvimento | Em desenvolvimento |

---

# Licença

Este projeto está licenciado sob a licença MIT.

---

# Contato

Desenvolvido por **Kayan da Matta** ([@kayanmatta](https://github.com/kayanmatta)).

Caso tenha sugestões ou encontre algum problema, fique à vontade para abrir uma *Issue* ou enviar um *Pull Request*.
