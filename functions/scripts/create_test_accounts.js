/**
 * create_test_accounts.js
 * Cria contas de teste com expiração de 15 dias (admin + usuário padrão)
 *
 * EXECUÇÃO (PowerShell):
 * $env:GOOGLE_APPLICATION_CREDENTIALS="C:\Users\DELL\hpcdigital\functions\serviceAccount.json"
 * node create_test_accounts.js
 */

const path = require("path");
const admin = require("firebase-admin");

// -------- CONFIGURAÇÃO EXPLÍCITA (SEM ADIVINHAÇÃO) --------
admin.initializeApp({
  credential: admin.credential.cert(
    require(path.resolve(__dirname, "../serviceAccount.json"))
  ),
  projectId: "hpcmobile-9ec3e", // 🔴 FORÇADO
});

const db = admin.firestore();

// ------------ DATA DE EXPIRAÇÃO (+15 dias) ----------------
const expiresAt = new Date(Date.now() + 15 * 24 * 60 * 60 * 1000);

// ------------ CONTAS DE TESTE ------------------------------
const accounts = [
  {
    email: "review_admin@hpcdemo.com",
    password: "HpcDemo!2025",
    displayName: "Review Admin",
    role: "admin",
  },
  {
    email: "review_user@hpcdemo.com",
    password: "HpcUser!2025",
    displayName: "Review User",
    role: "user",
  },
];

// ------------ FUNÇÃO PRINCIPAL ------------------------------
async function createTestAccount({ email, password, displayName, role }) {
  try {
    console.log(`\n➡ Criando conta: ${email}`);

    // 1️⃣ Authentication
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName,
      emailVerified: true,
      disabled: false,
    });

    console.log(`✔ Auth criado | UID: ${userRecord.uid}`);

    // 2️⃣ Firestore (/usuarios/{uid})
    await db.collection("usuarios").doc(userRecord.uid).set({
      uid: userRecord.uid,
      email,
      nome: displayName,
      role,
      isTestAccount: true,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
    });

    console.log(`✔ Firestore criado`);
    console.log(`⏳ Expira em: ${expiresAt.toISOString()}`);

  } catch (err) {
    if (err.code === "auth/email-already-exists") {
      console.warn(`⚠ Conta já existe: ${email}`);
    } else {
      console.error(`❌ Erro ao criar ${email}:`, err.message || err);
    }
  }
}

// ------------ EXECUÇÃO -------------------------------------
(async () => {
  console.log("=== CRIAÇÃO DE CONTAS DE TESTE (15 DIAS) ===");

  for (const acc of accounts) {
    await createTestAccount(acc);
  }

  console.log("\n=== FINALIZADO ===");
})();
