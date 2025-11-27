# 🍲 Rango Legal

Aplicativo desenvolvido como parte das Sprints 1 e 2 do projeto **Rango Legal**, voltado para o gerenciamento e recomendação de receitas culinárias, com base no perfil nutricional do usuário.

---

## 👥 Equipe do Projeto

| Nome                      | Função                                                    |
| ------------------------- | --------------------------------------------------------- |
| **Maria Eduarda Martins** | Backend (CRUD de receitas, integração com banco de dados) |
| **Fernando Theodoro**     | Frontend (telas do app, UX)                               |
| **Mateus Evangelista**    | Designer UI/UX                                            |
| **Diogo Patrick**         | Scrum Master / Suporte                                    |
| **Welbert Almeida**       | Documentação e QA                                         |
| **Rafael Jardim**         | Inteligência Artificial                                   |

---

## 🎯 Objetivo do Aplicativo

O **Rango Legal** tem como propósito **organizar e disponibilizar receitas culinárias**, permitindo ao usuário:

* Cadastrar, editar, excluir e consultar receitas (CRUD);
* Receber recomendações de pratos com base no **perfil nutricional pessoal**;
* Manter um **repositório pessoal de receitas favoritas**;
* Explorar novas receitas por **nome ou ingrediente**;
* Aproveitar uma **interface simples e intuitiva**.

---

## 👥 Público-Alvo

Usuários que desejam **organizar suas receitas**, **personalizar sua alimentação** e **descobrir novas opções** de pratos com base em seu perfil nutricional — desde iniciantes na cozinha até pessoas que seguem dietas específicas.

---

## ⚙️ Principais Funcionalidades

* **Definição do Perfil Nutricional** (preferências, restrições e objetivos alimentares);
* **Busca de Receitas** por nome ou ingrediente;
* **Recomendações por Inteligência Artificial**;
* **CRUD de Receitas** (criação, leitura, atualização e exclusão);
* **Organização por Categorias** (sobremesas, massas, carnes etc.);
* **Interface Intuitiva e Moderna**.

---

## 🧩 Estrutura de Telas (Sprint 1)

1. **Tela de Login / Cadastro**

   * Acesso inicial ao app.
   * Opção para criar conta ou entrar com credenciais existentes.

2. **Tela Principal (Lista de Receitas)**

   * Exibe todas as receitas cadastradas pelo usuário.
   * Permite acessar detalhes e editar ou excluir.

3. **Tela de Cadastro / Edição de Receita**

   * Formulário para inserir ou atualizar informações sobre receitas.

4. **Tela de Cadastro do Perfil Nutricional**

   * Usuário define restrições alimentares, metas e preferências.

5. **Tela de Recomendação da IA**

   * Sugestões automáticas baseadas no perfil do usuário.

---

## 💻 Telas Implementadas no Flutter (Sprint 2)

1. **Tela de Login**

   * Interface de autenticação e cadastro de novos usuários.

2. **Tela Principal**

   * Lista de receitas disponíveis com filtros e categorias.

3. **Tela de Visualização de Receitas**

   * Exibição detalhada de cada receita cadastrada.

4. **Tela de Cadastro do Perfil Nutricional**

   * Entrada e edição dos dados do perfil alimentar.

5. **Tela de Recomendação da IA**

   * Mostra receitas sugeridas com base no perfil e histórico.

6. **Tela de Perfil e Sobre**

   * Informações sobre o usuário e o aplicativo.

---

## 🧠 Inteligência Artificial

O módulo de IA, desenvolvido por **Rafael Jardim**, realiza a análise do **perfil nutricional** do usuário e das **características das receitas**, gerando recomendações personalizadas com base em:

* Ingredientes mais utilizados;
* Restrições alimentares;
* Preferências registradas;
* Histórico de interações.

---

## 🧱 Tecnologias Utilizadas

* **Frontend:** Flutter
* **Backend:** Integração com banco de dados (Maria Eduarda Martins)
* **IA:** Módulo de recomendação inteligente (Rafael Jardim)
* **Controle de Versão:** Git e GitHub
* **Design:** UI/UX com foco em usabilidade (Mateus Evangelista)

---

## 📱 Fluxo de Navegação

