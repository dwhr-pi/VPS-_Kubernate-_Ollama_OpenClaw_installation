import { parseCommaList, slugify } from "./utils.mjs";

const paletteByStyle = {
  modern: ["#0f172a", "#22c55e", "#e2e8f0"],
  minimal: ["#111827", "#6366f1", "#f9fafb"],
  luxury: ["#111111", "#c9a227", "#f5f1e8"],
  playful: ["#1d4ed8", "#f97316", "#fef3c7"]
};

export function normalizeBrief(input = {}) {
  const style = input.style || "modern";
  const colors = Array.isArray(input.colors) && input.colors.length
    ? input.colors
    : paletteByStyle[style.split(",")[0].trim()] || paletteByStyle.modern;

  const businessName = input.businessName || "Neue Marke";
  const language = String(input.language || "de").toLowerCase().startsWith("en") ? "en" : "de";

  return {
    businessName,
    industry: input.industry || "Dienstleistung",
    audience: input.audience || "anspruchsvolle Zielgruppe",
    style,
    pages: Number.isFinite(Number(input.pages)) ? Number(input.pages) : 3,
    cta: input.cta || (language === "de" ? "Jetzt anfragen" : "Request a quote"),
    colors,
    language,
    offer: input.offer || (language === "de" ? "Beratung, Umsetzung und Support" : "Consulting, delivery and support"),
    prompt: input.prompt || "",
    slug: slugify(input.slug || businessName)
  };
}

export function deriveContentPlan(brief, llmPlan = null) {
  const fallbackSections = brief.language === "de"
    ? [
        { title: "Leistungen", text: `${brief.businessName} liefert ${brief.offer} fuer ${brief.audience}.` },
        { title: "Warum wir", text: "Mobile-first, conversion-orientiert und klar positioniert." },
        { title: "Ablauf", text: "Briefing, Konzept, Umsetzung, Launch und Optimierung." },
        { title: "Kontakt", text: `CTA: ${brief.cta}` }
      ]
    : [
        { title: "Services", text: `${brief.businessName} delivers ${brief.offer} for ${brief.audience}.` },
        { title: "Why us", text: "Mobile-first, conversion-driven and clearly positioned." },
        { title: "Process", text: "Briefing, concept, delivery, launch and optimisation." },
        { title: "Contact", text: `CTA: ${brief.cta}` }
      ];

  return {
    headline: llmPlan?.headline || (brief.language === "de"
      ? `${brief.businessName} macht ${brief.industry} klar, stark und verkaufsbereit.`
      : `${brief.businessName} turns ${brief.industry} into a clear high-converting presence.`),
    subheadline: llmPlan?.subheadline || (brief.language === "de"
      ? `Fuer ${brief.audience}: moderne Website mit Fokus auf ${brief.offer}.`
      : `Built for ${brief.audience} with a strong focus on ${brief.offer}.`),
    sections: Array.isArray(llmPlan?.sections) && llmPlan.sections.length ? llmPlan.sections : fallbackSections,
    seoKeywords: Array.isArray(llmPlan?.seoKeywords) && llmPlan.seoKeywords.length
      ? llmPlan.seoKeywords
      : parseCommaList(brief.offer).concat(parseCommaList(brief.industry)),
    palette: brief.colors
  };
}
