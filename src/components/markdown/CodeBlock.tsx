"use client";

import React, { useState } from "react";
import { Check, Copy } from "lucide-react";

interface CodeBlockProps {
  code: string;
  language?: string;
  filename?: string;
}

function getLanguageDotColor(lang: string): string {
  const l = lang.toLowerCase();
  if (["bash", "sh", "cmd", "powershell", "terminal", "zsh", "shell"].includes(l)) {
    return "bg-[#22c55e] shadow-[0_0_8px_#22c55e]";
  }
  if (["python", "py"].includes(l)) {
    return "bg-[#06b6d4] shadow-[0_0_8px_#06b6d4]";
  }
  if (["javascript", "js", "typescript", "ts", "json"].includes(l)) {
    return "bg-[#eab308] shadow-[0_0_8px_#eab308]";
  }
  if (["sql"].includes(l)) {
    return "bg-[#a855f7] shadow-[0_0_8px_#a855f7]";
  }
  if (["html", "xml", "css"].includes(l)) {
    return "bg-[#f97316] shadow-[0_0_8px_#f97316]";
  }
  return "bg-[#38bdf8] shadow-[0_0_8px_#38bdf8]";
}

function renderCodeLine(line: string) {
  const trimmed = line.trim();
  // Comment line
  if (trimmed.startsWith("#") || trimmed.startsWith("//") || trimmed.startsWith("--")) {
    return <span className="text-[#64748b]">{line}</span>;
  }
  return <span className="text-[#38bdf8]">{line || " "}</span>;
}

export function CodeBlock({ code, language = "plaintext", filename }: CodeBlockProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const lines = code.trim().split("\n");
  const dotColor = getLanguageDotColor(language);

  return (
    <div className="my-6 rounded-xl border border-[#1e3a8a]/70 hover:border-[#2563eb]/60 bg-[#060b13] overflow-hidden shadow-[0_4px_24px_rgba(2,6,23,0.7)] text-sm font-mono transition-colors">
      {/* Titlebar */}
      <div className="flex items-center justify-between px-4 py-2.5 bg-[#08101e] border-b border-[#1e293b] select-none">
        <div className="flex items-center gap-2.5">
          <span className={`w-2 h-2 rounded-full inline-block ${dotColor}`} />
          <span className="text-xs font-mono font-bold tracking-wider text-[#e2e8f0] uppercase">
            {filename || language.toUpperCase()}
          </span>
        </div>

        <button
          type="button"
          onClick={handleCopy}
          aria-label="Copy code"
          className="flex items-center gap-1.5 px-3 py-1 text-xs text-[#94a3b8] hover:text-[#f8fafc] bg-[#0c1527] hover:bg-[#13223f] border border-[#1e293b] hover:border-[#2563eb]/50 rounded-md transition-all font-mono font-medium select-none cursor-pointer"
        >
          {copied ? (
            <>
              <Check className="w-3.5 h-3.5 text-[#22c55e]" />
              <span className="text-[#22c55e]">Copied</span>
            </>
          ) : (
            <>
              <Copy className="w-3.5 h-3.5 text-[#94a3b8]" />
              <span>Copy</span>
            </>
          )}
        </button>
      </div>

      {/* Code Content Area */}
      <div className="p-4 md:p-5 overflow-x-auto text-[#38bdf8] leading-relaxed font-mono text-xs md:text-sm">
        <pre className="font-mono whitespace-pre m-0 p-0 text-[#38bdf8] bg-transparent border-0 outline-none">
          <code className="text-[#38bdf8] bg-transparent border-0 outline-none p-0">
            {lines.map((line, idx) => (
              <div key={idx} className="min-h-[1.5rem] border-0 outline-none">
                {renderCodeLine(line)}
              </div>
            ))}
          </code>
        </pre>
      </div>
    </div>
  );
}
