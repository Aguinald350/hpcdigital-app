// index.js (COMPLETO) - add generateVerificationLink v2 https
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { https: httpsV2 } = require("firebase-functions/v2");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions"); // legacy helper (functions.config())
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

admin.initializeApp();

// leitura de config legado (compatibilidade)
function readLegacyConfig() {
  try {
    const cfg = functions.config ? functions.config() : {};
    return cfg || {};
  } catch (e) {
    return {};
  }
}

const cfg = readLegacyConfig();
const SUPPORT_WHATS = "+244925780193";
const SENDGRID_KEY =
  process.env.SENDGRID_API_KEY ||
  (cfg.sendgrid && cfg.sendgrid.key) ||
  "";

if (SENDGRID_KEY) {
  sgMail.setApiKey(SENDGRID_KEY);
} else {
  logger.warn("SENDGRID API KEY não encontrada em env/processo ou functions.config()");
}

/**
 * onActivationRequestCreated (v2 Firestore trigger)
 */
exports.onActivationRequestCreated = onDocumentCreated(
  { region: "africa-south1" },
  "activation_requests/{reqId}",
  async (event) => {
    try {
      const snap = event.data;
      if (!snap) {
        logger.warn("Snapshot vazio em onActivationRequestCreated.");
        return;
      }

      const data = snap.data() || {};
      const params = event.params || {};
      const to = data.email;
      const nome = data.nome || "usuário";
      const uid = data.uid || "";
      const tel = data.telefone || "";
      const tipo = data.tipoAtual || {};

      const MAIL_FROM =
        process.env.MAIL_FROM || (cfg.notify && cfg.notify.from) || "HPC Digital <hpcdigitalapp@gmail.com>";
      const MAIL_REPLY = process.env.MAIL_REPLY || (cfg.notify && cfg.notify.replyto) || MAIL_FROM;
      const MAIL_CC = process.env.MAIL_CC || (cfg.notify && cfg.notify.cc);

      if (!SENDGRID_KEY) {
        logger.error("SENDGRID KEY ausente — não será enviado e-mail ao usuário.");
        return;
      }

      const htmlUser = `
        <div style="font-family:Arial,Helvetica,sans-serif;line-height:1.5;">
          <h2>Ativação da sua conta — HPC Digital</h2>
          <p>Olá <strong>${nome}</strong>,</p>
          <p>Fale com nosso suporte no WhatsApp:</p>
          <p style="font-size:18px;margin:12px 0;">
            <strong>WhatsApp:</strong> <a href="https://wa.me/${SUPPORT_WHATS}" target="_blank">${SUPPORT_WHATS}</a>
          </p>
          <p>Envie esta mensagem (copiar/colar):</p>
          <pre style="background:#f6f8fa;padding:12px;border-radius:8px;white-space:pre-wrap;">
Saudações 👋
Quero ativar/renovar minha conta.
— Nome: ${nome}
— Email: ${to}
— UID: ${uid}
— Telefone: ${tel || '-'}
— Plano atual: ${tipo.label || '-'} (${tipo.descricao || '-'})
          </pre>
          <p>Se você não fez este pedido, ignore este e-mail.</p>
        </div>
      `;

      const msgUser = {
        to,
        from: MAIL_FROM,
        replyTo: MAIL_REPLY,
        subject: "HPC Digital — Instruções para ativação",
        html: htmlUser,
      };

      const payloads = [msgUser];

      if (MAIL_CC) {
        payloads.push({
          to: MAIL_CC,
          from: MAIL_FROM,
          replyTo: MAIL_REPLY,
          subject: "Novo pedido de ativação — HPC Digital",
          html: `
            <div style="font-family:Arial,Helvetica,sans-serif;">
              <h3>Novo pedido de ativação</h3>
              <ul>
                <li><b>Nome:</b> ${nome}</li>
                <li><b>Email:</b> ${to}</li>
                <li><b>Telefone:</b> ${tel}</li>
                <li><b>UID:</b> ${uid}</li>
                <li><b>Plano:</b> ${tipo.label || '-'}</li>
                <li><b>DocID:</b> ${params.reqId}</li>
              </ul>
            </div>
          `,
        });
      }

      // envia todos (SendGrid aceita array)
      await sgMail.send(payloads);
      logger.info("E-mail(s) enviados com sucesso", { to, cc: MAIL_CC || null });
    } catch (err) {
      logger.error("Falha em onActivationRequestCreated:", err);
    }
  }
);

