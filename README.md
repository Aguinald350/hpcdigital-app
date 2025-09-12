# HPC Digital — App Flutter

Aplicativo Flutter com integração Firebase para gerenciamento de hinos, eventos e informações da igreja.

## 🧱 Stack
- **Flutter** (Dart)
- **Firebase** (Auth, Firestore, Storage, etc.)
- **Android Studio** / VS Code
- **Git/GitHub**

---

## ✅ Pré-requisitos

1. **Flutter** instalado  
   ```bash
   flutter --version
   flutter doctor


## 2. Android Studio** (SDK + emulador) ou dispositivo físico.

3. **Acesso ao Firebase do projeto**

    * Você deve ter permissão no console do Firebase.
    * Combine com o time a estratégia para **compartilhar as credenciais** (veja seção “Segredos e credenciais”).

---

## 🚀 Como clonar e rodar

### 1) Clonar o repositório

```bash
git clone https://github.com/Aguinald350/hpcdigital-app.git
cd hpcdigital-app
```

### 2) Instalar dependências

```bash
flutter pub get
```

### 3) Configurar o Firebase (uma das opções)

#### Opção A — Já existe `lib/firebase_options.dart` no repo

* Se o arquivo **já está versionado**, pule para “Rodar”.
* Caso não esteja ou você precise regenerar:

  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure
  ```

  Isso cria/atualiza `lib/firebase_options.dart`.

> **Android:** coloque `android/app/google-services.json` (não deve ser commitado).
> **iOS:** coloque `ios/Runner/GoogleService-Info.plist` (não deve ser commitado).

### 4) Rodar

* Pelo Android Studio: **Run ▶️**
* Ou por terminal:

  ```bash
  flutter run
  ```

---

## 🔐 Segredos e credenciais

Por padrão, **NÃO** fazemos commit de:

* `android/app/google-services.json`
* `ios/Runner/GoogleService-Info.plist`

Esses arquivos devem ser compartilhados de forma segura (1Password/Drive com acesso restrito) e adicionados localmente.
O `lib/firebase_options.dart` pode ser versionado (mais prático para o time).

---

## 👥 Colaboração (Android Studio)

1. Seja adicionado como **colaborador** no GitHub.
2. Android Studio → **Get from VCS** → cole a URL do repo.
3. Após clonar: `flutter pub get` → **Run**.

---

## 🌿 Fluxo de Git (para evitar conflitos)

### Padrão de branches

