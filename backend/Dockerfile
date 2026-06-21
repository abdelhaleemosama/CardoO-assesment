FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json tsconfig.build.json nest-cli.json ormconfig.ts ./
COPY src ./src
COPY migrations ./migrations
COPY scripts ./scripts
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/migrations ./migrations
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/src ./src
COPY tsconfig.json ormconfig.ts ./
# Need ts-node available at runtime to run the .ts migrations + datasource
RUN npm install --no-save ts-node@10.9.2 typescript@5.5.3
RUN addgroup -S app && adduser -S app -G app && chown -R app:app /app
USER app
EXPOSE 3000
CMD ["sh", "-c", "npm run migration:run && node dist/main"]
