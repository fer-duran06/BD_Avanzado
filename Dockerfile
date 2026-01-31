# Usamos una imagen ligera de Node.js
FROM node:20-alpine

# Creamos la carpeta de trabajo dentro del contenedor
WORKDIR /app

# Copiamos los archivos de dependencias
COPY package*.json ./

# Instalamos las librerías
RUN npm install

# Copiamos el resto del código
COPY . .

# Construimos la aplicación Next.js
RUN npm run build

# Exponemos el puerto 3000
EXPOSE 3000

# Comando para iniciar la app
CMD ["npm", "start"]