* **main** → Produção/estável (protegido).
* **feature/** → novas funcionalidades.
* **fix/** → correções de bug.
* **refactor/** → melhorias sem mudar comportamento.
* **chore/** → ajustes de build, scripts, configs.
* **docs/** → documentação.

**Convenção de nomes (kebab-case):**

```
feature/hinos-busca-por-numero
fix/eventos-filtro-mes
refactor/churchscreen-lista-intendencias
```

### Ciclo de trabalho recomendado

1. **Atualize sua cópia local do `main`:**

   ```bash
   git checkout main
   git pull --rebase origin main
   ```

2. **Crie seu branch a partir do `main`:**

   ```bash
   git checkout -b feature/nome-da-tarefa
   ```

3. **Trabalhe e faça commits pequenos:**

   ```bash
   git add .
   git commit -m "feat(events): lista com calendário mensal"
   ```

4. **Sincronize periodicamente (evita conflitos grandes):**

   ```bash
   git fetch origin
   git rebase origin/main
   # Se houver conflitos, resolva-os, depois:
   git add .
   git rebase --continue
   ```

5. **Publique seu branch remoto:**

   ```bash
   git push -u origin feature/nome-da-tarefa
   ```

6. **Abra um Pull Request (PR) para `main` no GitHub.**

    * Marque um revisor.
    * Aguarde aprovação e merge.

> **Nunca** desenvolva direto no `main`. Use sempre branches de feature/fix.

---

## 📝 Mensagens de commit (Conventional Commits)

Use prefixos padronizados:

* `feat:` nova funcionalidade
* `fix:` correção de bug
* `docs:` documentação
* `style:` formatação (sem lógica)
* `refactor:` refatoração
* `perf:` desempenho
* `test:` testes
* `chore:` tarefas de build/infra

**Exemplos:**

```
feat(events): calendário por mês e marcador de dias
fix(hinos): ordenar por número na busca
chore(ci): ajusta cache do pub no pipeline
```

---

## 🔀 Como atualizar seu branch com o `main` (sem criar merge commits)

No seu branch (ex.: `feature/hinos-busca-por-numero`):

```bash
git fetch origin
git rebase origin/main
# resolver conflitos (se houver)
git add <arquivos_resolvidos>
git rebase --continue
git push --force-with-lease
```

> Use `--force-with-lease` (e não `--force`) para evitar sobrescrever trabalho alheio.

---

## 🧩 Resolvendo conflitos (passo a passo)

1. O Git vai marcar arquivos com conflitos (`<<<<<<<`, `=======`, `>>>>>>>`).
2. Edite os arquivos e escolha o conteúdo correto.
3. Marque como resolvido:

   ```bash
   git add <arquivo>
   ```
4. Continue o rebase:

   ```bash
   git rebase --continue
   ```
5. Se quiser abortar o rebase:

   ```bash
   git rebase --abort
   ```

---

## 🔧 Dicas para Windows (CRLF)

Se aparecer aviso de **CRLF/LF**, rode:

```bash
git config core.autocrlf true
```

Isso ajuda a normalizar finais de linha.

---

## 📁 Estrutura (resumo)

```
lib/
  admin/
    AdminPanelScreen.dart
    ...
  constantes/
    constants.dart
  widgets/
    detalhes_hino_screen.dart
  firebase_service/
    firebase_auth.dart
  firebase_options.dart        # (gerado pelo flutterfire)
android/
  app/google-services.json     # (não versionado)
ios/
  Runner/GoogleService-Info.plist  # (não versionado)
```

---

## 🧪 Rodando testes (se aplicável)

```bash
flutter test
```

---

## ✅ Checklist para abrir PR

* [ ] Branch criado a partir do `main` atualizado.
* [ ] Build local OK (`flutter pub get` + `flutter analyze`).
* [ ] Mensagens de commit padronizadas.
* [ ] Descrição clara do que foi feito.
* [ ] Sem arquivos secretos (JSON/PLIST) no commit.

---

## ❓ Suporte rápido

* **Atualizar remoto da sua máquina:**

  ```bash
  git remote -v
  ```
* **Trocar URL remota (se necessário):**

  ```bash
  git remote set-url origin https://github.com/Aguinald350/hpcdigital-app.git
  ```

---

---

## 📋 Status do Projeto (HPC Digital)

### ✅ Já implementado

- **Estrutura inicial Flutter + Firebase**  
  - Integração `firebase_options.dart` (via FlutterFire CLI).
  - Configurações Android/iOS previstas no README.
  - `.gitignore` adequado.

- **Git/GitHub — Fluxo com branches separados**  
  - Branch padrão `main`.
  - Convenções de nome para branches (`feature/`, `fix/`, etc.).
  - Guia de rebase/merge e PRs.

- **Hinos (Português)**
  - Tela com **busca por número/título**.
  - **Agrupamento por seção oficial**.
  - **Ordenação numérica correta** dentro de cada seção.
  - Tela de **detalhes do hino**.
  - Telas de **admin**: cadastrar/editar hino.

- **Eventos**
  - Tela pública com **abas por categoria** + **calendário mensal** (TableCalendar).
  - Marcadores em dias com evento e **lista filtrável por dia/mês**.
  - Admin:
    - **EventosScreenAdmin** com calendário e lista por mês.
    - **EditarEventoScreen** separada (CRUD completo).
    - Ações rápidas (editar/apagar) via menu.
  - Ajustes para **evitar índices compostos** obrigatórios (filtrar categoria no cliente quando necessário).

- **Admin Panel**
  - Menus: **Cadastrar Hino**, **Ver Hinos**, **Eventos (cadastrar/gerir)**, **Minha Igreja**.
  - **Minha Igreja (Admin)**:
    - **Cadastrar Distrito** (nome).
    - **Cadastrar Intendência** (nome + dropdown de distrito).
    - **Cadastrar Igreja**:
      - Nome da igreja.
      - Nº de pastores → campos dinâmicos para **nomes** e **contactos**.
      - **Secretário** (nome + contacto).
      - **Dropdown de Intendência** (preenche distrito automaticamente).
      - **Localização** (campo para URL do Google Maps ou geolocalização futura).
  - **constants.dart**: fonte de verdade para listas (classes/eventos/status), evitando mismatch de dropdown.

- **Minha Igreja (Usuário) — Navegação hierárquica**
  - **Busca** por nome da igreja/ intendência.
  - Lista **alfabética de distritos** → ao clicar, carrega **intendências** → ao clicar, carrega **igrejas**.
  - Card da igreja com **nome, distrito, intendência, pastores + contactos, secretário + contacto** e área reservada para **mapa** (link/preview).

- **Regras Firestore (esqueleto)**
  - Collections: `hinos`, `usuarios`, `eventos`, `distritos`, `intendencias`, `igrejas`.
  - Função `isAdmin()` e `isSignedIn()` (sugeridas) para gates de segurança.
  - Observação sobre necessidade de **documento de usuário** com `role: "admin"`.

- **Índices Firestore**
  - Documentação/orientação para lidar com mensagens do console e **criar índices compostos** quando necessário.
  - Alternativa implementada: **consultas por data** + filtro por categoria **no cliente** (evita índice composto).

---

### 🚧 Em andamento / A fazer

- **Firestore Rules (endurecer e validar)**  
  - Implementar `function isSignedIn()`.  
  - Garantir `usuarios/{uid}` com `role: "admin"` para quem precisa.  
  - Validar schemas (ex.: tipos de campos, datas, minimo/máximo de pastores) em `allow create/update` com `request.resource.data`.

- **Índices Compostos**  
  - Criar os que forem realmente necessários (usar links que aparecem no log do app).  
  - Revisar consultas que fazem `where(...) + orderBy(...)` em campos diferentes.

- **Minha Igreja (Usuário) — Mapa**
  - **Embed visual** do mapa (ex.: `google_maps_flutter`) ou preview confiável do link do Maps.  
  - Permissões de localização (se necessário para recursos futuros).  
  - Tratamento de links do Maps e validação de URLs.

- **Validações de formulário**
  - Máscaras de telefone (ex.: `flutter_multi_formatter` ou `mask_text_input_formatter`).  
  - Normalização e validação de links (Maps).  
  - Limites de comprimento e mensagens de erro mais amigáveis.

- **UX/Performance**
  - **Paginação**/limites em listas grandes (ex.: hinos/eventos).  
  - **Caching**/offline (Firestore `persistenceEnabled`).  
  - **Shimmer/skeletons** durante carregamento.

