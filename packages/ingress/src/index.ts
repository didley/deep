import { Hono } from 'hono'
import { handle } from 'hono/aws-lambda'
import { trimTrailingSlash } from 'hono/trailing-slash'

const app = new Hono()

app.use("*", trimTrailingSlash())

app.get('/ingress/health', (c) => c.json({ status: 'ok' }))

export const handler = handle(app)
