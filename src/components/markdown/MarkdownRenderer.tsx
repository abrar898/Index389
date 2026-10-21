"use client";

import React from "react";
import { AlertCircle, AlertTriangle, CheckCircle2, Info, Terminal } from "lucide-react";
import { TerminalBlock } from "./TerminalBlock";
import { CodeBlock } from "./CodeBlock";

interface MarkdownRendererProps {
  content: string;
}

export function MarkdownRenderer({ content }: MarkdownRendererProps) {
  // Parse content into blocks
  const lines = content.split(/\r?\n/);
  const blocks: React.ReactNode[] = [];

  let inCode = false;
  let codeBuffer: string[] = [];
  let codeLang = "";
  let tableBuffer: string[] = [];
  let inTable = false;

  const flushTable = (key: number) => {
    if (tableBuffer.length === 0) return null;
    const rows = tableBuffer.map((r) =>
      r
        .split("|")
        .map((c) => c.trim())
        .filter((c, i, arr) => i > 0 && i < arr.length - 1)
    );
    const header = rows[0] || [];
    const bodyRows = rows.slice(2); // Skip separator

    const element = (
      <div key={`table-${key}`} className="my-6 overflow-x-auto rounded-xl border border-[#1f3352]">
        <table className="w-full text-left border-collapse text-sm">
          <thead className="bg-[#111d30] text-[#9fef00] font-mono text-xs uppercase tracking-wider font-bold border-b border-[#1f3352]">
            <tr>
              {header.map((col, idx) => (
                <th key={idx} className="px-4 py-2.5">
                  {col}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-[#1f3352] bg-[#070b13] text-[#a4b1cd]">
            {bodyRows.map((r, rIdx) => (
              <tr key={rIdx} className="hover:bg-[#14233c]/50 transition-colors">
                {r.map((col, cIdx) => (
                  <td key={cIdx} className="px-4 py-2.5 font-mono text-xs">
                    {col}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
    tableBuffer = [];
    inTable = false;
    return element;
  };

  const renderInline = (text: string) => {
    // Bold, inline code, links
    const parts: React.ReactNode[] = [];
    const tokens = text.split(/(`[^`]+`|\*\*[^*]+\*\*|\[[^\]]+\]\([^)]+\))/g);

    tokens.forEach((token, idx) => {
      if (token.startsWith("`") && token.endsWith("`")) {
        parts.push(
          <code
            key={idx}
            className="px-1.5 py-0.5 rounded bg-[#070b13] text-[#9fef00] font-mono text-xs font-semibold border border-[#9fef00]/30 inline-block align-baseline mx-0.5"
          >
            {token.slice(1, -1)}
          </code>
        );
      } else if (token.startsWith("**") && token.endsWith("**")) {
        parts.push(
          <strong key={idx} className="font-bold text-white">
            {token.slice(2, -2)}
          </strong>
        );
      } else if (token.startsWith("[") && token.includes("](")) {
        const match = /\[(.*?)\]\((.*?)\)/.exec(token);
        if (match) {
          const rawUrl = match[2].trim();
          const isSafe = !/^(javascript:|data:|vbscript:)/i.test(rawUrl);
          const safeHref = isSafe ? rawUrl : "#blocked-unsafe-link";

          parts.push(
            <a
              key={idx}
              href={safeHref}
              target={safeHref.startsWith("http") ? "_blank" : undefined}
              rel="noopener noreferrer"
              className="text-[#38bdf8] hover:text-[#60a5fa] hover:underline inline-flex items-center gap-0.5"
            >
              {match[1]}
            </a>
          );
        } else {
          parts.push(token);
        }
      } else {
        parts.push(token);
      }
    });

    return parts;
  };

  const slugify = (text: string) =>
    text
      .toLowerCase()
      .trim()
      .replace(/[^\w\s-]/g, "")
      .replace(/[\s_-]+/g, "-")
      .replace(/^-+|-+$/g, "");

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Check code blocks
    if (line.startsWith("```")) {
      if (inCode) {
        const fullCode = codeBuffer.join("\n");
        const isShell = ["bash", "sh", "zsh", "shell", "terminal", "cmd", "powershell"].includes(
          codeLang.toLowerCase()
        );

        if (isShell) {
          blocks.push(<TerminalBlock key={`term-${i}`} command={fullCode} language={codeLang} />);
        } else {
          blocks.push(<CodeBlock key={`code-${i}`} code={fullCode} language={codeLang} />);
        }

        codeBuffer = [];
        inCode = false;
      } else {
        inCode = true;
        codeLang = line.replace("```", "").trim() || "plaintext";
      }
      continue;
    }

    if (inCode) {
      codeBuffer.push(line);
      continue;
    }

    // Check tables
    if (line.trim().startsWith("|") && line.trim().endsWith("|")) {
      inTable = true;
      tableBuffer.push(line.trim());
      continue;
    } else if (inTable) {
      const renderedTable = flushTable(i);
      if (renderedTable) blocks.push(renderedTable);
    }

    // Headings
    if (line.startsWith("# ")) {
      const title = line.slice(2).trim();
      const id = slugify(title);
      blocks.push(
        <h1
          key={`h1-${i}`}
          id={id}
          className="text-2xl md:text-3xl font-extrabold text-white tracking-tight mt-8 mb-4 border-b border-[#1e293b] pb-2.5"
        >
          {renderInline(title)}
        </h1>
      );
    } else if (line.startsWith("## ")) {
      const title = line.slice(3).trim();
      const id = slugify(title);
      blocks.push(
        <h2
          key={`h2-${i}`}
          id={id}
          className="text-lg md:text-xl font-bold text-white tracking-tight mt-8 mb-4 border-b border-[#1e293b] pb-2"
        >
          {renderInline(title)}
        </h2>
      );
    } else if (line.startsWith("### ")) {
      const title = line.slice(4).trim();
      const id = slugify(title);
      blocks.push(
        <h3
          key={`h3-${i}`}
          id={id}
          className="text-base font-semibold text-[#f1f5f9] tracking-tight mt-6 mb-2"
        >
          {renderInline(title)}
        </h3>
      );
    } else if (/^\d+\.\s+[A-Z]/.test(line.trim()) && !line.includes(":") && line.trim().length < 80) {
      // Numbered section header like "1. Reconnaissance & Port Scanning"
      const title = line.trim();
      const id = slugify(title);
      blocks.push(
        <h2
          key={`num-h2-${i}`}
          id={id}
          className="text-lg md:text-xl font-bold text-white tracking-tight mt-8 mb-4 border-b border-[#1e293b] pb-2"
        >
          {renderInline(title)}
        </h2>
      );
    } else if (/^\d+\.\s+/.test(line.trim())) {
      // Regular ordered list item
      const itemText = line.replace(/^\s*\d+\.\s+/, "");
      blocks.push(
        <li key={`oli-${i}`} className="ml-5 list-decimal text-sm md:text-[15px] text-[#cbd5e1] leading-relaxed my-1.5 marker:text-[#38bdf8]">
          {renderInline(itemText)}
        </li>
      );
    } else if (line.startsWith("> ")) {
      const quoteText = line.slice(2).trim();
      const isWarn = quoteText.toLowerCase().includes("warning") || quoteText.toLowerCase().includes("danger");

      blocks.push(
        <div
          key={`quote-${i}`}
          className={`my-4 p-4 rounded-r-lg border-l-4 ${
            isWarn
              ? "bg-[#ff3366]/10 border-[#ff3366] text-[#ff3366]"
              : "bg-[#2de2e6]/10 border-[#2de2e6] text-[#2de2e6]"
          } text-sm leading-relaxed`}
        >
          <div className="flex items-start gap-2.5">
            {isWarn ? (
              <AlertTriangle className="w-5 h-5 flex-shrink-0 mt-0.5 text-[#ff3366]" />
            ) : (
              <Info className="w-5 h-5 flex-shrink-0 mt-0.5 text-[#2de2e6]" />
            )}
            <div className={isWarn ? "text-[#ff3366]" : "text-[#a4b1cd]"}>{renderInline(quoteText)}</div>
          </div>
        </div>
      );
    } else if (line.startsWith("- ") || line.startsWith("* ")) {
      blocks.push(
        <li key={`li-${i}`} className="ml-5 list-disc text-sm md:text-[15px] text-[#cbd5e1] leading-relaxed my-1.5 marker:text-[#38bdf8]">
          {renderInline(line.slice(2).trim())}
        </li>
      );
    } else if (line.trim().length > 0) {
      blocks.push(
        <p key={`p-${i}`} className="my-3 text-sm md:text-[15px] text-[#e2e8f0] leading-relaxed md:leading-7 font-normal">
          {renderInline(line)}
        </p>
      );
    }
  }

  if (inTable) {
    const renderedTable = flushTable(lines.length);
    if (renderedTable) blocks.push(renderedTable);
  }

  return <div className="space-y-1 prose-dark article-prose max-w-none">{blocks}</div>;
}
