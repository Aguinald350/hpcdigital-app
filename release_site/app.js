// app.js (module)
const { db, doc, getDoc, onSnapshot, runTransaction, setDoc } = window.__HPC_FIREBASE || {};

const APK_PATH = '/HPCMobile_v1.0.apk';
const PHONE_SUPPORT = '244925780193';

const toast = document.getElementById('toast');
const downloadCountEl = document.getElementById('download-count');
const downloadBtn = document.getElementById('download-btn');
const downloadBtn2 = document.getElementById('download-btn-2');
const copyBtns = Array.from(document.querySelectorAll('#copy-link, #btn-copy-link-2'));
const btnSupport = document.getElementById('btn-support');
const themeToggle = document.getElementById('theme-toggle');
const subscribeBtns = Array.from(document.querySelectorAll('.js-subscribe'));

function showToast(text, ms = 2200) {
  if (!toast) return;
  toast.textContent = text;
  toast.style.display = 'block';
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => { toast.style.display = 'none'; }, ms);
}

/* THEME: carregar preferência e toggle */
(function themeInit(){
  const saved = localStorage.getItem('hpc_theme');
  if (saved === 'light') document.body.classList.add('light');
  else document.body.classList.remove('light');

  themeToggle?.addEventListener('click', () => {
    document.body.classList.toggle('light');
    const mode = document.body.classList.contains('light') ? 'light' : 'dark';
    localStorage.setItem('hpc_theme', mode);
    showToast(mode === 'light' ? 'Modo claro' : 'Modo escuro');
  });
})();

/* WHATSAPP support */
btnSupport?.addEventListener('click', () => {
  const url = `https://wa.me/${PHONE_SUPPORT}?text=${encodeURIComponent('Olá HPC Support, preciso de ajuda.')}`;
  window.open(url, '_blank');
});

/* copy link */
copyBtns.forEach(b => b?.addEventListener('click', async (ev) => {
  ev.preventDefault();
  try {
    await navigator.clipboard.writeText(location.origin + APK_PATH);
    showToast('Link copiado');
  } catch (e) {
    showToast('Não foi possível copiar automaticamente');
  }
}));

/* subscribe (abre whatsapp com texto) */
subscribeBtns.forEach(btn => btn?.addEventListener('click', () => {
  const plan = btn.dataset.plan || 'monthly';
  const msg = plan === 'annual'
    ? 'Olá, quero pagar o plano anual promocional (10.000 Kz). Meu email: '
    : 'Olá, quero assinar (1.000 Kz/mês). Meu email: ';
  window.open(`https://wa.me/${PHONE_SUPPORT}?text=${encodeURIComponent(msg)}`, '_blank');
}));

/* DOWNLOAD COUNTER — duas opções: Cloud Function (recomendada) ou Firestore transação (rápida) */

/* -------- OPÇÃO RECOMENDADA: chamar Cloud Function HTTP que incrementa o contador atomically. --------
   (1) Deployar função HTTPS em /incrementDownload (exemplo mais abaixo)
   (2) Substituir INCREMENT_URL pela URL da função
*/
// const INCREMENT_URL = 'https://us-central1-YOUR_PROJECT.cloudfunctions.net/incrementDownload';
// async function incrementViaFunction() {
//   try {
//     const res = await fetch(INCREMENT_URL, { method: 'POST' });
//     if (!res.ok) throw new Error('HTTP ' + res.status);
//     const json = await res.json();
//     if (json && typeof json.count === 'number') downloadCountEl.textContent = json.count.toLocaleString();
//   } catch (e) {
//     console.error('incrementViaFunction failed', e);
//   }
// }

/* -------- OPÇÃO RÁPIDA: transação Firestore (client-side). Menos segura — testa já. -------- */
async function incrementFirestoreCounter() {
  if (!db) return;
  const counterRef = doc(db, 'metrics', 'downloads');
  try {
    await runTransaction(db, async (tx) => {
      const snap = await tx.get(counterRef);
      if (!snap.exists()) {
        tx.set(counterRef, { count: 1 });
        return 1;
      } else {
        const current = snap.data().count || 0;
        tx.update(counterRef, { count: current + 1 });
        return current + 1;
      }
    });
  } catch (e) {
    console.error('transaction failed', e);
  }
}

/* bind click to download to increment */
[downloadBtn, downloadBtn2].forEach(el => {
  el?.addEventListener('click', (ev) => {
    // permite download normal; incrementamos contador em background
    // Opcional: prevenir navegação para contar antes de saída (não recomendado)
    try {
      // escolha a opção: comentar uma delas conforme preferes
      // incrementViaFunction(); // se tiveres Cloud Function
      incrementFirestoreCounter(); // transação cliente
    } catch (e) {
      console.error(e);
    }
  });
});

/* show real-time count from Firestore */
if (db) {
  const counterDoc = doc(db, 'metrics', 'downloads');
  onSnapshot(counterDoc, (snap) => {
    if (!snap.exists()) {
      downloadCountEl.textContent = '0';
    } else {
      const c = snap.data().count || 0;
      downloadCountEl.textContent = Number(c).toLocaleString();
    }
  }, (err) => {
    console.error('snapshot error', err);
  });
} else {
  // sem firebase: tenta buscar via fetch a um endpoint (não incluído)
  downloadCountEl.textContent = '--';
}

/* small UX: show toast on successful copy */
document.querySelectorAll('a[download], button.btn-primary').forEach(btn => {
  btn.addEventListener('click', () => {
    showToast('Download iniciado — obrigado!');
  });
});
