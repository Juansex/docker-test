# Docker Test - Rick & Morty App

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

## Descripción

Este proyecto es una aplicación web de React que consume la [API de Rick and Morty](https://rickandmortyapi.com/) para mostrar información sobre los personajes de la serie. La aplicación está completamente dockerizada utilizando un **Dockerfile multi-stage** y cuenta con un pipeline de **CI/CD automatizado con GitHub Actions** que construye y publica la imagen en Docker Hub.

### Características principales:

- **Dockerfile multi-stage**: Optimiza el tamaño de la imagen final
- **CI/CD automatizado**: GitHub Actions construye y publica automáticamente
- **NGINX como servidor web**: Configuración optimizada para aplicaciones React
- **Imagen ligera**: Utiliza Alpine Linux para reducir el tamaño
- **Listo para producción**: Configuración lista para desplegar

---

## Arquitectura de la Aplicación

### Aplicación React
La aplicación permite:
- Ver todos los personajes de Rick and Morty
- Mostrar información detallada (nombre, estado, especie, episodios)
- Interfaz responsive y moderna
- Navegación sencilla entre vistas

### Estructura del Proyecto
```
docker-test/
├── .github/
│   └── workflows/
│       └── docker-publish.yml    # Pipeline CI/CD
├── public/                       # Archivos públicos
├── src/                          # Código fuente React
│   ├── components/
│   │   └── Characters.js         # Componente de personajes
│   ├── img/                      # Imágenes
│   ├── App.js                    # Componente principal
│   ├── App.css                   # Estilos
│   └── index.js                  # Punto de entrada
├── build/                        # Build de producción (generado)
├── dockerfile                    # Configuración Docker multi-stage
├── nginx.conf                    # Configuración NGINX
├── .dockerignore                 # Archivos excluidos del build
├── package.json                  # Dependencias del proyecto
└── README.md                     # Este archivo
```

---

## Implementación Docker

### Dockerfile Multi-Stage

El proyecto utiliza un **Dockerfile multi-stage** que separa el proceso de construcción en dos etapas:

#### **Etapa 1: Build (Construcción)**
```dockerfile
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```
- Usa Node.js 18 en Alpine Linux (imagen ligera)
- Instala las dependencias con `npm ci` (más rápido y reproducible)
- Construye la aplicación React para producción

#### **Etapa 2: Production (Producción)**
```dockerfile
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
- Usa NGINX en Alpine (imagen ultra-ligera)
- Copia solo los archivos estáticos necesarios desde la etapa de build
- Configura NGINX con configuración personalizada
- Expone el puerto 80

### Ventajas del Multi-Stage Build:

- **Imagen final más pequeña**: Solo contiene NGINX y archivos estáticos (sin Node.js ni dependencias de desarrollo)  
- **Más seguro**: Menos superficie de ataque al eliminar herramientas de desarrollo  
- **Más rápido**: Las imágenes más pequeñas se descargan y despliegan más rápido  
- **Mejor organización**: Separa claramente build de producción

### .dockerignore

El archivo `.dockerignore` excluye archivos innecesarios del contexto de Docker:
```
node_modules
npm-debug.log
build
.git
.gitignore
README.md
.env
.DS_Store
```

Esto acelera el build y reduce el tamaño del contexto enviado al daemon de Docker.

### nginx.conf

Configuración optimizada para aplicaciones React con client-side routing:
```nginx
server {
    listen 80;
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }
}
```
La directiva `try_files` asegura que todas las rutas sean manejadas por React Router.

---

## CI/CD con GitHub Actions

### Pipeline Automatizado

El workflow `.github/workflows/docker-publish.yml` se ejecuta automáticamente en cada push o pull request a `main`:

```yaml
name: Docker Build and Push

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
```

### Pasos del Pipeline:

1. **Checkout del código**
   ```yaml
   - uses: actions/checkout@v4
   ```

2. **Configurar Docker Buildx**
   ```yaml
   - uses: docker/setup-buildx-action@v3
   ```
   Habilita características avanzadas de Docker como cache optimizado

3. **Login en Docker Hub**
   ```yaml
   - uses: docker/login-action@v3
     with:
       username: ${{ secrets.DOCKERHUB_USERNAME }}
       password: ${{ secrets.DOCKERHUB_TOKEN }}
   ```
   Autentica usando secrets configurados en el repositorio

4. **Build y Push de la imagen**
   ```yaml
   - uses: docker/build-push-action@v5
     with:
       push: true
       tags: latest, sha-{commit}
       cache-from: type=gha
       cache-to: type=gha,mode=max
   ```
   Construye y publica con cache de GitHub Actions para builds más rápidos

### Configuración de Secrets

Para que el pipeline funcione, debes configurar estos secrets en GitHub:

1. Ve a: **Settings** → **Secrets and variables** → **Actions**
2. Crea estos secrets:
   - `DOCKERHUB_USERNAME`: Tu usuario de Docker Hub
   - `DOCKERHUB_TOKEN`: Token de acceso de Docker Hub

Para crear el token:
1. Ve a [Docker Hub](https://hub.docker.com)
2. Account Settings → Security → New Access Token
3. Copia el token y agrégalo como secret en GitHub

---

## Cómo Usar

### Opción 1: Usar la imagen publicada en Docker Hub

```bash
# Descargar la imagen
docker pull juansex/docker-test:latest

# Ejecutar el contenedor
docker run -d -p 8080:80 juansex/docker-test:latest

# Abrir en el navegador
open http://localhost:8080
```

### Opción 2: Build local

```bash
# Clonar el repositorio
git clone https://github.com/Juansex/docker-test.git
cd docker-test

# Construir la imagen
docker build -t docker-test:local .

# Ejecutar el contenedor
docker run -d -p 8080:80 docker-test:local

# Abrir en el navegador
open http://localhost:8080
```

### Opción 3: Desarrollo local (sin Docker)

```bash
# Instalar dependencias
npm install

# Ejecutar en modo desarrollo
npm run dev

# Abrir http://localhost:3000
```

---

## Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| **React** | 18.2.0 | Framework frontend |
| **Node.js** | 18-alpine | Build de la aplicación |
| **NGINX** | alpine | Servidor web |
| **Docker** | - | Contenedorización |
| **GitHub Actions** | - | CI/CD automatizado |
| **Rick and Morty API** | - | Fuente de datos |

---

## Comparación de Tamaños de Imagen

| Tipo de Build | Tamaño |
|--------------|--------|
| **Con Node.js** (sin multi-stage) | ~1.2 GB |
| **Multi-stage con NGINX** | ~45 MB |
| **Reducción** | **96%** |

---

## Comandos Útiles

```bash
# Ver imágenes locales
docker images

# Ver contenedores en ejecución
docker ps

# Ver logs del contenedor
docker logs <container_id>

# Detener contenedor
docker stop <container_id>

# Eliminar contenedor
docker rm <container_id>

# Eliminar imagen
docker rmi docker-test:local

# Limpiar sistema Docker
docker system prune -a
```

---

## Imagen Publicada

**Docker Hub**: [https://hub.docker.com/r/juansex/docker-test](https://hub.docker.com/r/juansex/docker-test)


---

## Autor

**Juan Sebastian**
- GitHub: [@Juansex](https://github.com/Juansex)

---

## Recursos Adicionales

- [Documentación oficial de Docker](https://docs.docker.com/)
- [Guía de Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [React Documentation](https://react.dev/)
- [NGINX Documentation](https://nginx.org/en/docs/)