1. O usuário faz **login** ou cria uma conta.
2. Define seu **perfil nutricional** (restrições e preferências).
3. Acessa a **lista de receitas** ou cadastra novas.
4. Recebe **recomendações automáticas** via IA.
5. Pode **editar, excluir ou favoritar** receitas.

---

## 🧩 Estrutura de Sprints

### 🏁 Sprint 1

* Criação da proposta inicial do app.
* Definição das telas e das principais funcionalidades.
* Rascunhos de UI e arquitetura base.
* Documentação inicial e atribuição de papéis.


### 🚀 Sprint 2

* Implementação das telas no **Flutter**.
* Conexão entre as páginas (navegação funcional).
* Ajuste de layout e usabilidade.
* Preparação do módulo de IA e do CRUD de receitas.
* Documentação e QA .


### 🚀 Sprint 3

✔ Banco de dados completo (Minimundo + DER + Esquema)
✔ Integração total entre Flutter e Banco de Dados
✔ CRUD funcional para Perfis e Receitas
✔ Base sólida para o módulo de recomendação por IA (em implementação )

---

# 🧱 1) Projeto do Banco de Dados ( Sprint 3)

*(Exigência da Sprint)*

A Sprint 3 consolidou o **modelo de dados completo**, responsável por armazenar usuários, perfis nutricionais e receitas.
A seguir estão os artefatos que descrevem o banco:

---

## 📄 1.1. Minimundo

Segundo o documento oficial da Sprint:

O sistema permite:

* Usuários cadastrados com **nome, sobrenome, email e senha**.
* Cada usuário pode possuir **um ou mais perfis nutricionais**, contendo:

  * idade, peso, altura, sexo, nível de atividade física,
  * objetivo nutricional,
  * restrições alimentares,
  * preferências alimentares.
* Cada perfil pode ter **múltiplas receitas personalizadas**, incluindo:

  * nome da receita,
  * ingredientes,
  * modo de preparo,
  * restrições alimentares específicas.

### 📌 Estrutura da Tabela Usuário

| Campo         | Tipo  |
| ------------- | ----- |
| id            | PK    |
| primeiro_nome | texto |
| sobrenome     | texto |
| email         | texto |
| senha         | texto |

---

# ⚙️ 2) Integração CRUD Completa no App

*(Exigência da Sprint)*

Nesta Sprint, o banco de dados foi integrado ao aplicativo Flutter, permitindo operações **Create, Read, Update e Delete**.

---

## 🔧 2.1. CRUD de Receitas

Baseado nas telas da Sprint:

* **Criar Receita:** formulário com nome, ingredientes, preparo e restrições.
* **Listar Receitas:** exibição na tela inicial após login.
* **Editar Receita:** alteração dos dados cadastrados.
* **Excluir Receita:** ação disponível no menu da receita.

Todas as operações realizam acesso direto ao banco seguindo o DER definido.

---

## 🔧 2.2. CRUD de Perfis Nutricionais

Baseado nas telas da Sprint:

* **Criar Perfil:** inclui idade, peso, altura, objetivo e outras informações.
* **Listar Perfis:** tela dedicada para visualizar perfis já cadastrados.
* **Editar Perfil:** atualização dos valores do perfil selecionado.
* **Excluir Perfil:** removido conforme o usuário logado.

O sistema permite **vários perfis por usuário**, conforme descrito no minimundo.

---

## 🤖 2.3. Integração com Recomendação (IA)

* A IA utiliza **dados do perfil** + **características das receitas**. ( falta implementar)
* As recomendações são atualizadas dinamicamente conforme o perfil do usuário.

---

# 🎥 Demonstração em Aula

A demonstração desta sprint envolverá:

✔ Login do usuário
✔ Criação do perfil nutricional
✔ Adicionar nova receita
✔ Editar e excluir receitas
✔ Exibir listas e perfis cadastrados

---

## 🔗 Repositório no GitHub

> 🔗 [Acesse o projeto no GitHub](https://github.com/portofth/RangoLegal)

---

## 📄 Conclusão

O **Rango Legal** busca facilitar o gerenciamento de receitas culinárias, unindo **organização, praticidade e inteligência artificial** para gerar recomendações personalizadas.
O projeto foi desenvolvido de forma colaborativa, com divisão clara de tarefas e foco em **usabilidade**, **design limpo** e **funcionalidade prática**, servindo de base sólida para as próximas sprints.

