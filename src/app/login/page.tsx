"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Shield, Lock, User, AlertCircle, ArrowLeft } from "lucide-react";
import Link from "next/link";

import { ThemeToggle } from "@/components/layout/ThemeToggle";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError("");

    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || "Authentication failed");
      }

      router.push("/dashboard");
      router.refresh();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Failed to sign in.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[var(--background)] text-[var(--foreground)] flex items-center justify-center p-3 sm:p-4 cyber-grid relative">
      <div className="absolute top-4 right-4 z-20">
        <ThemeToggle />
      </div>

      <div className="w-full max-w-md rounded-2xl border border-[var(--surface-border)] glass-panel p-5 sm:p-8 shadow-2xl space-y-6">
        <div className="flex flex-col items-center text-center space-y-2">
          <div className="w-12 h-12 rounded-xl bg-[var(--surface-card)] border border-[var(--surface-border)] flex items-center justify-center text-[#9fef00] shadow-inner">
            <Shield className="w-6 h-6" />
          </div>
          <h1 className="text-xl font-bold font-mono tracking-wider text-[var(--foreground-bright)]">
            CYBERNOTES // SECURE AUTH
          </h1>
          <p className="text-xs text-[var(--foreground-muted)]">
            Restricted access knowledge repository. Authorized personnel only.
          </p>
        </div>

        {error && (
          <div className="p-3 rounded-lg bg-[#ff3366]/10 border border-[#ff3366]/30 text-[#ff3366] text-xs flex items-center gap-2">
            <AlertCircle className="w-4 h-4 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-4 text-xs font-mono">
          <div className="space-y-1">
            <label className="text-[#8ba0c3]">OPERATOR IDENTITY (EMAIL)</label>
            <div className="relative">
              <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#6c7d9c]" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full pl-9 pr-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
              />
            </div>
          </div>

          <div className="space-y-1">
            <label className="text-[#8ba0c3]">ACCESS KEY (PASSWORD)</label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#6c7d9c]" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full pl-9 pr-3 py-2 rounded-lg bg-[#111d30] border border-[#1f3352] text-[#ffffff] focus:border-[#9fef00] focus:outline-none"
              />
            </div>
          </div>

          <div className="pt-2">
            <button
              type="submit"
              disabled={isLoading}
              className="w-full py-2.5 rounded-xl bg-[#9fef00] text-[#0b121e] font-bold text-xs hover:bg-[#b4fa1f] transition-all shadow-md active:scale-95 disabled:opacity-50"
            >
              {isLoading ? "AUTHENTICATING..." : "ESTABLISH SESSION"}
            </button>
          </div>
        </form>

        <div className="p-3.5 rounded-xl bg-[#111d30] border border-[#1f3352] text-[11px] font-mono text-[#8ba0c3] space-y-2.5">
          <div className="text-[#9fef00] font-semibold text-xs border-b border-[#1f3352] pb-1">
            PRE-CONFIGURED ACCESS CREDENTIALS:
          </div>

          <div className="space-y-0.5">
            <div className="text-[#ffffff] font-bold flex items-center justify-between">
              <span>ADMINISTRATOR (Full Rights):</span>
              <button
                type="button"
                onClick={() => {
                  setEmail("admin@cybersec.local");
                  setPassword("CyberSecAdmin2026!");
                }}
                className="text-[#9fef00] hover:underline cursor-pointer"
              >
                Use Admin
              </button>
            </div>
            <div>Email: <span className="text-[#a4b1cd]">admin@cybersec.local</span></div>
            <div>Pass: <span className="text-[#a4b1cd]">CyberSecAdmin2026!</span></div>
            <div className="text-[10px] text-[#6c7d9c]">Can create notes, categories, edit, import, and delete.</div>
          </div>

          <div className="space-y-0.5 pt-1.5 border-t border-[#1f3352]">
            <div className="text-[#ffffff] font-bold flex items-center justify-between">
              <span>STANDARD ANALYST (Read-Only):</span>
              <button
                type="button"
                onClick={() => {
                  setEmail("user@cybersec.local");
                  setPassword("CyberSecUser2026!");
                }}
                className="text-[#2de2e6] hover:underline cursor-pointer"
              >
                Use Analyst
              </button>
            </div>
            <div>Email: <span className="text-[#a4b1cd]">user@cybersec.local</span></div>
            <div>Pass: <span className="text-[#a4b1cd]">CyberSecUser2026!</span></div>
            <div className="text-[10px] text-[#6c7d9c]">Read writeups, bookmark favorites, export PDF & Word.</div>
          </div>
        </div>

        <div className="text-center">
          <Link
            href="/"
            className="inline-flex items-center gap-1.5 text-xs font-mono text-[#6c7d9c] hover:text-[#ffffff] transition-colors"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Return to Public Academy</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
