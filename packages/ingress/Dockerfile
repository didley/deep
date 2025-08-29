FROM node:20-slim
WORKDIR /srv
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build
ENV PORT=8080 NODE_ENV=production
CMD ["node", "dist/index.js"]