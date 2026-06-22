# Deploying the cchat website to Vercel

The landing page lives in [`website/`](../website/) and is a static
[Astro](https://astro.build/) site (`output: 'static'`). It is configured to
deploy on Vercel from the `website` subdirectory and to serve the custom domain
**`cchat.dzhuneyt.com`**.

This document is the reproducible deploy path. Everything that can be committed
to the repo already has been ([`website/vercel.json`](../website/vercel.json));
the only remaining steps are the ones that require the Vercel account and the
`dzhuneyt.com` DNS zone, which are owned by the board.

---

## What's already done (in-repo)

- `website/vercel.json` pins the build so the project is reproducible:
  - `framework: astro`
  - `buildCommand: npm run build`
  - `outputDirectory: dist`
  - `cleanUrls: true`, `trailingSlash: false`
  - a host-conditional `redirects` rule that 301-redirects the raw
    `cchat-website.vercel.app` host to the canonical `cchat.dzhuneyt.com`
    (the `has` host condition scopes it to the `.vercel.app` alias only, so it
    never loops on the custom domain). Deployment-specific
    `cchat-website-<hash>.vercel.app` preview URLs are intentionally not caught.
- `npm run build` is verified green and emits `website/dist/` (static HTML +
  hashed assets).

Because the site is fully static, `website/dist/` can also be served by any
static host (Netlify, Cloudflare Pages, S3+CloudFront, GitHub Pages) — Vercel is
just the chosen target.

---

## Recommended: connect the GitHub repo (no tokens, auto-deploys)

This is the lowest-maintenance path. After a one-time setup, every push to
`main` ships production and every PR gets a preview URL — no CLI or token needed.

**Board action (Vercel dashboard, ~3 min):**

1. <https://vercel.com/new> → import **`Dzhuneyt/cchat`** into the
   `dzhuneyt's projects` team.
2. In the import screen, set:
   - **Root Directory** → `website`  ← _critical; the repo root is not an Astro project_
   - Framework Preset → **Astro** (auto-detected; `vercel.json` also pins it)
   - Build Command → `npm run build` (default)
   - Output Directory → `dist` (default)
3. Click **Deploy**. The first build produces a `*.vercel.app` URL — that is the
   working preview/production URL. Confirm it renders the cchat landing page.

**Then add the custom domain:**

4. Project → **Settings → Domains** → add `cchat.dzhuneyt.com`.
5. Vercel will display the exact DNS record to create. It will be a **CNAME** for
   the `cchat` subdomain (see the DNS section below for the values to add to the
   `dzhuneyt.com` zone).
6. Once DNS propagates, Vercel auto-issues the TLS certificate and the domain
   goes live.

---

## Alternative: deploy via the Vercel CLI

Use this if you'd rather not connect the Git integration. Requires the board's
Vercel auth (interactive `vercel login`, or a `VERCEL_TOKEN` from
<https://vercel.com/account/tokens>). Run from the `website/` directory:

```bash
cd website
npx vercel@latest            # first run: links/creates the project; pick the
                             # dzhuneyt's projects team; root dir is "." here
npx vercel@latest --prod     # production deploy
```

With a token (non-interactive / CI):

```bash
cd website
npx vercel@latest --prod --yes --token "$VERCEL_TOKEN" \
  --scope dzhuneyts-projects
```

> Note: the agent tooling cannot run this — there is no Vercel CLI session or
> `VERCEL_TOKEN` available to the CTO agent, and the connected Vercel MCP is
> read-only (it can list projects/deployments/domains but cannot create a
> project, attach a domain, or write DNS). Hence the dashboard path above is the
> recommended one.

---

## DNS records for `cchat.dzhuneyt.com` (board owns the `dzhuneyt.com` zone)

`cchat.dzhuneyt.com` is a **subdomain**, so it uses a **CNAME** record. Add this
to the `dzhuneyt.com` DNS zone:

| Type  | Name / Host | Value                  | TTL          | Proxy |
|-------|-------------|------------------------|--------------|-------|
| CNAME | `cchat`     | `cname.vercel-dns.com` | 3600 (or Auto) | DNS only / unproxied |

Notes:
- **Name/Host** is just `cchat` (some DNS UIs want the full
  `cchat.dzhuneyt.com` — both refer to the same record).
- `cname.vercel-dns.com` is Vercel's general subdomain target. **Use the exact
  value Vercel shows in Settings → Domains after you add the domain** — Vercel
  sometimes hands out a region-specific target (e.g. `cname.vercel-dns-0XX.com`).
  If the dashboard shows a different value, prefer it.
- If the DNS provider is Cloudflare, set the record to **DNS only** (grey cloud)
  so Vercel can issue and serve the certificate directly.
- Do **not** add an A record for this subdomain; the apex `dzhuneyt.com` is out
  of scope for this project.

After the CNAME resolves, Vercel verifies the domain and provisions HTTPS
automatically (typically within minutes).

---

## Verifying the deploy

- Build locally: `cd website && npm run build` → exit 0, `dist/index.html` present.
- Preview/production renders the landing page at the `*.vercel.app` URL.
- `https://cchat.dzhuneyt.com` resolves and serves the site over HTTPS once DNS
  propagates and the cert is issued.
