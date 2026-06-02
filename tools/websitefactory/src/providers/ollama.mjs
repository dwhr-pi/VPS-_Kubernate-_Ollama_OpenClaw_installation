export async function tryGeneratePlanWithOllama(brief, env = process.env) {
  const baseUrl = env.OLLAMA_BASE_URL || "http://127.0.0.1:11434";
  const model = env.WEBSITEFACTORY_OLLAMA_MODEL || "qwen2.5-coder";
  const provider = env.WEBSITEFACTORY_PROVIDER || "ollama";
  const timeoutMs = Number(env.WEBSITEFACTORY_OLLAMA_TIMEOUT_MS || 10000);

  if (provider !== "ollama") {
    return null;
  }

  const prompt = [
    "Return strict JSON only.",
    "Schema: {\"headline\": string, \"subheadline\": string, \"sections\": [{\"title\": string, \"text\": string}], \"seoKeywords\": [string]}",
    `Business: ${brief.businessName}`,
    `Industry: ${brief.industry}`,
    `Audience: ${brief.audience}`,
    `Style: ${brief.style}`,
    `CTA: ${brief.cta}`,
    `Language: ${brief.language}`,
    `Offer: ${brief.offer}`,
    `Prompt: ${brief.prompt || ""}`
  ].join("\n");

  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    const response = await fetch(`${baseUrl}/api/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      signal: controller.signal,
      body: JSON.stringify({
        model,
        stream: false,
        messages: [
          { role: "system", content: "Return strict JSON only. No markdown." },
          { role: "user", content: prompt }
        ]
      })
    });
    clearTimeout(timer);

    if (!response.ok) return null;
    const payload = await response.json();
    const content = payload?.message?.content;
    return content ? JSON.parse(content) : null;
  } catch {
    return null;
  }
}
