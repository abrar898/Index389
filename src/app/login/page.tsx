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
        <div className="flex flex-col items-center text-center space-y-3">
          <div className="relative w-20 h-20 rounded-2xl overflow-hidden border-2 border-[#9fef00]/40 shadow-[0_0_25px_rgba(159,239,0,0.25)] bg-black/60 flex items-center justify-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/logo.png"
              alt="Index 389 Logo"
              className="w-full h-full object-cover"
            />
          </div>
          <div>
            <h1 className="text-xl font-bold font-mono tracking-wider text-[var(--foreground-bright)]">
              INDEX 389 // SECURE AUTH
            </h1>
            <p className="text-xs text-[var(--foreground-muted)] mt-1">
              CTF Team • Cybersecurity • Research Platform
            </p>
          </div>
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

        <div className="text-center pt-2">
          <Link
            href="/"
            className="inline-flex items-center gap-1.5 text-xs font-mono text-[#6c7d9c] hover:text-[#9fef00] transition-colors"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Return to Public Academy</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
