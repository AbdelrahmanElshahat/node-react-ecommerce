FROM node:18-alpine3.17

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy source code
COPY . .

# Create uploads directory
RUN mkdir -p uploads

EXPOSE 5000

# Start the application using babel-node for development/production
CMD ["npx", "babel-node", "server.js"]