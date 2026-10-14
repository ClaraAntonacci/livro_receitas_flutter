
# Sabor & Afeto — Livro de Receitas

Aplicativo mobile desenvolvido em Flutter para consultar, cadastrar, editar e excluir receitas culinárias, consumindo uma API própria disponibilizada na nuvem.

O aplicativo permite organizar receitas em um só lugar, visualizar seus ingredientes e modos de preparo e consultar o custo aproximado de cada prato.

## Telas do aplicativo

### 1. Splash Screen

Tela inicial do aplicativo, com animação de abertura e a identidade visual do Sabor & Afeto.

![Splash Screen](assets/splash.png)

### 2. Início

Tela principal com a lista de receitas cadastradas, campo de pesquisa por nome ou ingrediente, imagens, tipo da receita e custo aproximado.

![Tela inicial](assets/inicio.png)

### 3. Nova Receita

Formulário para cadastrar receitas, informando nome, tipo, ingredientes, modo de preparo, URL da imagem e custo aproximado.

![Nova receita](assets/nova_receita.png)

## Funcionalidades

- Consultar receitas cadastradas na API.
- Pesquisar receitas pelo nome ou pelos ingredientes.
- Visualizar os detalhes de cada receita.
- Cadastrar novas receitas.
- Editar receitas existentes.
- Excluir receitas.
- Atualizar a lista de receitas.
- Utilizar navegação inferior entre Splash, Início e Nova Receita.
- Utilizar temas claro e escuro conforme a configuração do sistema.
- Exibir uma tela de abertura com animação.

## Tecnologias utilizadas

- Flutter
- Dart
- HTTP
- API REST
- intl
- shared_preferences

## API utilizada

API de receitas disponibilizada para a atividade do SENAI.

- [Acessar a API](https://receitasapi-b-2025.vercel.app/)
- [Repositório da API](https://github.com/wellifabio/receitasapp-expo-2025.git)
- [Front-end de referência](https://wellifabio.github.io/receitas-web-2025/)

## Como executar o projeto

### Pré-requisitos

- Flutter instalado e configurado.
- Dart instalado com o Flutter.
- Android Studio ou Visual Studio Code.
- Acesso à internet.

### Instalação

1. Clone o repositório:

   ```bash
   git clone URL_DO_SEU_REPOSITORIO
   ```

2. Entre na pasta do projeto:

   ```bash
   cd livro_receitas_flutter
   ```

3. Instale as dependências:

   ```bash
   flutter pub get
   ```

4. Execute o aplicativo:

   ```bash
   flutter run
   ```

## APK

O APK de instalação do aplicativo está disponível na pasta `assets` do repositório.

Arquivo: `assets/livro_receitas.apk`

## Desenvolvimento

Projeto desenvolvido como atividade acadêmica do curso técnico de Desenvolvimento de Sistemas do SENAI, com o objetivo de praticar o desenvolvimento mobile em Flutter e o consumo de uma API back-end própria.

---

**Sabor & Afeto — Feito em casa, feito com carinho.**
