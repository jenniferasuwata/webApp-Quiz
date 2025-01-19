# Dockerfile
FROM node:16-alpine

# Create an app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port for our server (change as needed)
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]
