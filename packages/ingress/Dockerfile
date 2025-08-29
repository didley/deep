FROM node:20-slim
WORKDIR /srv

# 1. Copy root manifests + package manifest
COPY pnpm-lock.yaml package.json pnpm-workspace.yaml ./
COPY packages/ingress/package.json ./packages/ingress/

# 2. Install only this package's deps (with workspace context)
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN pnpm install --filter @ingress... --frozen-lockfile

# 3. Copy source
COPY packages/ingress ./packages/ingress
# COPY packages/common ./packages/common

# 4. Build
RUN pnpm --filter @ingress build

ENV NODE_ENV=production
ENV PORT=8080
CMD ["node", "packages/ingress/dist/index.js"]