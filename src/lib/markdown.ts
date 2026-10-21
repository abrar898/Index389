import matter from "gray-matter";

export interface TocItem {
  id: string;
  text: string;
  level: number;
  sectionNumber?: string;
}

export interface ParsedMarkdown {
  frontmatter: {
    title?: string;
    description?: string;
    category?: string;
    tags?: string[];
    status?: "DRAFT" | "PUBLISHED" | "ARCHIVED";
    visibility?: "PUBLIC" | "PRIVATE" | "RESTRICTED";
    date?: string;
    author?: string;
    [key: string]: unknown;
  };
  title: string;
  description: string;
  category: string;
  tags: string[];
  cleanMarkdown: string;
  toc: TocItem[];
  readingTimeMin: number;
}

function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/[\s_-]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export function parseMarkdownFile(rawContent: string): ParsedMarkdown {
  let parsedMatter;
  try {
    parsedMatter = matter(rawContent);
  } catch {
    parsedMatter = { data: {}, content: rawContent };
  }

  const data = parsedMatter.data || {};
  let content = parsedMatter.content || "";

  // 1. First, check if the note has an explicit "Table of Contents" section with defined links
  const lines = content.split(/\r?\n/);
  let inExplicitToc = false;
  const explicitToc: TocItem[] = [];
  let mainModuleCounter = 1;
  let subCounter = 1;

  for (let i = 0; i < Math.min(250, lines.length); i++) {
    const line = lines[i];
    if (/^#+\s*Table of Contents/i.test(line)) {
      inExplicitToc = true;
      continue;
    }
    if (inExplicitToc) {
      if ((line.trim() === "---" || line.startsWith("#")) && explicitToc.length > 0) {
        break;
      }
      // Match markdown links: e.g. 1. [Title](#part-1-...) or - [Title](#sub-part) or * [Title](url#id)
      const linkMatch = /^(\s*)(?:(\d+)\.|\*|-)\s*\[([^\]]+)\]\(([^)]+)\)/.exec(line);
      if (linkMatch) {
        const indent = linkMatch[1].length;
        const rawNum = linkMatch[2];
        const rawText = linkMatch[3].trim();
        const rawHref = linkMatch[4].trim();

        // Extract anchor hash if present, otherwise slugify title
        const hashIdx = rawHref.indexOf("#");
        const id = hashIdx !== -1
          ? rawHref.slice(hashIdx + 1).replace(/-+/g, "-")
          : slugify(rawText);

        const isSub = indent >= 2 || (!rawNum && (line.trim().startsWith("-") || line.trim().startsWith("*")));

        let sectionNumber = "";
        if (!isSub) {
          sectionNumber = rawNum ? rawNum : String(mainModuleCounter);
          const parsedInt = parseInt(sectionNumber, 10);
          mainModuleCounter = isNaN(parsedInt) ? mainModuleCounter + 1 : parsedInt + 1;
          subCounter = 1;
        } else {
          const parentNum = mainModuleCounter - 1;
          sectionNumber = `${parentNum}.${subCounter++}`;
        }

        explicitToc.push({
          id,
          text: rawText,
          level: isSub ? 2 : 1,
          sectionNumber,
        });
      }
    }
  }

  // 2. If explicit TOC is found in the note, use it! Otherwise extract real headings outside code blocks
  const toc: TocItem[] = [];
  let firstH1 = "";

  if (explicitToc.length > 0) {
    toc.push(...explicitToc);
    // Find first H1 for title
    for (const line of lines) {
      if (line.startsWith("# ") && !line.includes("Table of Contents")) {
        firstH1 = line.slice(2).trim();
        break;
      }
    }
  } else {
    // Extract headings strictly outside code blocks
    let inCode = false;
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (line.trim().startsWith("```")) {
        inCode = !inCode;
        continue;
      }
      if (inCode) continue;

      const headingMatch = /^(#{1,6})\s+(.+)$/.exec(line);
      if (headingMatch) {
        const level = headingMatch[1].length;
        const rawText = headingMatch[2].trim().replace(/\*\*(.*?)\*\*/g, "$1").replace(/`([^`]+)`/g, "$1");
        
        // Skip generic "Table of Contents" heading from becoming an item
        if (/^Table of Contents$/i.test(rawText)) continue;

        const id = slugify(rawText);

        if (level === 1 && !firstH1) {
          firstH1 = rawText;
        }

        if (level >= 1 && level <= 3) {
          toc.push({
            id,
            text: rawText,
            level,
          });
        }
      }
    }
  }

  // Determine Title: Frontmatter -> First H1 -> Default
  const title = (data.title as string)?.trim() || firstH1 || "Untitled Cybersecurity Note";

  // Determine Description
  let description = (data.description as string)?.trim() || "";
  if (!description) {
    // Attempt to extract the first normal text paragraph after any title
    const paragraphs = content
      .split(/\n\n+/)
      .map((p) => p.trim())
      .filter((p) => p && !p.startsWith("#") && !p.startsWith("```") && !p.startsWith(">"));
    if (paragraphs.length > 0) {
      description = paragraphs[0].slice(0, 180) + (paragraphs[0].length > 180 ? "..." : "");
    }
  }

  // Tags
  let tags: string[] = [];
  if (Array.isArray(data.tags)) {
    tags = data.tags.map((t) => String(t).trim().toLowerCase()).filter(Boolean);
  } else if (typeof data.tags === "string") {
    tags = data.tags
      .split(/[,;\s]+/)
      .map((t) => t.trim().toLowerCase())
      .filter(Boolean);
  }

  // Category
  const category = (data.category as string)?.trim() || "General Methodology";

  // Estimate reading time (~200 words per minute)
  const wordCount = content.trim().split(/\s+/).length;
  const readingTimeMin = Math.max(1, Math.ceil(wordCount / 200));

  return {
    frontmatter: data,
    title,
    description,
    category,
    tags,
    cleanMarkdown: content,
    toc,
    readingTimeMin,
  };
}

export function escapeHtml(unsafe: string): string {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
