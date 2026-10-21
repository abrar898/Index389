"use client";

import React, { useState } from "react";
import {
  ShieldCheck,
  CheckCircle,
  Copy,
  Terminal,
  FileCheck,
  Code2,
  Lock,
} from "lucide-react";

export function SecurityToolkit() {
  const [activeTab, setActiveTab] = useState<"cheatsheet" | "hasher" | "encoder">("cheatsheet");

  // Hash calculator tool state
  const [inputText, setInputText] = useState("");
  const [sha256Hash, setSha256Hash] = useState("");
  const [copiedHash, setCopiedHash] = useState(false);

  // String encoder / formatter state
  const [rawText, setRawText] = useState("");
  const [base64Output, setBase64Output] = useState("");
  const [urlEncodedOutput, setUrlEncodedOutput] = useState("");
  const [hexOutput, setHexOutput] = useState("");

  const referenceGuides = [
    {
      category: "Network & Port Auditing (Nmap)",
      commands: [
        { desc: "Standard Service & Version Probe", cmd: "nmap -sV -sC -T4 target.htb" },
        { desc: "Fast Port Sweep (Top 1000 Ports)", cmd: "nmap -F -T4 target.htb" },
        { desc: "Operating System Fingerprint Scan", cmd: "nmap -O --osscan-guess target.htb" },
      ],
    },
    {
      category: "System Hardening & Permission Auditing",
      commands: [
        { desc: "List elevated executable permissions", cmd: "find / -perm -4000 -type f 2>/dev/null" },
        { desc: "Audit active listening network sockets", cmd: "ss -tulpn" },
        { desc: "Inspect current user groups & memberships", cmd: "id && groups" },
      ],
    },
    {
      category: "Web & API Security Testing",
      commands: [
        { desc: "Check SSL / TLS Certificate Validity", cmd: "openssl s_client -connect target.htb:443" },
        { desc: "Inspect HTTP Response Security Headers", cmd: "curl -I -s https://target.htb | grep -iE 'security|x-frame|content-security'" },
        { desc: "Directory & Route Enumeration", cmd: "ffuf -u https://target.htb/FUZZ -w wordlist.txt -mc 200,301" },
      ],
    },
  ];

  // SHA-256 calculation using browser WebCrypto API
  const computeHash = async (text: string) => {
    setInputText(text);
    if (!text) {
      setSha256Hash("");
      return;
    }
    try {
      const msgUint8 = new TextEncoder().encode(text);
      const hashBuffer = await crypto.subtle.digest("SHA-256", msgUint8);
      const hashArray = Array.from(new Uint8Array(hashBuffer));
      const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
      setSha256Hash(hashHex);
    } catch {
      setSha256Hash("Calculation error");
    }
  };

  const handleEncode = (val: string) => {
    setRawText(val);
    if (!val) {
      setBase64Output("");
      setUrlEncodedOutput("");
      setHexOutput("");
      return;
    }
    try {
      setBase64Output(btoa(val));
      setUrlEncodedOutput(encodeURIComponent(val));
      const hex = Array.from(new TextEncoder().encode(val))
        .map((b) => b.toString(16).padStart(2, "0"))
        .join(" ");
      setHexOutput(hex);
    } catch {
      // ignore
    }
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
  };

  return (
    <div className="p-6 rounded-2xl glass-panel border-[var(--surface-border)] space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-[var(--surface-border)]">
        <div className="space-y-1">
          <div className="flex items-center gap-2 text-xs font-mono text-[#9fef00]">
            <ShieldCheck className="w-4 h-4" />
            <span>SECURITY AUDIT & RESEARCH UTILITIES</span>
          </div>
          <h2 className="text-lg font-bold text-[var(--foreground-bright)]">
            Security Researcher Toolkit
          </h2>
          <p className="text-xs text-[var(--foreground-muted)]">
            Client-side cryptographic hash calculator, string encoders, and operational security cheatsheets
          </p>
        </div>

        {/* Tab switchers */}
        <div className="flex items-center gap-1 p-1 rounded-xl bg-[var(--surface)] border border-[var(--surface-border)] text-xs font-mono overflow-x-auto">
          <button
            type="button"
            onClick={() => setActiveTab("cheatsheet")}
            className={`px-3 py-1.5 rounded-lg transition-colors cursor-pointer whitespace-nowrap ${
              activeTab === "cheatsheet"
                ? "bg-[var(--primary)]/15 text-[var(--primary)] font-bold"
                : "text-[var(--foreground-muted)] hover:text-[var(--foreground-bright)]"
            }`}
          >
            Audit References
          </button>
          <button
            type="button"
            onClick={() => setActiveTab("hasher")}
            className={`px-3 py-1.5 rounded-lg transition-colors cursor-pointer whitespace-nowrap ${
              activeTab === "hasher"
                ? "bg-[var(--primary)]/15 text-[var(--primary)] font-bold"
                : "text-[var(--foreground-muted)] hover:text-[var(--foreground-bright)]"
            }`}
          >
            SHA256 Hasher
          </button>
          <button
            type="button"
            onClick={() => setActiveTab("encoder")}
            className={`px-3 py-1.5 rounded-lg transition-colors cursor-pointer whitespace-nowrap ${
              activeTab === "encoder"
                ? "bg-[var(--primary)]/15 text-[var(--primary)] font-bold"
                : "text-[var(--foreground-muted)] hover:text-[var(--foreground-bright)]"
            }`}
          >
            Data Encoders
          </button>
        </div>
      </div>

      {/* TAB 1: Cheatsheet */}
      {activeTab === "cheatsheet" && (
        <div className="space-y-6">
          {referenceGuides.map((sec, i) => (
            <div key={i} className="space-y-3">
              <h3 className="text-xs font-mono font-bold text-[var(--foreground-bright)] flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-[#9fef00]" />
                {sec.category}
              </h3>
              <div className="space-y-2">
                {sec.commands.map((item, j) => (
                  <div
                    key={j}
                    className="p-3 rounded-xl bg-[var(--surface)] border border-[var(--surface-border)] flex flex-col md:flex-row md:items-center justify-between gap-2 text-xs font-mono group"
                  >
                    <div className="space-y-1 min-w-0">
                      <span className="text-[11px] text-[var(--foreground-muted)] block">{item.desc}</span>
                      <code className="text-[#9fef00] break-all select-all font-semibold">{item.cmd}</code>
                    </div>
                    <button
                      type="button"
                      onClick={() => copyToClipboard(item.cmd)}
                      className="flex-shrink-0 self-end md:self-center px-2.5 py-1 rounded bg-[var(--surface-card)] hover:bg-[var(--surface-elevated)] border border-[var(--surface-border)] text-[11px] text-[var(--foreground-bright)] flex items-center gap-1.5 transition-colors cursor-pointer"
                    >
                      <Copy className="w-3 h-3" />
                      <span>Copy</span>
                    </button>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* TAB 2: SHA256 Hasher */}
      {activeTab === "hasher" && (
        <div className="space-y-4 max-w-2xl">
          <div className="space-y-1">
            <label className="text-xs font-mono text-[var(--foreground-muted)] block font-semibold">
              Input String / Secret Token / Checksum Source:
            </label>
            <input
              type="text"
              value={inputText}
              onChange={(e) => computeHash(e.target.value)}
              placeholder="Enter text to compute real-time SHA-256 fingerprint..."
              className="w-full px-3 py-2 rounded-xl bg-[var(--surface)] border border-[var(--surface-border)] text-xs font-mono text-[var(--foreground-bright)] focus:border-[#9fef00] focus:outline-none"
            />
          </div>

          {sha256Hash && (
            <div className="p-4 rounded-xl bg-[var(--surface)] border border-[var(--surface-border)] space-y-2">
              <span className="text-[10px] font-mono text-[#9fef00] uppercase tracking-wider block">
                Calculated SHA-256 Checksum:
              </span>
              <div className="flex items-center justify-between gap-3">
                <code className="text-xs font-mono text-[var(--foreground-bright)] break-all select-all">
                  {sha256Hash}
                </code>
                <button
                  type="button"
                  onClick={() => {
                    copyToClipboard(sha256Hash);
                    setCopiedHash(true);
                    setTimeout(() => setCopiedHash(false), 2000);
                  }}
                  className="px-3 py-1.5 rounded-lg bg-[var(--surface-card)] hover:bg-[var(--surface-elevated)] border border-[var(--surface-border)] text-xs font-mono text-[#9fef00] flex items-center gap-1.5 flex-shrink-0 cursor-pointer"
                >
                  {copiedHash ? <CheckCircle className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
                  <span>{copiedHash ? "Copied" : "Copy"}</span>
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* TAB 3: Data Encoders */}
      {activeTab === "encoder" && (
        <div className="space-y-4 max-w-3xl">
          <div className="space-y-1">
            <label className="text-xs font-mono text-[var(--foreground-muted)] block font-semibold">
              Raw Payload or String:
            </label>
            <textarea
              rows={3}
              value={rawText}
              onChange={(e) => handleEncode(e.target.value)}
              placeholder="e.g. admin:supersecretpassword or API query string..."
              className="w-full px-3 py-2 rounded-xl bg-[var(--surface)] border border-[var(--surface-border)] text-xs font-mono text-[var(--foreground-bright)] focus:border-[#9fef00] focus:outline-none resize-none"
            />
          </div>

          {base64Output && (
            <div className="space-y-3">
              <div className="p-3 rounded-xl bg-[var(--surface)] border border-[var(--surface-border)] space-y-1">
                <div className="flex items-center justify-between">
                  <span className="text-[11px] font-mono text-[#2de2e6] uppercase">Base64 Encoded</span>
                  <button
                    type="button"
                    onClick={() => copyToClipboard(base64Output)}
                    className="text-xs text-[var(--foreground-muted)] hover:text-[#ffffff] flex items-center gap-1"
                  >
                    <Copy className="w-3 h-3" />
                    <span>Copy</span>
                  </button>
                </div>
                <code className="text-xs font-mono text-[var(--foreground-bright)] break-all block select-all">
                  {base64Output}
                </code>
              </div>

              <div className="p-3 rounded-xl bg-[var(--surface)] border border-[var(--surface-border)] space-y-1">
                <div className="flex items-center justify-between">
                  <span className="text-[11px] font-mono text-[#9fef00] uppercase">URL Encoded</span>
                  <button
                    type="button"
                    onClick={() => copyToClipboard(urlEncodedOutput)}
                    className="text-xs text-[var(--foreground-muted)] hover:text-[#ffffff] flex items-center gap-1"
                  >
                    <Copy className="w-3 h-3" />
                    <span>Copy</span>
                  </button>
                </div>
                <code className="text-xs font-mono text-[var(--foreground-bright)] break-all block select-all">
                  {urlEncodedOutput}
                </code>
              </div>

              <div className="p-3 rounded-xl bg-[var(--surface)] border border-[var(--surface-border)] space-y-1">
                <div className="flex items-center justify-between">
                  <span className="text-[11px] font-mono text-[#ff8400] uppercase">Hex Byte String</span>
                  <button
                    type="button"
                    onClick={() => copyToClipboard(hexOutput)}
                    className="text-xs text-[var(--foreground-muted)] hover:text-[#ffffff] flex items-center gap-1"
                  >
                    <Copy className="w-3 h-3" />
                    <span>Copy</span>
                  </button>
                </div>
                <code className="text-xs font-mono text-[var(--foreground-bright)] break-all block select-all">
                  {hexOutput}
                </code>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
