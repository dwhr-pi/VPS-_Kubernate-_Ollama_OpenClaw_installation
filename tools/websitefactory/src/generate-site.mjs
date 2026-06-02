import path from "node:path";
import { deriveContentPlan, normalizeBrief } from "./lib/briefing.mjs";
import { ensureDir, nowIso, slugify, writeText } from "./lib/utils.mjs";
import { tryGeneratePlanWithOllama } from "./providers/ollama.mjs";

function astroFiles(projectName, brief, plan) {
  const palette = plan.palette;
  const sectionsLiteral = JSON.stringify(plan.sections, null, 2);
  const seoLiteral = JSON.stringify(plan.seoKeywords || [], null, 2);

  return {
    "package.json": JSON.stringify({
      name: slugify(projectName),
      private: true,
      version: "0.1.0",
      type: "module",
      scripts: {
        dev: "astro dev",
        build: "astro build",
        preview: "astro preview"
      },
      dependencies: {
        astro: "^4.16.0",
        "@astrojs/tailwind": "^5.1.0",
        tailwindcss: "^3.4.10"
      }
    }, null, 2) + "\n",
    "astro.config.mjs": `import { defineConfig } from "astro/config";\nimport tailwind from "@astrojs/tailwind";\n\nexport default defineConfig({\n  integrations: [tailwind()],\n  server: { host: "127.0.0.1" }\n});\n`,
    "tailwind.config.mjs": `export default {\n  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,ts,tsx}"],\n  theme: { extend: {} },\n  plugins: []\n};\n`,
    "src/styles/global.css": `@tailwind base;\n@tailwind components;\n@tailwind utilities;\n\n:root {\n  --wf-bg: ${palette[0] || "#0f172a"};\n  --wf-accent: ${palette[1] || "#22c55e"};\n  --wf-text: ${palette[2] || "#e2e8f0"};\n}\n\nhtml, body {\n  margin: 0;\n  padding: 0;\n  font-family: ui-sans-serif, system-ui, sans-serif;\n  background: radial-gradient(circle at top right, color-mix(in srgb, var(--wf-accent) 20%, transparent), transparent 35%), linear-gradient(180deg, color-mix(in srgb, var(--wf-bg) 90%, black), var(--wf-bg));\n  color: var(--wf-text);\n}\n`,
    "src/layouts/BaseLayout.astro": `---\nimport "../styles/global.css";\nconst { title = "${brief.businessName}", description = "${plan.subheadline}" } = Astro.props;\n---\n<html lang="${brief.language}">\n  <head>\n    <meta charset="utf-8" />\n    <meta name="viewport" content="width=device-width, initial-scale=1" />\n    <title>{title}</title>\n    <meta name="description" content={description} />\n  </head>\n  <body>\n    <slot />\n  </body>\n</html>\n`,
    "src/pages/index.astro": `---\nimport BaseLayout from "../layouts/BaseLayout.astro";\nconst sections = ${sectionsLiteral};\nconst seoKeywords = ${seoLiteral};\n---\n<BaseLayout title="${brief.businessName} | Landingpage" description="${plan.subheadline}">\n  <main class="min-h-screen">\n    <section class="mx-auto max-w-6xl px-6 py-20 md:px-10">\n      <div class="grid gap-10 md:grid-cols-[1.2fr_0.8fr] md:items-center">\n        <div>\n          <p class="mb-4 inline-flex rounded-full border border-white/20 bg-white/5 px-4 py-2 text-sm uppercase tracking-[0.24em] text-white/70">${brief.industry}</p>\n          <h1 class="max-w-3xl text-4xl font-black leading-tight md:text-6xl">${plan.headline}</h1>\n          <p class="mt-6 max-w-2xl text-lg text-white/80 md:text-xl">${plan.subheadline}</p>\n          <div class="mt-8 flex flex-wrap gap-4">\n            <a href="#kontakt" class="rounded-full bg-[var(--wf-accent)] px-6 py-3 font-semibold text-slate-950">${brief.cta}</a>\n            <a href="#leistungen" class="rounded-full border border-white/20 px-6 py-3 font-semibold">Leistungen ansehen</a>\n          </div>\n          <p class="mt-6 text-sm text-white/60">SEO: {seoKeywords.join(" | ")}</p>\n        </div>\n        <div class="rounded-[2rem] border border-white/10 bg-white/5 p-6 shadow-2xl backdrop-blur">\n          <div class="grid gap-4">\n            <div class="rounded-2xl bg-black/30 p-4"><p class="text-sm uppercase tracking-[0.24em] text-white/50">Zielgruppe</p><p class="mt-2 text-lg font-semibold">${brief.audience}</p></div>\n            <div class="rounded-2xl bg-black/30 p-4"><p class="text-sm uppercase tracking-[0.24em] text-white/50">Angebot</p><p class="mt-2 text-lg font-semibold">${brief.offer}</p></div>\n            <div class="rounded-2xl bg-black/30 p-4"><p class="text-sm uppercase tracking-[0.24em] text-white/50">Look & Feel</p><p class="mt-2 text-lg font-semibold">${brief.style}</p></div>\n          </div>\n        </div>\n      </div>\n    </section>\n    <section id="leistungen" class="mx-auto max-w-6xl px-6 pb-16 md:px-10"><div class="grid gap-6 md:grid-cols-2">{sections.map((section) => (<article class="rounded-[1.75rem] border border-white/10 bg-white/5 p-6 shadow-lg backdrop-blur"><h2 class="text-2xl font-bold">{section.title}</h2><p class="mt-4 text-white/75">{section.text}</p></article>))}</div></section>\n    <section id="kontakt" class="mx-auto max-w-6xl px-6 pb-24 md:px-10"><div class="rounded-[2rem] border border-white/10 bg-gradient-to-br from-white/10 to-white/5 p-8 shadow-2xl"><div class="grid gap-8 md:grid-cols-[1fr_1fr]"><div><p class="text-sm uppercase tracking-[0.24em] text-white/60">Kontakt</p><h2 class="mt-3 text-3xl font-black">Lassen Sie uns Ihre naechste Website aufbauen.</h2><p class="mt-4 text-white/75">Diese Kontaktflaeche ist als UI-Platzhalter gedacht und kann spaeter an Formspree, n8n oder Ihr eigenes Backend angebunden werden.</p></div><form class="grid gap-4 rounded-[1.5rem] bg-black/25 p-6"><input class="rounded-xl border border-white/15 bg-black/20 px-4 py-3 text-white placeholder:text-white/40" type="text" placeholder="Name" /><input class="rounded-xl border border-white/15 bg-black/20 px-4 py-3 text-white placeholder:text-white/40" type="email" placeholder="E-Mail" /><textarea class="min-h-32 rounded-xl border border-white/15 bg-black/20 px-4 py-3 text-white placeholder:text-white/40" placeholder="Projekt oder Kampagne beschreiben"></textarea><button class="rounded-full bg-[var(--wf-accent)] px-6 py-3 font-semibold text-slate-950" type="button">${brief.cta}</button></form></div></div></section>\n  </main>\n</BaseLayout>\n`,
    "src/pages/impressum.astro": `---\nimport BaseLayout from "../layouts/BaseLayout.astro";\n---\n<BaseLayout title="Impressum | ${brief.businessName}" description="Impressum Platzhalter"><main class="mx-auto max-w-3xl px-6 py-16"><h1 class="text-4xl font-black">Impressum</h1><p class="mt-6 text-white/75">Platzhalter. Bitte vor Livegang mit echten Anbieterangaben, Rechtsform, Kontakt und Vertretungsberechtigten ergaenzen.</p></main></BaseLayout>\n`,
    "src/pages/datenschutz.astro": `---\nimport BaseLayout from "../layouts/BaseLayout.astro";\n---\n<BaseLayout title="Datenschutz | ${brief.businessName}" description="Datenschutz Platzhalter"><main class="mx-auto max-w-3xl px-6 py-16"><h1 class="text-4xl font-black">Datenschutz</h1><p class="mt-6 text-white/75">Platzhalter. Bitte Tracking, Kontaktformular, Hosting, CDN, Analyse und Rechtsgrundlagen vor Livegang rechtskonform ergaenzen.</p></main></BaseLayout>\n`,
    "README.md": `# ${brief.businessName}\n\nAutomatisch erzeugtes Landingpage-Projekt durch WebsiteFactory.\n\n## Quickstart\n\n\`\`\`bash\npnpm install\npnpm dev --host 127.0.0.1 --port 4321\npnpm build\n\`\`\`\n`,
    "CHANGELOG.md": `# Changelog\n\n## 0.1.0\n\n- Erstgenerierung durch WebsiteFactory am ${new Date().toISOString().slice(0, 10)}\n- Astro/Tailwind Landingpage angelegt\n- Rechtliche Platzhalter und Build-Report erzeugt\n`,
    "docs/build-report.md": `# Build Report\n\n## Status\n\n- Generator: abgeschlossen\n- Preview: offen\n- Build: offen\n- Screenshot: offen\n- Lighthouse-Basischeck: offen\n\n## Briefing\n\n- Business: ${brief.businessName}\n- Branche: ${brief.industry}\n- Zielgruppe: ${brief.audience}\n- Stil: ${brief.style}\n- Sprache: ${brief.language}\n\n## Auto-Fix\n\nMaximal 3 Korrekturrunden vorgesehen. In diesem Prototyp sind die Check-Schritte vorbereitet, werden aber nicht ungefragt autonom veroeffentlicht.\n`
  };
}

export async function generateProject(options = {}) {
  const brief = normalizeBrief(options.brief || {});
  const llmPlan = await tryGeneratePlanWithOllama(brief);
  const plan = deriveContentPlan(brief, llmPlan);
  const outputRoot = options.outputDir || path.resolve(process.cwd(), "generated-sites", brief.slug);

  ensureDir(outputRoot);
  const files = astroFiles(brief.businessName, brief, plan);
  for (const [relativePath, content] of Object.entries(files)) {
    writeText(path.join(outputRoot, relativePath), content);
  }

  return {
    brief,
    plan,
    outputDir: outputRoot,
    createdAt: nowIso()
  };
}
