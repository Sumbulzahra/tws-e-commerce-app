# Stage 1: Development/Build Stage
FROM node:18-alpine AS builder
WORKDIR /app

# Install necessary build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN NODE_OPTIONS="--max-old-space-options=2048" npm ci

# Copy all project files
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Production Stage
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Copy necessary files from builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["node", "server.js"]
