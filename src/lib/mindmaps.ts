import fs from "fs";
import path from "path";
import {
  MindmapItem,
  MindmapSummary,
  MindmapInput,
  extractMindmapStats,
  generateSlug,
} from "./mindmaps-shared";

export * from "./mindmaps-shared";

const DATA_DIR = path.join(process.cwd(), "src", "data", "mindmaps");
const PUBLIC_DIR = path.join(process.cwd(), "public", "mindmaps");

function ensureDirs() {
  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  }
  if (!fs.existsSync(PUBLIC_DIR)) {
    fs.mkdirSync(PUBLIC_DIR, { recursive: true });
  }
}

function initializeDefaultMindmap(): MindmapItem {
  ensureDirs();
  const defaultSlug = "cpts-exam-mindmap";
  const defaultHtmlPath = path.join(PUBLIC_DIR, `${defaultSlug}.html`);

  let htmlContent = "";
  if (fs.existsSync(defaultHtmlPath)) {
    htmlContent = fs.readFileSync(defaultHtmlPath, "utf-8");
  }

  const stats = extractMindmapStats(htmlContent);

  const defaultItem: MindmapItem = {
    id: "mindmap-cpts-exam",
    slug: defaultSlug,
    title: "CPTS Exam Mindmap",
    description:
      "Interactive 9-Phase Penetration Testing & Active Directory Cheat Sheet Mindmap with real-time command substitution, pan/zoom canvas, and live node search.",
    category: "Certifications & Exams",
    tags: ["cpts", "pentest", "active-directory", "privesc", "cheatsheet"],
    htmlContent,
    nodeCount: stats.nodeCount,
    phaseCount: stats.phaseCount,
    commandCount: stats.commandCount,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    isDefault: true,
  };

  const jsonPath = path.join(DATA_DIR, `${defaultSlug}.json`);
  fs.writeFileSync(jsonPath, JSON.stringify(defaultItem, null, 2), "utf-8");
  return defaultItem;
}

export async function getAllMindmaps(): Promise<MindmapSummary[]> {
  ensureDirs();
  const files = fs.readdirSync(DATA_DIR).filter((f) => f.endsWith(".json"));

  if (files.length === 0) {
    const defaultItem = initializeDefaultMindmap();
    const { htmlContent, ...summary } = defaultItem;
    return [summary];
  }

  const mindmaps: MindmapSummary[] = [];

  for (const file of files) {
    try {
      const raw = fs.readFileSync(path.join(DATA_DIR, file), "utf-8");
      const data: MindmapItem = JSON.parse(raw);
      const { htmlContent, ...summary } = data;
      mindmaps.push(summary);
    } catch (err) {
      console.error(`Error reading mindmap file ${file}:`, err);
    }
  }

  // Always ensure CPTS exam mindmap is present
  if (!mindmaps.some((m) => m.slug === "cpts-exam-mindmap")) {
    const defaultItem = initializeDefaultMindmap();
    const { htmlContent, ...summary } = defaultItem;
    mindmaps.unshift(summary);
  }

  return mindmaps.sort((a, b) => (b.isDefault ? 1 : -1) || new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
}

export async function getMindmapBySlug(slug: string): Promise<MindmapItem | null> {
  ensureDirs();
  const filePath = path.join(DATA_DIR, `${slug}.json`);

  if (!fs.existsSync(filePath)) {
    if (slug === "cpts-exam-mindmap") {
      return initializeDefaultMindmap();
    }
    return null;
  }

  try {
    const raw = fs.readFileSync(filePath, "utf-8");
    const data: MindmapItem = JSON.parse(raw);

    // If htmlContent is empty or outdated, check the public html file
    if (!data.htmlContent) {
      const htmlPath = path.join(PUBLIC_DIR, `${slug}.html`);
      if (fs.existsSync(htmlPath)) {
        data.htmlContent = fs.readFileSync(htmlPath, "utf-8");
      }
    }
    return data;
  } catch (err) {
    console.error(`Error loading mindmap ${slug}:`, err);
    return null;
  }
}

export async function saveMindmap(input: MindmapInput): Promise<MindmapItem> {
  ensureDirs();
  const slug = input.slug ? generateSlug(input.slug) : generateSlug(input.title) || `mindmap-${Date.now()}`;
  const existing = await getMindmapBySlug(slug);

  const stats = extractMindmapStats(input.htmlContent);
  const now = new Date().toISOString();

  const mindmap: MindmapItem = {
    id: existing?.id || `mindmap-${Date.now()}`,
    slug,
    title: input.title.trim(),
    description: input.description?.trim() || "Interactive security mindmap and cheat sheet.",
    category: input.category?.trim() || "General Research",
    tags: input.tags && input.tags.length > 0 ? input.tags : ["mindmap", "cybersecurity"],
    htmlContent: input.htmlContent,
    nodeCount: stats.nodeCount,
    phaseCount: stats.phaseCount,
    commandCount: stats.commandCount,
    createdAt: existing?.createdAt || now,
    updatedAt: now,
    isDefault: existing?.isDefault || false,
  };

  // 1. Write JSON file
  fs.writeFileSync(path.join(DATA_DIR, `${slug}.json`), JSON.stringify(mindmap, null, 2), "utf-8");

  // 2. Write Standalone HTML file to public/mindmaps/[slug].html
  fs.writeFileSync(path.join(PUBLIC_DIR, `${slug}.html`), input.htmlContent, "utf-8");

  return mindmap;
}

export async function deleteMindmap(slug: string): Promise<boolean> {
  if (slug === "cpts-exam-mindmap") {
    throw new Error("The default CPTS Exam Mindmap is protected and cannot be deleted.");
  }

  ensureDirs();
  const jsonPath = path.join(DATA_DIR, `${slug}.json`);
  const htmlPath = path.join(PUBLIC_DIR, `${slug}.html`);

  let deleted = false;
  if (fs.existsSync(jsonPath)) {
    fs.unlinkSync(jsonPath);
    deleted = true;
  }
  if (fs.existsSync(htmlPath)) {
    fs.unlinkSync(htmlPath);
  }

  return deleted;
}
