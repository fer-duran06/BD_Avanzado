# app/Dockerfile
FROM node:20-alpine

WORKDIR /app

# 1. Copiar archivos de dependencias
COPY package.json package-lock.json* ./

# 2. Instalar dependencias completas (incluyendo devDependencies)
RUN npm install

# 3. Copiar el código fuente
COPY . .

# 4. Exponer puerto
EXPOSE 3000

# 5. Comando para iniciar en modo desarrollo
CMD ["npm", "run", "dev"]