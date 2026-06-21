# cchat website

Static landing page for [cchat](../README.md), built with [Astro](https://astro.build/).

## Develop

```bash
npm install
npm run dev      # start dev server at http://localhost:4321
npm run build    # build static site to ./dist
npm run preview  # preview the production build locally
```

## Deploy

Output is fully static (`output: 'static'` in `astro.config.mjs`), so `dist/`
can be served by any static host. For Vercel, the project deploys from this
`website` directory (root directory = `website`, build `npm run build`, output
`dist`); these settings are pinned in [`vercel.json`](./vercel.json).

See [`../docs/DEPLOY.md`](../docs/DEPLOY.md) for the full reproducible deploy
path and the exact DNS records for `cchat.dzhuneyt.com`.