/**
 * incrementDownload (v2 https)
 */
exports.incrementDownload = httpsV2.onRequest(
  { region: "africa-south1", cors: true },
  async (req, res) => {
    try {
      const db = admin.firestore();
      const ref = db.collection("metrics").doc("downloads");

      const result = await db.runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (!snap.exists) {
          tx.set(ref, { count: 1 });
          return { count: 1 };
        } else {
          const cur = (snap.data().count || 0);
          const next = cur + 1;
          tx.update(ref, { count: next });
          return { count: next };
        }
      });

      res.set("Access-Control-Allow-Origin", "*");
      res.json({ success: true, count: result.count });
    } catch (err) {
      logger.error("incrementDownload error:", err);
      res.status(500).json({ success: false, error: err.message || String(err) });
    }
  }
);

/**
 * helper: valida se decoded uid tem role 'admin' no Firestore
 */
async function checkFirestoreIsAdmin(uid) {
  if (!uid) return false;
  try {
    const doc = await admin.firestore().collection('usuarios').doc(uid).get();
    if (!doc.exists) return false;
    const data = doc.data() || {};
    const role = (data.role || '').toString().toLowerCase();
    return role === 'admin';
  } catch (err) {
    logger.error('checkFirestoreIsAdmin error:', err);
    return false;
  }
}

/**
 * adminMarkVerified (v2 https - sem App Engine)
 * Protegido via Firebase ID token + role admin no Firestore (usuarios/{uid}.role === 'admin').
 */
exports.adminMarkVerified = httpsV2.onRequest(
  { region: "africa-south1", cors: true },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        return res.status(405).json({ error: "Method not allowed. Use POST." });
      }

      const authHeader = req.get("Authorization") || req.get("authorization");
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ error: "Missing Authorization Bearer token." });
      }
      const idToken = authHeader.split(" ")[1];

      let decoded;
      try {
        decoded = await admin.auth().verifyIdToken(idToken);
      } catch (err) {
        console.error("verifyIdToken failed:", err);
        return res.status(401).json({ error: "Invalid or expired token." });
      }

      // verifica role no Firestore (aceita admins definidos em /usuarios/{uid}.role)
      const isAdmin = await checkFirestoreIsAdmin(decoded.uid);
      if (!isAdmin) {
        return res.status(403).json({ error: "User is not admin (firestore role)." });
      }

      const uid = req.body && req.body.uid;
      if (!uid || typeof uid !== "string") {
        return res.status(400).json({ error: "Missing uid in body." });
      }

      await admin.auth().updateUser(uid, { emailVerified: true });

      await admin.firestore().collection("admin_actions").add({
        action: "adminMarkVerified",
        uid,
        adminUid: decoded.uid,
        ip: req.ip || null,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      return res.json({ success: true });
    } catch (err) {
      console.error("adminMarkVerified error:", err);
      return res.status(500).json({ error: "Internal error." });
    }
  }
);

/**
 * generateVerificationLink
 * - POST { email: string }
 * - Header: Authorization: Bearer <adminIdToken>
 * - Retorna: { success:true, link: "https://..." } ou { success:false, error: "..." }
 *
 * Nota: verificação de admin feita via documento Firestore usuarios/{decoded.uid}.role === 'admin'
 */
