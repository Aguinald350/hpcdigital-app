#!/usr/bin/env python3
"""
Gera um QR PNG com um logo central (bom para landing page offline/server-side).
Saída: release_site/images/qrcodeimage.png

Requisitos:
  pip install pillow qrcode

Uso:
  python generate_qr_with_logo.py

Ajusta DOWNLOAD_URL e LOGO_PATH abaixo se necessário.
"""
import os
from PIL import Image, ImageDraw
import qrcode

# === CONFIGURAÇÃO ===
DOWNLOAD_URL = "https://hpcmobile-9ec3e.web.app/HPCMobile_v1.0.apk"
# caminho do logo (usa a imagem que enviaste). Ajusta se for outro caminho.
LOGO_PATH = "images/icon.png"  # coloca aqui o teu logo (ex: images/icon.png)
# Output
OUTPUT_DIR = "release_site/images"
OUTPUT_FILENAME = "qrcodeimage.png"
OUTPUT_PATH = os.path.join(OUTPUT_DIR, OUTPUT_FILENAME)
# Tamanho final do QR (px) — podes ajustar
QR_SIZE = 1000

# === FUNÇÕES ===
def ensure_dirs():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_qr(url, qr_size=QR_SIZE):
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_H,  # H = 30% redundância
        box_size=10,
        border=4,
    )
    qr.add_data(url)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white").convert("RGBA")
    # redimensiona para dimensão exata mantendo proporção
    img = img.resize((qr_size, qr_size), Image.LANCZOS)
    return img

def build_logo_overlay(logo_path, qr_img):
    logo = Image.open(logo_path).convert("RGBA")

    qr_w, qr_h = qr_img.size
    # logo ocupa ~22% da largura do QR (ajusta se quiseres maior/menor)
    logo_max = int(qr_w * 0.22)
    logo.thumbnail((logo_max, logo_max), Image.LANCZOS)

    # Cria background branco arredondado (para contraste)
    pad = int(min(logo.size) * 0.25)  # padding em px
    bg_w = logo.size[0] + pad
    bg_h = logo.size[1] + pad
    bg = Image.new("RGBA", (bg_w, bg_h), (255,255,255,255))

    # Máscara para arredondar o fundo
    mask = Image.new("L", (bg_w, bg_h), 0)
    draw = ImageDraw.Draw(mask)
    radius = int(min(bg_w, bg_h) / 6)
    draw.rounded_rectangle([0,0,bg_w-1,bg_h-1], radius=radius, fill=255)
    bg.putalpha(mask)

    # Posições centrais
    pos_bg = ((qr_w - bg_w)//2, (qr_h - bg_h)//2)
    pos_logo = ((qr_w - logo.size[0])//2, (qr_h - logo.size[1])//2)

    return bg, pos_bg, logo, pos_logo

def save_final(qr_img, bg, pos_bg, logo, pos_logo, out_path):
    qr_img.paste(bg, pos_bg, bg)
    qr_img.paste(logo, pos_logo, logo)
    qr_img.save(out_path)
    print(f"QR saved to: {out_path}")

# === MAIN ===
def main():
    ensure_dirs()
    if not os.path.isfile(LOGO_PATH):
        print(f"ERROR: logo not found at '{LOGO_PATH}'. Coloca o ficheiro e tenta novamente.")
        return
    qr = generate_qr(DOWNLOAD_URL)
    bg, pos_bg, logo, pos_logo = build_logo_overlay(LOGO_PATH, qr)
    save_final(qr, bg, pos_bg, logo, pos_logo, OUTPUT_PATH)

if __name__ == "__main__":
    main()
