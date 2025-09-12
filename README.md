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


