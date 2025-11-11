// paths used
const APK_URL = "/HPCMobile_v1.0.apk";
const SUPPORT_WHATS = "https://wa.me/244925780193?text=Olá%20HPC%20Support%2C%20preciso%20de%20ajuda%20com%20a%20instalação";

// util: show toast
function showToast(msg, timeout = 3000) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  t.setAttribute('aria-hidden', 'false');
  clearTimeout(t._timer);
  t._timer = setTimeout(() => {
    t.classList.remove('show');
    t.setAttribute('aria-hidden', 'true');
  }, timeout);
}

// copy link to clipboard
async function copyLink() {
  try {
    await navigator.clipboard.writeText(location.origin + APK_URL);
    showToast('Link copiado para a área de transferência');
  } catch (e) {
    // fallback
    const ta = document.createElement('textarea');
    ta.value = location.origin + APK_URL;
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
    showToast('Link copiado (fallback)');
  }
}

document.addEventListener('DOMContentLoaded', () => {
  // buttons
  const copyBtns = [document.getElementById('copy-link'), document.getElementById('btn-copy-link-2')];
  copyBtns.forEach(b => { if (b) b.addEventListener('click', copyLink); });

  const support = document.getElementById('btn-support');
  if (support) support.addEventListener('click', () => { window.open(SUPPORT_WHATS, '_blank'); });

  // explicit header download link - ensure href
  const dlHeader = document.getElementById('download-link-header');
  if (dlHeader) dlHeader.href = APK_URL;

  const dlBtns = [document.getElementById('download-btn'), document.getElementById('download-btn-2')];
  dlBtns.forEach(d => { if (d) d.href = APK_URL; });

  // small UX: if user is on desktop, show a hint on QR click
  const qr = document.querySelector('.qr-image');
  if (qr) {
    qr.addEventListener('click', () => {
      if (navigator.userAgent.match(/Android|iPhone|iPad|iPod/i) == null) {
        showToast('Abra a câmara do telemóvel e escaneie o QR para baixar');
      }
    });
  }
});
