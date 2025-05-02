# 🔐 Own Trust: Tu Infraestructura, Tus Reglas

**Own Trust** es una alternativa autoalojada a Cloudflare Zero Trust, diseñada para ofrecer **seguridad avanzada en redes y servicios personales**, sin depender de servicios en la nube de terceros.

Este proyecto nace como respuesta a los **bloqueos masivos** que ciertas organizaciones, junto con los operadores de Internet, están realizando semana tras semana contra los CDN, afectando especialmente a quienes, como yo, **no tienen el más mínimo interés en el fútbol**.

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
> evitando que cuando hay partido, cierta organización te deje sin servicio todo el fin de semana,  
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

### 🌍 IP Pública
- Necesitamos que nuestro operador nos esté dando una IP real para conectarnos a Internet. Si estamos dentro de un CG-NAT, no podrás usar Own Trust, porque no podrás conectarte desde fuera a tu IP.
  
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

## 🚀 2️⃣ Instalar Traefik

Llegados a este punto, ya tenemos en marcha nuestro generador de certificados **Wildcard SSL**.  
Puedes comprobarlo visitando [crt.sh](https://crt.sh/) y buscando tu dominio. Verás un único certificado tipo `*.midominio.xyz`, en lugar de uno por cada subdominio individual. ¡Todo va según lo planeado!

Ahora toca desplegar **Traefik**, nuestro **proxy inverso**.

---

### 🗂️ Estructura del proyecto

Dentro del directorio `traefik/` del repositorio encontrarás:

📄 **`docker-compose.yml`**  
- Lanza y configura:
  - 🌀 **Traefik** (proxy inverso)
  - 🌐 **Cloudflare DDNS** (para mantener el dominio actualizado con tu IP)
  - 🧪 Servicio de prueba **whoami**
  - 📦 **Portainer**, para gestionar contenedores fácilmente

📁 **`config/`**  
- Contiene toda la configuración necesaria para Traefik.
- Copia la carpeta `traefik` al directorio `/Docker/` de tu servidor.

📄 **`traefik.yml`**  
- Archivo de configuración **global** del proxy.

📄 **`dynamic.yml`**  
- Configuración **dinámica**:
  - Middlewares
  - Servicios externos (fuera de Docker, como Plex o Cockpit)
  - ⚠️ Para servicios en Docker, mejor usar `labels`.
  - El Geo-Bloqueo está configurado para bloquear por defecto todo el tráfico que venga desde fuera de España. Tenlo en cuenta.

---

### ⚙️ Pasos previos antes de desplegar

Una vez copiados los archivos al servidor (`docker-compose.yml` y carpeta `traefik/`), hay que hacer algunos ajustes:

#### 🔧 Modificaciones en `docker-compose.yml`

🛠️ Red de Docker:  
- *(Opcional)* Cambia `mired` por otro nombre si lo deseas.  
  ⚠️ Si lo haces, cambia también la red en todos los servicios que la usan.

🔐 Servicio `cloudflare-ddns-net`:  
- Reemplaza `CF_API_TOKEN` por tu token de Cloudflare (puedes usar el mismo que el del generador de certificados).  
- Sustituye `midominio.xyz` en `DOMAINS` por tu dominio real.

🌐 Labels de servicios:  
- Cambia cada instancia de `midominio.xyz` por tu dominio.  
  📌 Suele aparecer **dos veces por servicio**.

---

#### 🧩 Cambios en `dynamic.yml`

🌍 Regla de host:  
- Reemplaza todas las entradas `rule: Host(...)` con tu dominio real.  
  - Puedes ajustar también el subdominio, por ejemplo:  
    `traefik.midominio.xyz` → `proxy.tudominio.com`.

💡 Servicios externos:  
- En cada `url`, cambia la IP local (ej. `http://192.168.X.X:PORT`) por la correcta.  
  - Aplica esto a todos los servicios **añadidos a mano** (no en Docker).

---

Ya solo nos queda desplegar el Docker Compose con el comando "sudo docker compose up -d --remove-orphans" y esperar a que todo se monte bien. En pocos minutos deberíamos tener instalado el DDNS de Cloudflare, Traefik, Whoami y Portainer. Y todo debería estar funcionando correctamente. 

![image](https://github.com/user-attachments/assets/46943d14-2c07-414a-9c93-14995de8736d)


Podemos comprobarlo fácilmente:
-Entrando en "192.168.X.X:8999 deberíamos ver la web de Traefik. En ella debería aparecer todo en verde. Y deberíamos tener los middleware funcionando. Si entramos en "traefik.midominio.xyz" deberíamos llegar a esta misma ventana.
-Si entramos en "whoami.midominio.xyz" veremos una página de prueba de whoami. 
-Si entramos en "portainer.midominio.xyz" podremos entrar en Portainer, igual que si entramos desde 192.168.x.x:9000.

![image](https://github.com/user-attachments/assets/37d13f89-db6b-4941-9aac-67e6857ccaa9)



✅ **¡Todo listo!**  
Con estos pasos tendrás Traefik funcionando como proxy inverso, con certificados Wildcard, DNS dinámico y gestión por Portainer.

## 3️⃣ Instalar Authelia

Una vez que ya tenemos nuestro servidor y servicios protegidos, podemos añadir una **capa extra de seguridad** mediante **Authelia**, un middleware de autenticación avanzada.

### 🔐 ¿Qué es Authelia y por qué usarlo?

Authelia actúa como una **pasarela de autenticación** antes de acceder a tus servicios. Esto tiene varias ventajas:

- ✅ **Login unificado**: Puedes desactivar los logins internos de servicios como *Servarr* y gestionar todo desde Authelia.
- 🧩 **Añade un login** a los servicios que no lo tienen. Por ejemplo, si tienes "homepage" o "Glances".
- 🔒 **Autenticación en dos pasos**: Añade una segunda capa de seguridad mediante OTP o WebAuthn.
- 🛡️ **Blindaje ante ataques**: Si un atacante descubre un subdominio (por ejemplo, `portainer.tudominio.xyz`), no podrá alcanzar el servicio final sin autenticarse en Authelia. Si el subdominio no es descriptivo, **ni siquiera sabrá qué servicio hay detrás**.

---

### 🗂️ Estructura del Proyecto

Para desplegar Authelia, crearemos una carpeta llamada `authelia` dentro del directorio `/Docker`.

En el directorio `authelia/` de este repositorio encontrarás:

#### 📄 `docker-compose.yml`
- Despliega y configura:
  - 🌀 **Authelia** (como servicio de autenticación)

#### 📄 `configuration.yml`
- Archivo de configuración **global** de Authelia.
- Define estrategias de autenticación, métodos de acceso, etc.

#### 📄 `users_database.yml`
- Contiene la **base de datos de usuarios**.
- Aquí defines los usuarios, contraseñas y métodos 2FA.

---

Authelia requiere permisos más estrictos por razones de seguridad. Por eso, **te recomendamos preparar únicamente el directorio `/Docker/authelia`**, y dejar el resto de archivos para después del despliegue.

### 🚀 Despliegue inicial

1. Copia el archivo `docker-compose.yml` al servidor.
2. Dentro del `docker-compose.yml` cambia todos los "midominio.xyz" por tu propio dominio. El subdominio (auth) no debes cambiarlo.
3. Accede al directorio donde lo colocaste.
4. Lanza el servicio con: sudo docker compose up -d --remove-orphans
5. Si todo funciona correctamente, Authelia se desplegará pero no estará operativo aún hasta que lo configures.

👉 En el siguiente paso te explicaremos cómo hacerlo.

### 🛠 Configuración inicial de Authelia

#### 1. Configurar `configuration.yml`

Primero, accedemos al directorio `/Docker/authelia` para editar el archivo de configuración.

Copiamos todo el contenido del archivo `configuration.yml` que se encuentra en el repositorio y lo pegamos en el archivo local. **Antes de guardar, es necesario modificar los siguientes valores:**

- **`jwt_secret`** (dentro de `identity_validation`)  
  Ejecutar `openssl rand -hex 64` para generar una clave segura. La clave se coloca dentro de comillas.

- **`domain`** (dentro de `rules`)  
  Sustituir por tu dominio real.

- **`secret`** (dentro de `session`)  
  Ejecutar `openssl rand -hex 64` para generar una clave segura. La clave se coloca dentro de comillas.

- **`domain`** (dentro de `cookies`)  
  Sustituir por tu dominio real.

- **`authelia_url`** (dentro de `cookies`)  
  Introducir la URL en la que se desplegará Authelia (por ejemplo, `https://auth.midominio.xyz`).

- **`default_redirection_url`** (dentro de `cookies`)  
  URL a la que se redirigirá tras un inicio de sesión exitoso.

- **`encryption_key`** (dentro de `storage`)  
  Ejecutar `openssl rand -hex 64` para generar una clave segura. La clave se coloca dentro de comillas.

Una vez hechos estos cambios, el archivo `configuration.yml` estará listo.

---

#### 2. Configurar `users_database.yml`

Abrimos el archivo `users_database.yml` y reemplazamos su contenido por el que aparece en el repositorio. A continuación, modificamos los siguientes campos:

- **`nombre_usuario`**  
  El nombre del usuario que se usará para iniciar sesión.

- **`password`**  
  Contraseña cifrada. Se puede generar ejecutando:  
  `docker run -it --rm authelia/authelia:latest authelia crypto hash generate`

- **`email`**  
  Dirección de correo del usuario.

- **`grupo1`**  
  Grupo al que pertenecerá el usuario (por ejemplo: `admins`, `users`, etc.).

---

Una vez configurados ambos archivos, Authelia estará listo para funcionar correctamente. 
Reiniciamos el docker con "sudo docker-compose restart authelia" y todo debería estar ya funcionando. 
Podemos probarlo entrando en "auth.midominio.xyz" (el que hayamos configurado en authelia_url, dentro de la configutación) y podremos ver la pantalla de Login de Authelia. 

![image](https://github.com/user-attachments/assets/e95cdf6e-bc39-488b-95a4-381802054d35)


Si introducimos el usuario y la contraseña que hemos configurado en el archivo "users_database.yml", podremos iniciar sesión. 

### 🧩 Añadir Authelia a los servicios dentro de Traefik

Ya tenemos Authelia funcionando. Pero, para que se aplique a cada subdominio, debemos realizar algunos ajustes sencillos en la configuración de Traefik.

---

#### ✅ Aplicar el middleware a servicios en Docker

El primer paso es añadir, en las *labels* de todos los servicios definidos en Docker, la etiqueta que permite usar el middleware de Authelia.

Para ello, localiza la línea donde se definen los middlewares del router Traefik en cada contenedor y añade `authelia@docker` al final de la lista. El resultado debe verse así:

**Ejemplo de configuración de middlewares:**

MIDDLEWARES
      - "traefik.http.routers.portainer.middlewares=geo-block@file,rate-limit@file,secure-headers@file,authelia@docker"

> 💡 Es importante que `authelia@docker` vaya **al final**, ya que debe ser el último middleware en ejecutarse.

---

#### 🖧 Aplicar el middleware a servicios fuera de Docker (modo host)

Si tienes servicios que no están gestionados directamente por Docker (por ejemplo, Plex en modo host), deberás definir manualmente el middleware dentro del archivo dinámico de configuración de Traefik, normalmente llamado `dynamic.yml`.

**Ejemplo de router para Plex:**

#🎬 Plex
    plex:
      rule: "Host(`plex.midominio.xyz`)"
      service: plex
      entryPoints:
        - websecure
      tls: {}
      middlewares:
        - geo-block
        - rate-limit
        - secure-headers
        - authelia@docker <--- Este es el importante


---

#### 🔐 Middleware Authelia en Traefik

Para que `authelia@docker` funcione, Authelia debe estar registrado como un middleware en Traefik mediante las *labels* de su propio contenedor.

Si seguiste la guía de despliegue inicial, esto ya debería estar configurado. No obstante, asegúrate de incluir las siguientes etiquetas en el contenedor de Authelia:

- Definir la dirección del endpoint de verificación.
- Permitir el reenvío de cabeceras.
- Especificar qué cabeceras se deben devolver al cliente autenticado.

**Etiquetas necesarias para el contenedor de Authelia:**

labels:
  - "traefik.http.middlewares.authelia.forwardauth.address=http://authelia:9091/api/verify"
  - "traefik.http.middlewares.authelia.forwardauth.trustForwardHeader=true"
  - "traefik.http.middlewares.authelia.forwardauth.authResponseHeaders=Remote-User,Remote-Groups,Remote-Name,Remote-Email"


Con estas etiquetas, se define correctamente el middleware `authelia@docker`, que puede aplicarse a cualquier router en Traefik, ya sea gestionado por Docker o definido manualmente.

---

#### 🚀 Finalizar e iniciar protección

Una vez realizados todos los cambios:

- Revisa que todos los servicios que quieras proteger tengan el middleware `authelia@docker` aplicado.
- Reinicia tanto **Traefik** como **Authelia** para aplicar la nueva configuración.

Desde este momento, toda tu infraestructura estará protegida por Authelia, actuando como una *Own Trust* para el control de acceso, incluso fuera del entorno de Cloudflare.

## 4️⃣ Extras

Llegados a este punto, ya tienes toda una infraestructura segura a prueba de bloqueos ilegales por parte de ciertas organizaciones o compañías telefónicas.  
Y, aunque todo debería funcionar perfectamente, hay algunas configuraciones que se pueden afinar mejor para evitar problemas.

### Sacar las APIs de Authelia

Puede ocurrir que tengamos un servicio, como **FreshRSS**, que queremos tener protegido, pero cuya **API** no funciona correctamente si pasa por Authelia.  
En ese caso, lo que debemos hacer es crear una **ruta adicional dentro de Traefik** para que el tráfico destinado a la API no pase por Authelia (aunque sí por el resto de middlewares de seguridad).

Esto se puede hacer fácilmente añadiendo una nueva definición de router en las *labels* del contenedor de Docker de FreshRSS, justo después de los middlewares generales. El bloque de configuración quedaría así:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.freshrss.rule=Host(`freshrss.midominio.xyz`)"
  - "traefik.http.routers.freshrss.entrypoints=websecure"
  - "traefik.http.routers.freshrss.tls=true"
  - "traefik.http.routers.freshrss.tls.domains[0].main=freshrss.midominio.xyz"
  - "traefik.http.services.freshrss.loadbalancer.server.port=80"

  # Middlewares generales (incluye Authelia)
  - "traefik.http.routers.freshrss.middlewares=geo-block@file,rate-limit@file,secure-headers@file,authelia@docker"

  # Router específico para la API, sin pasar por Authelia
  - "traefik.http.routers.freshrss-api.rule=Host(`freshrss.midominio.xyz`) && PathPrefix(`/api/`)"
  - "traefik.http.routers.freshrss-api.entrypoints=websecure"
  - "traefik.http.routers.freshrss-api.tls=true"
  - "traefik.http.routers.freshrss-api.tls.domains[0].main=freshrss.midominio.xyz"
  - "traefik.http.routers.freshrss-api.service=freshrss"
  - "traefik.http.routers.freshrss-api.middlewares=geo-block@file,rate-limit@file,secure-headers@file"
```
Puedes replicar esto mismo para otros servicios (como Home Assistant) a lo que les ocurra lo mismo.
