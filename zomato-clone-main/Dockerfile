# Build Stage
FROM node:18-alpine as builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN NODE_OPTIONS=--openssl-legacy-provider npm run build

# Production Stage
FROM nginx:alpine

# Copy build files to Nginx public directory
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
