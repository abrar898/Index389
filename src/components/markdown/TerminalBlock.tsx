"use client";

import React, { useState } from "react";
import { Check, Copy } from "lucide-react";

interface TerminalBlockProps {
  command: string;
  output?: string;
  language?: string;
  filename?: string;
}

export function TerminalBlock({ command, output, language = "bash", filename }: TerminalBlockProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(command);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const dotColor = "bg-[#22c55e] shadow-[0_0_8px_#22c55e]";

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
          aria-label="Copy command"
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

      {/* Terminal Command Input Area */}
      <div className="p-4 md:p-5 overflow-x-auto text-[#38bdf8] font-mono text-xs md:text-sm leading-relaxed whitespace-pre select-text">
        <pre className="font-mono whitespace-pre m-0 p-0 text-[#38bdf8] bg-transparent border-0 outline-none">
          <code className="text-[#38bdf8] bg-transparent border-0 outline-none p-0">{command.trim()}</code>
        </pre>
      </div>

      {/* Terminal Output Area if available */}
      {output && (
        <div className="border-t border-[#1e293b] bg-[#03060a] p-4 text-xs text-[#94a3b8] overflow-x-auto whitespace-pre font-mono">
          <div className="text-[10px] uppercase tracking-wider text-[#484f58] mb-1.5 font-semibold">
            [Output]
          </div>
          {output}
        </div>
      )}
    </div>
  );
}
