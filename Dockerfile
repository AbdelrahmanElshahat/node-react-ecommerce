FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

# Install all dependencies including devDependencies for production
RUN npm install

COPY . .

EXPOSE 5000

# Use node directly instead of nodemon for production
CMD ["npm", "run", "prod"]