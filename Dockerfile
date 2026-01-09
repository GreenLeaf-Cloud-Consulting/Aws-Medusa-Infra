# Development Dockerfile for Medusa
FROM node:20-alpine

# Set working directory
WORKDIR /server

# Copy package files and npm config
COPY package.json package-lock.json ./

# Install all dependencies using npm
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Build Medusa for production (baked into Docker image)
RUN npm run build

# Expose the port Medusa runs on
EXPOSE 9000

# Start with migrations and then the development server
CMD ["./start.sh"]