// generateVerificationLink (v2 https) - permite admin via custom claim OU role no Firestore
exports.generateVerificationLink = httpsV2.onRequest(
  { region: "africa-south1", cors: true },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        return res.status(405).json({ success: false, error: "Method not allowed. Use POST." });
      }

      const authHeader = req.get("Authorization") || req.get("authorization");
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ success: false, error: "Missing Authorization Bearer token." });
      }
      const idToken = authHeader.split(" ")[1];

      let decoded;
      try {
        decoded = await admin.auth().verifyIdToken(idToken);
      } catch (err) {
        console.error("verifyIdToken failed:", err);
        return res.status(401).json({ success: false, error: "Invalid or expired token." });
      }

      // primeiro check rápido por custom claim
      let isAdminByClaim = !!decoded.admin;

      // se não tiver claim, tenta validar no Firestore (campo usuarios/{uid}.role === 'admin')
      let isAdminByFirestore = false;
      if (!isAdminByClaim) {
        try {
          const uDoc = await admin.firestore().collection("usuarios").doc(decoded.uid).get();
          if (uDoc.exists) {
            const role = (uDoc.data() && uDoc.data().role) ? String(uDoc.data().role).toLowerCase() : "";
            if (role === "admin") isAdminByFirestore = true;
          } else {
            console.warn("usuarios doc not found for uid:", decoded.uid);
          }
        } catch (err) {
          console.error("Erro ao ler usuarios doc:", err);
          // não falhar ainda — continuamos com isAdminByClaim (se fosse true)
        }
      }

      if (!isAdminByClaim && !isAdminByFirestore) {
        return res.status(403).json({ success: false, error: "User is not admin." });
      }

      const email = req.body && req.body.email;
      if (!email || typeof email !== "string") {
        return res.status(400).json({ success: false, error: "Missing email in body." });
      }

      // ActionCodeSettings -> onde o usuário será redirecionado após clicar no link.
      const actionCodeSettings = {
        url: process.env.EMAIL_ACTION_RETURN_URL || "https://hpcmobile-9ec3e.firebaseapp.com/finishVerify",
        handleCodeInApp: false,
      };

      // gerar link
      let link;
      try {
        link = await admin.auth().generateEmailVerificationLink(email, actionCodeSettings);
      } catch (err) {
        console.error("generateEmailVerificationLink failed:", err);
        return res.status(500).json({ success: false, error: "Failed to generate verification link.", detail: (err.message || String(err)) });
      }

      // grava log administrável
      try {
        await admin.firestore().collection("admin_actions").add({
          action: "generate_verification_link",
          email,
          requestedBy: decoded.uid,
          byClaim: isAdminByClaim,
          byFirestoreRole: isAdminByFirestore,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (logErr) {
        console.warn("Could not write admin_actions log:", logErr);
      }

      // retorna link (não envia email automaticamente aqui)
      return res.json({ success: true, link });
    } catch (err) {
      console.error("generateVerificationLink error (fatal):", err);
      return res.status(500).json({ success: false, error: "Internal error.", detail: (err.message || String(err)) });
    }
  }
);

/**
 * cleanupExpiredTestAccounts
 * - Roda diariamente
 * - Desativa contas de teste expiradas
 */
exports.cleanupExpiredTestAccounts = httpsV2.onRequest(
  { region: "africa-south1" },
  async (req, res) => {
    try {
      const now = new Date();
      const snap = await admin.firestore()
        .collection("usuarios")
        .where("isTestAccount", "==", true)
        .where("expiresAt", "<", now)
        .where("status", "==", "active")
        .get();

      let processed = 0;

      for (const doc of snap.docs) {
        const uid = doc.id;

        try {
          // desativa no Auth
          await admin.auth().updateUser(uid, { disabled: true });

          // marca no Firestore
          await doc.ref.update({
            status: "expired",
            expiredAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          processed++;
        } catch (err) {
          logger.error(`Erro ao expirar ${uid}`, err);
        }
      }

      return res.json({
        success: true,
        expiredAccounts: processed,
      });
    } catch (err) {
      logger.error("cleanupExpiredTestAccounts error", err);
      return res.status(500).json({ error: "internal error" });
    }
  }
);
