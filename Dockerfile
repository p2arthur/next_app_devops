# ---- Build stage ----
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Standalone output is great for small runtime image
RUN npm run build

# ---- Runtime stage ----
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
# Copy the standalone build
COPY --from=builder /app/.next/standalone ./ 
COPY --from=builder /app/public ./public
# Next standalone needs the .next/static folder co-located
COPY --from=builder /app/.next/static ./.next/static

# Next standalone server binds to 3000 by default
EXPOSE 3000
CMD ["node", "server.js"]
