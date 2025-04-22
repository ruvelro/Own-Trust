#!/bin/bash

### ───── CONFIGURACIÓN PERSONAL ───── ###
DOMAIN="midominio.xyz"  # Tu dominio principal
CERT_DIR="/Docker/traefik/certs"  # Carpeta donde se instalarán los certificados
CF_Token="clave_del_token"  # Token de Cloudflare API
EMAIL="miemail@gmail.com"  # Correo para registro en Let's Encrypt

### ───── PASOS NECESARIOS ───── ###

# 1. Instalar acme.sh si no está instalado
if [ ! -d "$HOME/.acme.sh" ]; then
  echo "🔧 Instalando acme.sh..."
  curl https://get.acme.sh | sh
  source ~/.bashrc  # o ~/.profile si no funciona
fi

# 2. Exportar la variable de entorno necesaria para el DNS de Cloudflare
export CF_Token="$CF_Token"

# 3. Establecer Let's Encrypt como proveedor CA (opcional si ya lo usas)
"$HOME/.acme.sh/acme.sh" --set-default-ca --server letsencrypt

# 4. Registrar cuenta (si no lo has hecho ya)
"$HOME/.acme.sh/acme.sh" --register-account -m "$EMAIL" --server letsencrypt

# 5. Emitir el certificado wildcard
"$HOME/.acme.sh/acme.sh" --issue --dns dns_cf -d "$DOMAIN" -d "*.$DOMAIN" --keylength ec-384

# 6. Verificar que el certificado se generó correctamente
if [ ! -f "$HOME/.acme.sh/${DOMAIN}_ecc/${DOMAIN}.cer" ]; then
  echo "❌ Error: No se ha podido emitir el certificado wildcard."
  exit 1
fi

# 7. Crear carpeta destino si no existe
mkdir -p "$CERT_DIR"

# 8. Copiar los certificados a la carpeta correspondiente
cp "$HOME/.acme.sh/${DOMAIN}_ecc/fullchain.cer" "$CERT_DIR/wildcard.crt"
cp "$HOME/.acme.sh/${DOMAIN}_ecc/${DOMAIN}.key" "$CERT_DIR/wildcard.key"

echo "✅ Certificado wildcard instalado correctamente en: $CERT_DIR"
