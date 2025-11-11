// functions/index.js
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

function readLegacyConfig() {
  try {
    const v1 = require('firebase-functions');
    return v1.config ? v1.config() : {};
  } catch {
    return {};
  }
}

const SUPPORT_WHATS = '+244 925 780 193';

exports.onActivationRequestCreated = onDocumentCreated(
  // 👇 FIX AQUI: use a mesma região do seu Firestore
  { region: 'africa-south1' }, // se seu Firestore estiver em africa-south1
  'activation_requests/{reqId}',
  async (event) => {
    const snap = event.data;
    if (!snap) {
      logger.warn('Snapshot vazio.');
      return;
    }

    const data = snap.data() || {};
    const params = event.params || {};
    const to = data.email;
    const nome = data.nome || 'usuário';
    const uid = data.uid || '';
    const tel = data.telefone || '';
    const tipo = data.tipoAtual || {};

    const cfg = readLegacyConfig();
    const SENDGRID_KEY =
      process.env.SENDGRID_API_KEY || (cfg.sendgrid && cfg.sendgrid.key);
    const MAIL_FROM =
      process.env.MAIL_FROM || (cfg.notify && cfg.notify.from) || 'HPC Digital <hpcdigitalapp@gmail.com>';
    const MAIL_REPLY =
      process.env.MAIL_REPLY || (cfg.notify && cfg.notify.replyto) || MAIL_FROM;
    const MAIL_CC = process.env.MAIL_CC || (cfg.notify && cfg.notify.cc);

    if (!SENDGRID_KEY) {
      logger.error('SENDGRID KEY ausente.');
      return;
    }

    sgMail.setApiKey(SENDGRID_KEY);

    const htmlUser = `
      <div style="font-family:Arial,Helvetica,sans-serif;line-height:1.5;">
        <h2>Ativação da sua conta — HPC Digital</h2>
        <p>Olá <strong>${nome}</strong>,</p>
        <p>Fale com nosso suporte no WhatsApp:</p>
        <p style="font-size:18px;margin:12px 0;">
          <strong>WhatsApp:</strong> <a href="https://wa.me/244925780193" target="_blank">${SUPPORT_WHATS}</a>
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
      subject: 'HPC Digital — Instruções para ativação',
      html: htmlUser,
    };

    const htmlAdmin = `
      <div style="font-family:Arial,Helvetica,sans-serif;line-height:1.5;">
        <h3>Novo pedido de ativação</h3>
        <ul>
          <li><b>Nome:</b> ${nome}</li>
          <li><b>Email:</b> ${to}</li>
          <li><b>Telefone:</b> ${tel}</li>
          <li><b>UID:</b> ${uid}</li>
          <li><b>Plano:</b> ${tipo.label || '-'} (${tipo.descricao || '-'})
              | trial=${!!tipo.isTrial} | dias=${tipo.diasRestantes ?? '-'}</li>
          <li><b>DocID:</b> ${params.reqId}</li>
        </ul>
      </div>
    `;

    const payloads = [msgUser];
    if (MAIL_CC) {
      payloads.push({
        to: MAIL_CC,
        from: MAIL_FROM,
        replyTo: MAIL_REPLY,
        subject: 'Novo pedido de ativação — HPC Digital',
        html: htmlAdmin,
      });
    }

    try {
      await sgMail.send(payloads);
      logger.info('E-mail(s) enviados com sucesso', { to, cc: MAIL_CC || null });
    } catch (err) {
      logger.error('Falha ao enviar e-mail', { error: err?.message, to });
    }
  }
);
