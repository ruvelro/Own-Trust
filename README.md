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

El proyecto está diseñado sobre Ubuntu 24.04 LTS, aunque debería funcionar en cualquier distro Linux (o Windows, o macOS) al estar basado en Docker. Tan solo aseguraté de tener Docker y Docker Compose instalado en tu servidor.

### 🐋 Instalar Docker y Docker Compose en Ubuntu 24.04

```bash
# Actualiza los paquetes
sudo apt update && sudo apt upgrade -y

# Instala dependencias necesarias
sudo apt install -y ca-certificates curl gnupg

# Añade la clave GPG oficial de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Añade el repositorio de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instala Docker y Docker Compose
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Añade tu usuario al grupo docker (opcional)
sudo usermod -aG docker $USER
```
### 📁 Crear estructura de directorios
A continuación, crea la estructura de directorios que vamos a usar para Traefik y Authelia.

```
sudo mkdir /Docker/
chmod -R 777 /Docker/
mkdir -p /Docker/traefik/{certs,config/dynamic}
mkdir -p /Docker/authelia
touch /Docker/traefik/config/traefik.yml
touch /Docker/traefik/config/dynamic/dynamic.yml
```
Aunque no es lo ideal (y lo corregiré en el futuro), para que no haya problemas de permisos, sobre todo con el generador de certificados wildcard, te recomiendo dar permisos 777 al directorio /Docker/. Luego, a cada subcarpeta de /Docker/, le puedes dar los permisos que consideres.

El resultado final de la estructura de datos será así:
```
/Docker/
├── traefik/
│   ├── certs/
│   └── config/
│       ├── traefik.yml
│       └── dynamic/
│           ├── dynamic.yml
│           └── certs.yml
└── authelia/
    ├── configuration.yml
    ├── db.sqlite3
    ├── notification.txt
    └── users_database.yml
```
(los ficheros de "authelia" no hay que crearlos con touch, los crea el propio servicio).

## 🛠️ Conseguir la API de Cloudflare para los dominios

Para generar los certificados SSL Wildcard utilizando `acme.sh`, necesitamos obtener un **Token de la API de Cloudflare**. A continuación, te explico paso a paso cómo conseguirlo. Suponemos que ya tenemos comprado un dominio allí, o migrado de nuestro proveedor a GitHub. Si no es así, hazlo antes de continuar.

### Paso 1: Iniciar sesión en Cloudflare

1. Accede a la página web de [Cloudflare](https://www.cloudflare.com/).
2. Si ya tienes una cuenta, haz login con tus credenciales. Si no tienes cuenta, crea una nueva.

### Paso 2: Ir a la sección de "Profile"

1. Una vez dentro de tu cuenta de Cloudflare, haz clic en el ícono de tu perfil en la esquina superior derecha de la página.
2. En el menú desplegable, selecciona **"Profile"** (Mi perfil).

### Paso 3: Acceder a la sección de API Tokens

1. Dentro del perfil, ve a la pestaña **"API Tokens"**.
2. En esta sección, verás la opción para generar nuevos tokens de API. Haz clic en **"Create Token"**.

### Paso 4: Crear un nuevo Token

1. Selecciona **"Create Custom Token"** (Crear token personalizado).
2. En la pantalla de creación del token, tendrás que configurar los permisos del token. Utiliza la siguiente configuración:

   - **Permissions**:
     - **Zone** → **Read** (para leer información de los dominios).
     - **DNS** → **Edit** (para gestionar los registros DNS, necesario para validar el dominio).
   
   - **Zone Resources**:
     - **Include** → **All zones** (para que tenga acceso a todos tus dominios en Cloudflare).
    
![image](https://github.com/user-attachments/assets/4b74b033-24b4-4ac1-b547-46c57e58f738)


3. Haz clic en **Continue to summary** (Continuar con el resumen).

### Paso 5: Guardar el Token

1. Revisa la configuración del token y asegúrate de que todo está correcto.
2. Haz clic en **Create Token** (Crear Token).
3. Cloudflare generará el token y lo mostrará en pantalla. **Copia el token** y guárdalo en un lugar seguro, ya que no podrás verlo de nuevo.

### 1️⃣ Generar los certificados SSL Wildcard
Para esta tarea, vamos a usar el script "acme.sh". 
Podemos bajarlo e instalarlo a mano para, después, ejecutar el script "instalar_wildcard.sh" de este repositorio. Pero en el script he añadido directamente una función que comprueba si está instalado y, si no, lo instala automáticamente. 
Lo que sí necesitamos es "curl", que si no lo tenemos, podemos bajarlo e instalarlo con el siguiente comando:

```
sudo apt install curl
```
Una vez instalado curl, el siguiente paso será ejecutar el script "instalar_wildcard.sh". Para ello, lo bajamos del repositorio, lo colocamos en el directorio que queramos del sistema. Y, antes de nada, debemos cambiar las variables por las nuestras propias:

-DOMAIN --> Nuestro dominio, simple. Por ejemplo, "midominio.xyz"

-CERT_DIR --> Carpeta donde se instalarán los certificados. Mejor no tocar, ya que si lo haces tendrás que cambiar luego otras variables

-CF_Token --> El token de la API de Cloudflare. Ya está explicado cómo obtenerlo.

-EMAIL --> La dirección de correo para registro en Let's Encrypt.

Finalmente, le damos permisos de ejecución con:
```
chmod +x instalar_wildcard.sh". 
```
Ahora solo nos queda ejecutarlo con:
```
./instalar_wildcard.sh
```
Al terminar de ejecutarse, veremos un mensaje que nos indicará si se ha ejecutado correctamente, o ha habido un error. Debemos ver también bien las últimas líneas del script para ver que no ha salido nada mal. 

Si todo ha ido bien, ya solo nos queda comprobar si se ha creado la tarea de renovación de los certificados con:
```
crontab -l
```
Tiene que salir algo como "29 5 * * * "/home/ruvelro/.acme.sh"/acme.sh --cron --home "/home/ruvelro/.acme.sh" > /dev/null", lo cual indica que la tarea de actualización de certificados SSL se ha creado correctamente. Puedes ajustar, si quieres, los tiempos jugando con ese cron.

Listo. Ya tenemos nuestro generador de certificados wildcard instalado y configurado. Sigamos con Traefik.

### 2️⃣ Instalar Traefik

### 3️⃣ Instalar Authelia







