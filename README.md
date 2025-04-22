# 🔐 Own Trust: Tu Infraestructura, Tus Reglas

**Own Trust** es una alternativa autoalojada a Cloudflare Zero Trust, diseñada para ofrecer **seguridad avanzada en redes y servicios personales**, sin depender de servicios en la nube de terceros.

Este proyecto nace como respuesta a los **bloqueos masivos** que el mafioso *Tebas*, *LaLiga* y los operadores de Internet están realizando semana tras semana contra los CDN, afectando especialmente a quienes, como yo, **no tienen el más mínimo interés en el fútbol**.

## 🚀 ¿Qué incluye Own Trust?

Own Trust integra dos herramientas clave para garantizar la seguridad y el control total de tu infraestructura:

### 🔁 Traefik como Proxy Inverso
- Gestiona el enrutamiento del tráfico y los certificados **SSL wildcard**.
- Integra múltiples _middlewares_ para **proteger la infraestructura** frente a ataques diversos.

### 🔐 Authelia como Sistema de Autenticación
- Proporciona una capa de autenticación **centralizada y global**.
- Soporta **reglas de acceso granulares** y autenticación multifactor (MFA).

---

## 💡 ¿Por qué Own Trust?

Own Trust nace con una idea muy clara:  
> Que "los cuatro frikis" podamos **recuperar el control total** de nuestra infraestructura,  
> evitando que la mafia de LaLiga te deje sin servicio cada fin de semana,  
> y todo ello **sin renunciar a las funciones de seguridad esenciales**.

---

¿Existen otros proyectos similares? Seguramente sí. Pero este ha sido configurado desde cero, y probado a fondo, con la idea de que cualquiera pueda montarlo, sin problemas, en su propio servidor. 

### ✅ PROTECCIONES QUE YA TIENES CUBIERTAS

| Protección Cloudflare          | ¿Cubierta? | ¿Cómo la tienes cubierta? |
|-------------------------------|------------|----------------------------|
| Access (Zero Trust)           | ✅          | Con **Authelia** (control de acceso basado en identidad) |
| Rate Limiting                 | ✅          | Con middleware `rate-limit` de **Traefik** |
| Modify Request Header         | ✅          | Puedes hacerlo con middleware `headers` en **Traefik** |
| Modify Response Header        | ✅          | También con `headers` o middleware personalizado |
| Secure Headers                | ✅          | Ya implementado como middleware `secure-headers` |
| Geo-blocking                  | ✅          | Middleware `geo-block` con Traefik, usando `remoteIP` o similar |
| Redirect Rules                | ✅          | Usando `middlewares.redirectRegex` o `redirectScheme` en Traefik |
| URL Rewrites                  | ✅          | Con middleware `replacePath` o `rewriteRegex` |
| Web Application Firewall (WAF) | ⚠️ Parcial | Traefik **no incluye un WAF** real, pero puedes mitigar algo con reglas personalizadas o combinar con un WAF externo |
| Compression Rules             | ⚠️ Parcial | Traefik permite habilitar compresión (gzip) pero no es tan granular como en Cloudflare |
| Page Rules / Cache Rules      | ❌          | Cloudflare gestiona el caché a nivel de edge, Traefik **no tiene caché HTTP integrado** |
| Bots Protection               | ❌          | No hay detección automática de bots. Puedes mitigar con heurísticas, CAPTCHA o servicios externos |
| DDoS Protection               | ⚠️ Parcial | Traefik no incluye protección contra DDoS real. Puedes reducir riesgo con rate limiting y geo-block |
| IP Access Rules               | ✅          | Con Traefik `remoteIP` middleware o reglas por red IP |
| Workers (funciones personalizadas) | ⚠️ Opcional | No hay un sistema equivalente, pero podrías usar middlewares externos, Lua, nginx, etc. |

### ⚠️ PROTECCIONES POR AÑADIR

Aunque la protección es bastante completa, en el futuro seguiré trabajando en algunas características. Por ejemplo, a corto plazo experimentaré con **sistemas de CAPTCHA** dentro de Authelia para protegerlo mejor de los ataques de fuerza bruta, y un sistema **fail2ban** para bloquear IPs que realicen fuerza bruta.


## 📋 Requisitos

Para desplegar **Own Trust** en tu entorno personal, necesitas cumplir con algunos requisitos básicos:

### 🌐 Dominio con Cloudflare
- Es necesario tener un dominio registrado y gestionado desde [Cloudflare](https://www.cloudflare.com/), o migrado a él.
- Se utiliza para gestionar los **registros DNS dinámicos**, así como para emitir los certificados SSL a través de la API de Cloudflare.
- También lo usaremos para actualizar el DDNS para que siempre apunte a nuestra IP.

### 🐳 Docker y Docker Compose
- Own Trust se despliega usando **contenedores Docker**, así que necesitarás tener instalado:
  - `docker`
  - `docker-compose` (o usar `docker compose` si estás en versiones recientes).

### 💾 Almacenamiento Persistente
- Es recomendable contar con almacenamiento persistente para guardar:
  - Archivos de configuración
  - Certificados SSL
  - Base de datos de Authelia (si usas SQLite, basta con disco local; si usas Redis o PostgreSQL, requerirás servicios adicionales). Nosotros lo haremos con SQLite.

### ⚙️ Conocimientos Básicos de Redes y Linux
- Aunque el stack está automatizado, es útil tener nociones sobre:
  - **Puertos, DNS, certificados, firewalls**
  - Manejo de **sistemas Linux o similares** (Ubuntu, Debian, etc.)
  - Lectura y edición de archivos YAML

### 🌍 Puertos abiertos
- Para que Traefik pueda trabajar en condiciones, necesitaremos abrir dos puertos en nuestro router: el 80 (para HTTP) y el 443 (para HTTPS). Aunque esto nos expone en la red, no hay problema, ya que Traefik interceptará todas las conexiones. 
  
### 🔒 (Opcional) Autenticación de Dos Factores
- Para usar Authelia con 2FA, necesitarás, al menos, una de estas opciones:
  - Una app de autenticación compatible: **Authy**, **Google Authenticator**, **Bitwarden**, etc.
  - Una llave de seguridad FIDO para usar WebAuth.

Visto ya todo esto, empecemos con la configuración.

## 🛠️ Pasos Iniciales [En desarrollo]

### 1️⃣ Generar los certificados SSL Wildcard
Antes de instalar nada, asegúrate de generar tus certificados **SSL wildcard** usando la API de Cloudflare.

### 2️⃣ Instalar Traefik

### 3️⃣ Instalar Authelia







