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
can be served by any static host. For Vercel, set the project root to `website`
with build command `npm run build` and output directory `dist`.
