# Use official Node.js 22 LTS image as base
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy application files
COPY . .

# Expose port (default 9000)
EXPOSE 9000

# Set environment variable for production
ENV NODE_ENV=production

# Start the Express server
CMD ["node", "express.js"]
