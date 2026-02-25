# Imagen base con Node
FROM node:22-alpine AS base
WORKDIR /app


# Instalamos las dependencias
COPY package.json package-lock.json ./
RUN npm ci



# Ejecutamos los tests, si fallan el build para
FROM base AS test
COPY . .
RUN npm run test



# Generoamos los archivos para producción en dist/
FROM test AS build
RUN npm run build

# Servidor de desarrollo
FROM base AS dev
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]



# Imagen final con Nginx, solo copiamos lo de dist/
FROM nginx:stable-alpine AS production
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]