- **I18N / Locales**
  - Garantir `initializeDateFormatting('pt_BR')` corretamente.  
  - Traduzir strings estáticas via `intl`/`flutter_localizations`.

- **Autenticação e papéis**
  - Fluxo de login (Firebase Auth).  
  - Tela/guarda para rotas **admin only**.  
  - Onboarding simples para novos admins (criar doc `usuarios/{uid}`).

- **Notificações (opcional)**
  - Push (Firebase Cloud Messaging) para lembretes de eventos.

- **Qualidade**
  - `flutter analyze`, `dart fix --apply`.  
  - Tests de UI/Widget para casos críticos.  
  - Lints (`analysis_options.yaml`) mais estritos.

- **CI/CD (futuro)**
  - GitHub Actions para build/test.  
  - Play Console (release) e configurações de assinatura.  
  - Variáveis de ambiente/Secrets para chaves sensíveis.

- **Backups & Migrações**
  - Exportar coleções Firestore periodicamente.  
  - Padronizar migrações de schema (scripts ou docs).

---

### 📌 Decisões anotadas

- **Eventos:**
  - Para evitar índices compostos, consultas por mês usam **apenas `data`**; filtro de `classe` é feito no cliente.  
  - A aba **“Todos”** lista todas as classes daquele mês (e exibe a classe no card).

- **Hinos:**
  - Ordenação por `numero` é **numérica** (convertendo string→int quando preciso).  
  - Na busca, mostra **título do hino** diretamente (mais prático).

- **Arquitetura do Admin:**
  - **Editar Evento** em tela separada (`EditarEventoScreen`) para organização e reuso.  
  - **constants.dart** concentra listas (classes/status), evitando inconsistências com dropdowns.

---

### 🗂️ Estrutura de coleções (resumo)

- `hinos` `{numero:int|string, titulo, secao, lingua, ...}`
- `eventos` `{nome, descricao, data:Timestamp, classe, status, criadoEm}`
- `usuarios` `{role:"admin"|"...", ...}`
- `distritos` `{nome}`
- `intendencias` `{nome, distritoId, distritoNome}`
- `igrejas` `{nome, intendenciaId, intendenciaNome, distritoId, distritoNome, pastores:[{nome, contacto}], secretario:{nome, contacto}, localizacaoUrl}`

---

### 📣 Como o time deve trabalhar (resumo)

1. **Atualize a main** (`git pull origin main`).  
2. **Crie sua branch** (`feature/...`), trabalhe com commits pequenos.  
3. **Rebase periódico** com `origin/main` para reduzir conflitos.  
4. **Abra PR** → revisão do colega → merge.  
5. **Nunca** desenvolva direto em `main`.




