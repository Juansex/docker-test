# Etapa 1: Construcción (Build Stage)
FROM node:18-alpine AS build

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias (npm ci para builds más rápidos y reproducibles)
RUN npm ci

# Copiar el resto del código fuente
COPY . .

# Generar el build de producción
RUN npm run build

# Etapa 2: Producción (Production Stage)
FROM nginx:alpine

# Copiar configuración personalizada de NGINX
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar el build desde la etapa anterior
COPY --from=build /app/build /usr/share/nginx/html

# Exponer el puerto 80
EXPOSE 80

# Iniciar NGINX
CMD ["nginx", "-g", "daemon off;"]